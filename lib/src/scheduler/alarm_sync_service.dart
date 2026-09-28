import 'package:drift/drift.dart';

import '../data/database.dart';
import '../data/rule_mapper.dart';
import '../domain/interval_rule.dart';
import '../domain/occurrence_generator.dart';
import 'alarm_sink.dart';

/// Bir eşitleme işleminin sonucu.
class SyncResult {
  const SyncResult({
    required this.scheduled,
    required this.trimmedByLimit,
  });

  /// İşletim sistemine gerçekten kurulan alarm sayısı.
  final int scheduled;

  /// İşletim sistemi limiti yüzünden kurulamayanlar oldu mu?
  final bool trimmedByLimit;
}

/// Kuralları işletim sistemi alarmlarına dönüştüren kayan pencere yöneticisi.
///
/// Neden kayan pencere: iOS'ta AlarmKit'in uygulama başına açıklanmamış bir
/// alarm limiti var. "Her gün 08:00-08:20 arası 2 dakikada bir" kuralı yılda
/// ~4000 alarm demek; hepsini kurmak mümkün değil. Bunun yerine sadece en
/// yakın [windowPerRule] alarmı kurup, her alarm çaldıkça pencereyi ileri
/// kaydırıyoruz.
class AlarmSyncService {
  AlarmSyncService({
    required this.db,
    required this.sink,
    this.windowPerRule = 15,
    this.globalCap = 50,
    this.soundUri = '',
    this.vibrate = true,
  });

  final AppDatabase db;
  final AlarmSink sink;

  /// Tek bir kural için aynı anda kurulu tutulacak en fazla alarm sayısı.
  final int windowPerRule;

  /// Tüm kurallar toplamında kurulu tutulacak en fazla alarm sayısı.
  final int globalCap;

  /// Alarm sesi; boşsa telefonun varsayılan alarm sesi kullanılır.
  final String soundUri;

  /// Alarm çalarken titreşim olsun mu?
  final bool vibrate;

  /// Bir kuralın kurulu alarmlarını silip pencereyi baştan üretir.
  ///
  /// Kural eklendiğinde, düzenlendiğinde veya açılıp kapatıldığında çağrılır.
  Future<SyncResult> syncRule(IntervalRule rule, {DateTime? now}) async {
    final from = now ?? DateTime.now();

    await _cancelAlarmsOfRule(rule.id);

    if (!rule.isEnabled) {
      return const SyncResult(scheduled: 0, trimmedByLimit: false);
    }

    final budget = await _remainingBudget(excludingRule: rule.id);
    final want = windowPerRule < budget ? windowPerRule : budget;
    if (want <= 0) {
      return const SyncResult(scheduled: 0, trimmedByLimit: true);
    }

    final times = nextOccurrences(rule, from, limit: want);
    return _scheduleAll(rule, times);
  }

  /// Bir alarm çaldıktan sonra pencereyi ileri kaydırır.
  ///
  /// Çalan alarm "rang" olarak işaretlenir ve pencerenin sonuna yeni alarmlar
  /// eklenerek kurulu alarm sayısı [windowPerRule] seviyesinde tutulur.
  Future<void> handleRang(String alarmId, {DateTime? now}) async {
    final at = now ?? DateTime.now();
    await db.markAlarmRang(alarmId, at);

    final row = await (db.select(db.scheduledAlarms)
          ..where((a) => a.id.equals(alarmId)))
        .getSingleOrNull();
    if (row == null) return;

    final ruleRow = await (db.select(db.rules)
          ..where((r) => r.id.equals(row.ruleId)))
        .getSingleOrNull();
    if (ruleRow == null) return;

    final rule = ruleFromRow(ruleRow);

    // Tek seferlik kural çaldıysa iş bitti; pencereyi doldurmuyoruz.
    if (rule.recurrence is OneShot) {
      final remaining = await db.pendingCountForRule(rule.id);
      if (remaining == 0) {
        await db.upsertRule(rowFromRule(rule.copyWith(isEnabled: false),
            createdAt: ruleRow.createdAt));
      }
      return;
    }

    await topUp(rule, now: at);
  }

  /// Pencereyi [windowPerRule] seviyesine kadar doldurur; mevcut alarmlara
  /// dokunmaz.
  Future<SyncResult> topUp(IntervalRule rule, {DateTime? now}) async {
    final from = now ?? DateTime.now();
    if (!rule.isEnabled) {
      return const SyncResult(scheduled: 0, trimmedByLimit: false);
    }

    // Tek seferlik kural tanımı gereği tek bir pencere üretir. Penceresi bir
    // kez kurulduysa bir daha doldurulmaz; yoksa alarmlar tükendiğinde
    // nextOccurrences bir sonraki uygun pencereyi bulur ve kural yarın aynı
    // saatte yeniden çalar.
    if (rule.recurrence is OneShot &&
        await db.hasAnyAlarmForRule(rule.id)) {
      return const SyncResult(scheduled: 0, trimmedByLimit: false);
    }

    final pending = await db.pendingCountForRule(rule.id);
    final deficit = windowPerRule - pending;
    if (deficit <= 0) {
      return const SyncResult(scheduled: 0, trimmedByLimit: false);
    }

    final budget = await _remainingBudget(excludingRule: null);
    final want = deficit < budget ? deficit : budget;
    if (want <= 0) {
      return const SyncResult(scheduled: 0, trimmedByLimit: true);
    }

    // Zaten kurulu olan en ileri alarmdan sonrasını istiyoruz, yoksa aynı
    // zamanları ikinci kez kurardık.
    final last = await _latestPendingFireAt(rule.id);
    final anchor = (last != null && last.isAfter(from)) ? last : from;

    final times = nextOccurrences(rule, anchor, limit: want);
    return _scheduleAll(rule, times);
  }

  Future<SyncResult> _scheduleAll(IntervalRule rule, List<DateTime> times) async {
    var scheduled = 0;
    var trimmed = false;

    for (final t in times) {
      final id = _alarmId(rule.id, t);
      try {
        await sink.schedule(
          id: id,
          at: t,
          label: rule.label,
          soundUri: soundUri,
          vibrate: vibrate,
        );
      } on AlarmLimitReachedException {
        // Limit dolduysa daha fazlasını denemek anlamsız; elimizdekiyle yetin.
        trimmed = true;
        break;
      }
      await db.insertAlarms([
        ScheduledAlarm(
          id: id,
          ruleId: rule.id,
          fireAt: t,
          status: 'pending',
          ranAt: null,
        ),
      ]);
      scheduled++;
    }

    return SyncResult(scheduled: scheduled, trimmedByLimit: trimmed);
  }

  Future<void> _cancelAlarmsOfRule(String ruleId) async {
    // Ertelenmiş alarmlar da iptal edilmeli: yoksa kullanıcı kuralı
    // kapattıktan sonra ertelediği alarm yine çalar.
    for (final a in await db.cancellableAlarmsOfRule(ruleId)) {
      await sink.cancel(a.id);
    }
    await db.clearAlarmsOfRule(ruleId);
  }

  /// Kullanıcı bir alarmı ertelediğinde çağrılır.
  ///
  /// Erteleme eklentinin içinde gerçekleşiyor; kendi tablomuza yazmazsak
  /// kural kapatıldığında bu alarmı iptal edemiyoruz.
  Future<void> recordSnooze(String alarmId, int minutes, {DateTime? now}) {
    final at = (now ?? DateTime.now()).add(Duration(minutes: minutes));
    return db.markAlarmSnoozed(alarmId, ruleIdOf(alarmId), at);
  }

  /// Alarm kimliği `<kuralId>_<epoch>` biçiminde üretiliyor.
  static String ruleIdOf(String alarmId) {
    final i = alarmId.lastIndexOf('_');
    return i <= 0 ? alarmId : alarmId.substring(0, i);
  }

  Future<int> _remainingBudget({String? excludingRule}) async {
    final q = db.selectOnly(db.scheduledAlarms)
      ..addColumns([db.scheduledAlarms.id.count()])
      ..where(db.scheduledAlarms.status.equals('pending'));
    if (excludingRule != null) {
      q.where(db.scheduledAlarms.ruleId.equals(excludingRule).not());
    }
    final row = await q.getSingle();
    final used = row.read(db.scheduledAlarms.id.count()) ?? 0;
    return globalCap - used;
  }

  Future<DateTime?> _latestPendingFireAt(String ruleId) async {
    final q = db.select(db.scheduledAlarms)
      ..where((a) => a.ruleId.equals(ruleId) & a.status.equals('pending'))
      ..orderBy([(a) => OrderingTerm.desc(a.fireAt)])
      ..limit(1);
    final row = await q.getSingleOrNull();
    return row?.fireAt;
  }

  /// Alarm kimliği zamandan türetiliyor: aynı kural + aynı zaman için ikinci
  /// kez alarm kurulması imkânsız hale geliyor.
  String _alarmId(String ruleId, DateTime at) =>
      '${ruleId}_${at.millisecondsSinceEpoch}';
}
