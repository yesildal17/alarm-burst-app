import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_burst/src/features/stopwatch/stopwatch_page.dart';
import 'package:alarm_burst/src/features/timer/timer_page.dart';
import 'package:alarm_burst/src/features/worldclock/world_clock_page.dart';
import 'package:alarm_burst/src/platform/widget_bridge.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('kronometre biçimi', () {
    test('bir saatin altında dakika:saniye,yüzdebir', () {
      expect(formatElapsed(const Duration(seconds: 5, milliseconds: 240)),
          '00:05,24');
      expect(formatElapsed(const Duration(minutes: 12, seconds: 7)), '12:07,00');
    });

    test('bir saati geçince saat hanesi eklenir', () {
      expect(formatElapsed(const Duration(hours: 1, minutes: 2, seconds: 3)),
          '1:02:03,00');
    });

    test('sıfır', () => expect(formatElapsed(Duration.zero), '00:00,00'));
  });

  group('zamanlayıcı biçimi', () {
    test('dakika:saniye', () {
      expect(formatRemaining(const Duration(minutes: 4, seconds: 30)), '04:30');
    });

    test('saat hanesi', () {
      expect(formatRemaining(const Duration(hours: 2, minutes: 5, seconds: 9)),
          '2:05:09');
    });

    test('negatif süre sıfır gösterir', () {
      expect(formatRemaining(const Duration(seconds: -10)), '00:00');
    });
  });

  group('dünya saati', () {
    setUpAll(tzdata.initializeTimeZones);

    test('şehir adı saat diliminden çıkarılır', () {
      expect(cityOf('Europe/Istanbul'), 'Istanbul');
      expect(cityOf('America/New_York'), 'New York');
      expect(cityOf('Asia/Tokyo'), 'Tokyo');
    });

    test('fark yoksa "Aynı saat"', () {
      expect(formatOffset(Duration.zero), 'Aynı saat');
    });

    test('tam saatlik farklar', () {
      expect(formatOffset(const Duration(hours: 2)), '+2 saat');
      expect(formatOffset(const Duration(hours: -5)), '-5 saat');
      expect(formatOffset(const Duration(hours: 12)), '+12 saat');
    });

    test('buçuklu ve çeyrekli farklar', () {
      // Hindistan +5,5 · Nepal +5,75 · Chatham +12,75 gibi dilimler
      expect(formatOffset(const Duration(hours: 5, minutes: 30)), '+5,5 saat');
      expect(formatOffset(const Duration(hours: -3, minutes: -30)), '-3,5 saat');
      expect(formatOffset(const Duration(hours: 5, minutes: 45)), '+5,8 saat');
    });

    test('gerçek saat dilimi farkı hesaplanır', () {
      final now = DateTime.now();
      final label = offsetLabel(tz.getLocation('Pacific/Auckland'), now);
      expect(label, contains('saat'));
    });
  });

  group('widget sıradaki alarm metni', () {
    final from = DateTime(2026, 9, 27, 10, 0); // pazar

    test('bugünkü alarm sadece saat', () {
      expect(describeNextAlarm(DateTime(2026, 9, 27, 14, 30), from), '⏰ 14:30');
    });

    test('yarınki alarm', () {
      expect(describeNextAlarm(DateTime(2026, 9, 28, 8, 0), from),
          '⏰ Yarın 08:00');
    });

    test('daha ileri tarih gün adıyla', () {
      // 2026-10-02 cuma
      expect(describeNextAlarm(DateTime(2026, 10, 2, 7, 5), from),
          '⏰ Cum 07:05');
    });
  });
}
