import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_burst/src/data/database.dart';
import 'package:alarm_burst/src/data/rule_mapper.dart';
import 'package:alarm_burst/src/domain/interval_rule.dart';
import 'package:alarm_burst/src/scheduler/alarm_sync_service.dart';

import 'fake_alarm_sink.dart';

void main() {
  late AppDatabase db;
  late FakeAlarmSink sink;
  late AlarmSyncService service;

  // 08:00-08:20 / 2 dk = 11 alarm, her gün.
  IntervalRule daily({String id = 'r1', bool enabled = true}) => IntervalRule(
        id: id,
        label: 'sabah',
        startMinute: 8 * 60,
        endMinute: 8 * 60 + 20,
        intervalMinutes: 2,
        recurrence: const Weekly({1, 2, 3, 4, 5, 6, 7}),
        isEnabled: enabled,
      );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    sink = FakeAlarmSink();
    service = AlarmSyncService(db: db, sink: sink, windowPerRule: 5, globalCap: 12);
  });

  tearDown(() => db.close());

  Future<void> saveRule(IntervalRule r) => db.upsertRule(rowFromRule(r));

  test('pencere kadar alarm kurar, kuralın tamamını değil', () async {
    final r = daily();
    await saveRule(r);

    final result = await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));

    expect(result.scheduled, 5, reason: 'windowPerRule = 5');
    expect(result.trimmedByLimit, isFalse);
    expect(sink.scheduled.length, 5);
    expect(await db.pendingCountForRule('r1'), 5);
  });

  test('kurulan alarmlar kuralın ilk alarmlarıyla aynı', () async {
    final r = daily();
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));

    final times = sink.scheduled.values.toList()..sort();
    expect(
      times.map((d) => '${d.hour}:${d.minute.toString().padLeft(2, '0')}'),
      ['8:00', '8:02', '8:04', '8:06', '8:08'],
    );
  });

  test('devre dışı kural alarm kurmaz ve mevcutları iptal eder', () async {
    final r = daily();
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));
    expect(sink.scheduled.length, 5);

    final off = r.copyWith(isEnabled: false);
    await saveRule(off);
    final result = await service.syncRule(off, now: DateTime(2026, 9, 28, 7, 0));

    expect(result.scheduled, 0);
    expect(sink.scheduled, isEmpty, reason: 'hepsi iptal edildi');
    expect(sink.cancelled.length, 5);
    expect(await db.pendingCountForRule('r1'), 0);
  });

  test('genel üst sınır kurallar arasında paylaşılır', () async {
    // globalCap 12, windowPerRule 5 → üç kural: 5 + 5 + 2
    for (final id in ['r1', 'r2', 'r3']) {
      final r = daily(id: id);
      await saveRule(r);
      await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));
    }

    expect(sink.scheduled.length, 12, reason: 'globalCap aşılmadı');
    expect(await db.pendingCountForRule('r3'), 2);
  });

  test('alarm çaldıkça pencere ileri kayar', () async {
    final r = daily();
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));

    final first = (sink.scheduled.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .first;

    await service.handleRang(first.key, now: DateTime(2026, 9, 28, 8, 0));

    expect(await db.pendingCountForRule('r1'), 5,
        reason: 'biri çaldı, pencere yeniden doldu');

    final times = await (db.select(db.scheduledAlarms)).get();
    expect(times.where((a) => a.status == 'rang').length, 1);
    expect(times.where((a) => a.status == 'pending').length, 5);
  });

  test('pencere doldurulurken aynı zaman ikinci kez kurulmaz', () async {
    final r = daily();
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));
    final before = sink.scheduled.values.toSet();

    await service.topUp(r, now: DateTime(2026, 9, 28, 7, 0));

    expect(sink.scheduled.length, 5, reason: 'zaten dolu, yeni eklenmedi');
    expect(sink.scheduled.values.toSet(), before);
  });

  test('işletim sistemi limitine takılınca elindekiyle yetinir', () async {
    sink.failAfter = 3;
    final r = daily();
    await saveRule(r);

    final result = await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));

    expect(result.scheduled, 3);
    expect(result.trimmedByLimit, isTrue);
    expect(await db.pendingCountForRule('r1'), 3,
        reason: 'veritabanı kurulmamış alarmı kaydetmemeli');
  });

  test('tek seferlik kural tüm alarmları çalınca kendini kapatır', () async {
    final r = IntervalRule(
      id: 'once',
      label: 'tek',
      startMinute: 8 * 60,
      endMinute: 8 * 60 + 4,
      intervalMinutes: 2,
      recurrence: const OneShot(),
    );
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));
    expect(await db.pendingCountForRule('once'), 3, reason: '08:00/02/04');

    final ids = (sink.scheduled.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value)))
        .map((e) => e.key)
        .toList();

    await service.handleRang(ids[0], now: DateTime(2026, 9, 28, 8, 0));
    var row = await db.allRules();
    expect(row.single.isEnabled, isTrue, reason: 'hâlâ bekleyen alarm var');

    await service.handleRang(ids[1], now: DateTime(2026, 9, 28, 8, 2));
    await service.handleRang(ids[2], now: DateTime(2026, 9, 28, 8, 4));

    row = await db.allRules();
    expect(row.single.isEnabled, isFalse,
        reason: 'hepsi çaldı, kural kendini kapattı');
  });

  test('kural düzenlenince eski alarmlar silinip yenileri kurulur', () async {
    final r = daily();
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));
    final oldIds = sink.scheduled.keys.toSet();

    // Başlangıcı 09:00'a taşı.
    final moved = r.copyWith(startMinute: 9 * 60, endMinute: 9 * 60 + 20);
    await saveRule(moved);
    await service.syncRule(moved, now: DateTime(2026, 9, 28, 7, 0));

    expect(sink.cancelled.toSet(), oldIds, reason: 'eskiler iptal edildi');
    expect(sink.scheduled.length, 5);
    expect(sink.scheduled.values.every((d) => d.hour == 9), isTrue);
  });

  test('penceresi gecmis tek seferlik kural yarina tasmaz', () async {
    // Gercek cihazda yakalanan hata: uygulama acilisindaki telafi kodu
    // topUp'i cagiriyor, topUp tek seferlik kurali bilmedigi icin bir
    // sonraki uygun pencereyi (yarin ayni saat) kuruyordu.
    final r = IntervalRule(
      id: 'once',
      label: 'tek',
      startMinute: 16 * 60 + 40,
      endMinute: 16 * 60 + 50,
      intervalMinutes: 1,
      recurrence: const OneShot(),
    );
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 27, 16, 40));

    final scheduledDays = sink.scheduled.values.map((d) => d.day).toSet();
    expect(scheduledDays, {27}, reason: 'sadece bugunun penceresi');

    // Pencere tukendikten sonra telafi: hicbir sey eklenmemeli.
    for (final a in await db.allPendingAlarms()) {
      await db.markAlarmRang(a.id, a.fireAt);
    }
    final result = await service.topUp(r, now: DateTime(2026, 9, 27, 16, 51));

    expect(result.scheduled, 0, reason: 'tek seferlik kural yeniden kurulmaz');
    expect(sink.scheduled.values.map((d) => d.day).toSet(), {27});
  });

  test('tekrarli kural pencere tukenince sonraki gune uzar', () async {
    // Tek seferlik korumasinin tekrarli kurallari engellemedigini dogrular.
    final r = daily();
    await saveRule(r);
    await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));
    for (final a in await db.allPendingAlarms()) {
      await db.markAlarmRang(a.id, a.fireAt);
    }

    final result = await service.topUp(r, now: DateTime(2026, 9, 28, 9, 0));

    expect(result.scheduled, greaterThan(0));
    expect(sink.scheduled.values.any((d) => d.day == 29), isTrue,
        reason: 'ertesi gunun penceresi kuruldu');
  });

  group('erteleme', () {
    test('ertelenen alarm kendi tablomuza yazilir', () async {
      final r = daily();
      await saveRule(r);
      await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));

      final first = (sink.scheduled.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value)))
          .first;
      await service.handleRang(first.key, now: DateTime(2026, 9, 28, 8, 0));
      await service.recordSnooze(first.key, 5,
          now: DateTime(2026, 9, 28, 8, 0));

      final row = await (db.select(db.scheduledAlarms)
            ..where((a) => a.id.equals(first.key)))
          .getSingle();

      expect(row.status, 'snoozed');
      expect(row.fireAt, DateTime(2026, 9, 28, 8, 5));
    });

    test('kural kapatilinca ertelenen alarm da iptal edilir', () async {
      // Gercek cihazda yakalanan hata: erteleme eklentinin icinde olup
      // bitiyordu, bizim tablomuzda kaydi yoktu, kural kapatilinca iptal
      // edilemiyordu ve kapatilmis alarm yine caliyordu.
      final r = daily();
      await saveRule(r);
      await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));

      final first = (sink.scheduled.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value)))
          .first;
      await service.handleRang(first.key, now: DateTime(2026, 9, 28, 8, 0));
      await service.recordSnooze(first.key, 5,
          now: DateTime(2026, 9, 28, 8, 0));
      sink.cancelled.clear();

      final off = r.copyWith(isEnabled: false);
      await saveRule(off);
      await service.syncRule(off, now: DateTime(2026, 9, 28, 8, 1));

      expect(sink.cancelled, contains(first.key),
          reason: 'ertelenen alarm iptal edilmeli');
      expect(sink.scheduled, isEmpty, reason: 'hicbir alarm kurulu kalmamali');
    });

    test('kural silinince ertelenen alarm da iptal edilir', () async {
      final r = daily();
      await saveRule(r);
      await service.syncRule(r, now: DateTime(2026, 9, 28, 7, 0));

      final first = (sink.scheduled.entries.toList()
            ..sort((a, b) => a.value.compareTo(b.value)))
          .first;
      await service.handleRang(first.key, now: DateTime(2026, 9, 28, 8, 0));
      await service.recordSnooze(first.key, 5,
          now: DateTime(2026, 9, 28, 8, 0));

      await service.syncRule(r.copyWith(isEnabled: false),
          now: DateTime(2026, 9, 28, 8, 1));
      await db.deleteRule(r.id);

      expect(sink.scheduled, isEmpty);
      expect(await db.allPendingAlarms(), isEmpty);
    });

    test('alarm kimliginden kural kimligi cikarilir', () {
      expect(AlarmSyncService.ruleIdOf('12345_67890'), '12345');
      expect(AlarmSyncService.ruleIdOf('bozuk'), 'bozuk');
    });
  });
}
