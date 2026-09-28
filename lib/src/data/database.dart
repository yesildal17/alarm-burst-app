import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// Kullanıcının tanımladığı alarm kuralları.
///
/// Kullanıcı *kuralı* düzenler; işletim sistemi ise tek tek alarmlar ister.
/// İkisini ayrı tutmak, "bitişi 08:30 yap" dendiğinde eski alarmları silip
/// yenilerini üretmeyi temiz hale getiriyor.
class Rules extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().withDefault(const Constant(''))();

  /// Gün başından itibaren dakika, 0-1439.
  IntColumn get startMinute => integer()();
  IntColumn get endMinute => integer()();
  IntColumn get intervalMinutes => integer()();

  /// Haftanın günleri bit maskesi: pazartesi = 1<<0 ... pazar = 1<<6.
  /// 0 ise kural tek seferliktir.
  IntColumn get weekdayMask => integer().withDefault(const Constant(0))();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Bir kuraldan üretilmiş, işletim sistemine kurulmuş tek bir alarm.
///
/// Sadece kayan pencere içindeki alarmlar burada tutulur; kuralın tüm
/// gelecek alarmları değil.
class ScheduledAlarms extends Table {
  /// Aynı zamanda işletim sistemine verilen alarm kimliği.
  TextColumn get id => text()();

  TextColumn get ruleId =>
      text().references(Rules, #id, onDelete: KeyAction.cascade)();

  /// Alarmın çalacağı yerel zaman.
  DateTimeColumn get fireAt => dateTime()();

  /// pending | rang | dismissed | snoozed
  TextColumn get status => text().withDefault(const Constant('pending'))();

  DateTimeColumn get ranAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Rules, ScheduledAlarms])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'interval_alarm'));

  @override
  int get schemaVersion => 1;

  Future<List<Rule>> allRules() =>
      (select(rules)..orderBy([(r) => OrderingTerm(expression: r.startMinute)]))
          .get();

  Stream<List<Rule>> watchRules() =>
      (select(rules)..orderBy([(r) => OrderingTerm(expression: r.startMinute)]))
          .watch();

  Future<void> upsertRule(Rule rule) =>
      into(rules).insertOnConflictUpdate(rule);

  Future<void> deleteRule(String id) =>
      (delete(rules)..where((r) => r.id.equals(id))).go();

  /// Bir kurala ait kurulmuş alarmları siler; kural düzenlenince
  /// yeniden üretilmesi için önce bunlar temizlenir.
  Future<void> clearAlarmsOfRule(String ruleId) =>
      (delete(scheduledAlarms)..where((a) => a.ruleId.equals(ruleId))).go();

  Future<void> insertAlarms(List<ScheduledAlarm> alarms) async {
    await batch((b) => b.insertAll(scheduledAlarms, alarms));
  }

  /// Kayan pencerenin ileri kaydırılması için: bekleyen alarm sayısı.
  Future<int> pendingCountForRule(String ruleId) async {
    final q = selectOnly(scheduledAlarms)
      ..addColumns([scheduledAlarms.id.count()])
      ..where(
        scheduledAlarms.ruleId.equals(ruleId) &
            scheduledAlarms.status.equals('pending'),
      );
    final row = await q.getSingle();
    return row.read(scheduledAlarms.id.count()) ?? 0;
  }

  /// Geçmişte kalmış ama hâlâ "pending" duran alarmlar.
  ///
  /// Uygulama kapalıyken çalan alarmların olayı bize ulaşmıyor; açılışta
  /// bunları tespit edip pencereyi telafi ediyoruz.
  Future<List<ScheduledAlarm>> pendingAlarmsBefore(
    String ruleId,
    DateTime before,
  ) {
    return (select(scheduledAlarms)
          ..where((a) =>
              a.ruleId.equals(ruleId) &
              a.status.equals('pending') &
              a.fireAt.isSmallerThanValue(before)))
        .get();
  }

  /// Tum kurallardaki bekleyen alarmlar (testler ve telafi icin).
  Future<List<ScheduledAlarm>> allPendingAlarms() {
    return (select(scheduledAlarms)..where((a) => a.status.equals('pending')))
        .get();
  }

  /// Bu kural icin herhangi bir alarm uretilmis mi (calmis olanlar dahil)?
  Future<bool> hasAnyAlarmForRule(String ruleId) async {
    final q = selectOnly(scheduledAlarms)
      ..addColumns([scheduledAlarms.id.count()])
      ..where(scheduledAlarms.ruleId.equals(ruleId));
    final row = await q.getSingle();
    return (row.read(scheduledAlarms.id.count()) ?? 0) > 0;
  }

  /// Ertelenen alarmı kaydeder.
  ///
  /// Erteleme eklentinin içinde olup bitiyor; kaydetmezsek kural kapatıldığında
  /// iptal edemiyoruz ve kapatılmış bir alarm yine çalıyor.
  Future<void> markAlarmSnoozed(
    String alarmId,
    String ruleId,
    DateTime newFireAt,
  ) {
    return into(scheduledAlarms).insertOnConflictUpdate(
      ScheduledAlarm(
        id: alarmId,
        ruleId: ruleId,
        fireAt: newFireAt,
        status: 'snoozed',
        ranAt: null,
      ),
    );
  }

  /// Bir kuralın iptal edilmesi gereken alarmları: henüz çalmamış olanlar
  /// ve ertelenmiş olanlar.
  Future<List<ScheduledAlarm>> cancellableAlarmsOfRule(String ruleId) {
    return (select(scheduledAlarms)
          ..where((a) =>
              a.ruleId.equals(ruleId) &
              a.status.isIn(['pending', 'snoozed'])))
        .get();
  }

  Future<void> markAlarmRang(String alarmId, DateTime at) {
    return (update(scheduledAlarms)..where((a) => a.id.equals(alarmId)))
        .write(ScheduledAlarmsCompanion(
      status: const Value('rang'),
      ranAt: Value(at),
    ));
  }
}
