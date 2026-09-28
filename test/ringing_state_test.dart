import 'package:alarm_plus/alarm_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_burst/src/features/ringing/ringing_state.dart';

AlarmModel model({
  required String status,
  required DateTime scheduledAt,
  String label = 'sabah',
}) {
  return AlarmModel.fromMap({
    'id': 'a1',
    'scheduledTimeUtcMs': scheduledAt.toUtc().millisecondsSinceEpoch,
    'scheduledTimeLocalIso': scheduledAt.toIso8601String(),
    'payloadJson': '{"label":"$label"}',
    'status': status,
    'createdAtMs': 0,
    'updatedAtMs': 0,
    'retryCount': 0,
    'platformMeta': <String, dynamic>{},
  });
}

void main() {
  final now = DateTime(2026, 9, 27, 8, 0);

  group('fromModelIfRinging', () {
    test('çalan alarmı gösterir', () {
      final a = RingingAlarm.fromModelIfRinging(
        model(status: 'triggered', scheduledAt: now.subtract(const Duration(seconds: 20))),
        now: now,
      );

      expect(a, isNotNull);
      expect(a!.label, 'sabah');
    });

    test('susturulmuş alarmı göstermez', () {
      // Gerçek cihazda yakalanan hata: getLaunchAlarm susturulmuş alarmı da
      // döndürüyordu, uygulama her açılışta sahte alarm ekranına düşüyordu.
      for (final s in ['stopped', 'canceled', 'scheduled', 'error']) {
        expect(
          RingingAlarm.fromModelIfRinging(
            model(status: s, scheduledAt: now.subtract(const Duration(seconds: 20))),
            now: now,
          ),
          isNull,
          reason: '"$s" durumu alarm ekranı açmamalı',
        );
      }
    });

    test('çok eski alarmı göstermez', () {
      // Telefon kapalıyken geçen alarm, açılışta ekrana gelmemeli.
      final a = RingingAlarm.fromModelIfRinging(
        model(status: 'triggered', scheduledAt: now.subtract(const Duration(hours: 3))),
        now: now,
      );

      expect(a, isNull);
    });

    test('sınırın hemen içindeki alarm gösterilir', () {
      final a = RingingAlarm.fromModelIfRinging(
        model(
          status: 'triggered',
          scheduledAt: now.subtract(RingingAlarm.maxRingingAge - const Duration(minutes: 1)),
        ),
        now: now,
      );

      expect(a, isNotNull);
    });

    test('boş model null döner', () {
      expect(RingingAlarm.fromModelIfRinging(null, now: now), isNull);
    });
  });

  test('etiket okunamazsa alarm yine de gösterilir', () {
    final m = AlarmModel.fromMap({
      'id': 'a2',
      'scheduledTimeUtcMs': now.toUtc().millisecondsSinceEpoch,
      'scheduledTimeLocalIso': now.toIso8601String(),
      'payloadJson': 'bozuk json',
      'status': 'triggered',
      'createdAtMs': 0,
      'updatedAtMs': 0,
      'retryCount': 0,
      'platformMeta': <String, dynamic>{},
    });

    final a = RingingAlarm.fromModelIfRinging(m, now: now);
    expect(a, isNotNull, reason: 'etiket süs, alarm çalmalı');
    expect(a!.label, '');
  });

  group('pickRinging', () {
    test('listedeki çalan alarmı bulur', () {
      final a = RingingAlarm.pickRinging([
        model(status: 'scheduled', scheduledAt: now.add(const Duration(hours: 1))),
        model(status: 'stopped', scheduledAt: now.subtract(const Duration(minutes: 5))),
        model(status: 'triggered', scheduledAt: now.subtract(const Duration(seconds: 30)), label: 'çalan'),
      ], now: now);

      expect(a, isNotNull);
      expect(a!.label, 'çalan');
    });

    test('çalan yoksa null döner', () {
      final a = RingingAlarm.pickRinging([
        model(status: 'scheduled', scheduledAt: now.add(const Duration(hours: 1))),
        model(status: 'stopped', scheduledAt: now.subtract(const Duration(minutes: 5))),
      ], now: now);

      expect(a, isNull);
    });

    test('boş liste null döner', () {
      expect(RingingAlarm.pickRinging(const [], now: now), isNull);
    });

    test('çok eski tetiklenmiş alarmı seçmez', () {
      final a = RingingAlarm.pickRinging([
        model(status: 'triggered', scheduledAt: now.subtract(const Duration(hours: 5))),
      ], now: now);

      expect(a, isNull);
    });
  });
}
