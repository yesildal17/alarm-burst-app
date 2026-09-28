import 'package:flutter_test/flutter_test.dart';
import 'package:alarm_burst/src/domain/interval_rule.dart';
import 'package:alarm_burst/src/domain/occurrence_generator.dart';

IntervalRule rule({
  int start = 8 * 60,
  int end = 8 * 60 + 20,
  int interval = 2,
  Recurrence recurrence = const OneShot(),
  bool enabled = true,
}) {
  return IntervalRule(
    id: 'r1',
    label: 'test',
    startMinute: start,
    endMinute: end,
    intervalMinutes: interval,
    recurrence: recurrence,
    isEnabled: enabled,
  );
}

String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

void main() {
  group('occurrenceCount', () {
    test('08:00-08:20 / 2 dk → 11 alarm (iki uç dahil)', () {
      expect(rule().occurrenceCount, 11);
    });

    test('başlangıç ve bitiş aynıysa tek alarm', () {
      expect(rule(start: 8 * 60, end: 8 * 60).occurrenceCount, 1);
    });

    test('aralık pencereden büyükse tek alarm', () {
      expect(rule(interval: 60).occurrenceCount, 1);
    });

    test('aralık pencereyi tam bölmüyorsa son alarm bitişi aşmaz', () {
      // 08:00-08:20, 3 dk: 00,03,06,09,12,15,18 → 7 alarm (08:21 üretilmez)
      expect(rule(interval: 3).occurrenceCount, 7);
    });

    test('gece yarısını aşan pencere', () {
      // 23:50 → 00:10 = 20 dakika
      final r = rule(start: 23 * 60 + 50, end: 10, interval: 5);
      expect(r.crossesMidnight, isTrue);
      expect(r.windowLengthMinutes, 20);
      expect(r.occurrenceCount, 5);
    });

    test('geçersiz aralık sıfır alarm', () {
      expect(rule(interval: 0).occurrenceCount, 0);
    });
  });

  group('occurrencesOnDay', () {
    test('senin örneğin: 08:00 ile 08:20 arası 2 dakika', () {
      final day = DateTime(2026, 9, 28); // pazartesi
      final times = occurrencesOnDay(rule(), day).map(hhmm).toList();

      expect(times, [
        '08:00', '08:02', '08:04', '08:06', '08:08', '08:10',
        '08:12', '08:14', '08:16', '08:18', '08:20',
      ]);
      expect(times.length, 11);
    });

    test('gece yarısını aşan pencere ertesi güne taşar', () {
      final day = DateTime(2026, 9, 28);
      final times = occurrencesOnDay(
        rule(start: 23 * 60 + 50, end: 10, interval: 10),
        day,
      );

      expect(times.map(hhmm).toList(), ['23:50', '00:00', '00:10']);
      expect(times[0].day, 28);
      expect(times[1].day, 29, reason: 'gece yarısından sonrası ertesi gün');
      expect(times[2].day, 29);
    });

    test('ay sonunu aşan pencere doğru normalize edilir', () {
      final times = occurrencesOnDay(
        rule(start: 23 * 60 + 50, end: 10, interval: 20),
        DateTime(2026, 9, 30),
      );
      expect(times.last.month, 10);
      expect(times.last.day, 1);
    });
  });

  group('nextOccurrences — kayan pencere', () {
    test('şu andan sonrasını döndürür, geçmişi atlar', () {
      final now = DateTime(2026, 9, 28, 8, 7); // 08:06 geçti, 08:08 sırada
      final next = nextOccurrences(rule(), now, limit: 3).map(hhmm).toList();

      expect(next, ['08:08', '08:10', '08:12']);
    });

    test('limit kadar alarm döndürür, fazlasını değil', () {
      final now = DateTime(2026, 9, 28, 7, 0);
      expect(nextOccurrences(rule(), now, limit: 4).length, 4);
    });

    test('pencere tam üzerindeki an tekrar üretilmez', () {
      // 08:10'da tam alarm çaldı; bir sonraki 08:12 olmalı, 08:10 değil.
      final now = DateTime(2026, 9, 28, 8, 10);
      expect(hhmm(nextOccurrences(rule(), now, limit: 1).first), '08:12');
    });

    test('haftalık kural sadece seçili günlerde çalar', () {
      // Sadece pazartesi (1). 2026-09-28 pazartesi.
      final r = rule(recurrence: const Weekly({DateTime.monday}));
      final now = DateTime(2026, 9, 28, 9, 0); // pazartesi, pencere bitti
      final next = nextOccurrences(r, now, limit: 1).first;

      expect(next.weekday, DateTime.monday);
      expect(next, DateTime(2026, 10, 5, 8, 0), reason: 'sonraki pazartesi');
    });

    test('haftalık kural birden çok gün', () {
      final r = rule(
        recurrence: const Weekly({DateTime.monday, DateTime.wednesday}),
      );
      final now = DateTime(2026, 9, 28, 9, 0); // pazartesi geçti
      final next = nextOccurrences(r, now, limit: 1).first;

      expect(next, DateTime(2026, 9, 30, 8, 0), reason: 'çarşamba');
    });

    test('tek seferlik kural sadece bir pencere üretir', () {
      final now = DateTime(2026, 9, 28, 9, 0); // bugünün penceresi bitti
      final next = nextOccurrences(rule(), now, limit: 50);

      expect(next.length, 11, reason: 'yarının tek penceresi, fazlası değil');
      expect(next.first, DateTime(2026, 9, 29, 8, 0));
    });

    test('devre dışı kural alarm üretmez', () {
      final now = DateTime(2026, 9, 28, 7, 0);
      expect(nextOccurrences(rule(enabled: false), now), isEmpty);
    });

    test('gece yarısını aşan pencerede dünden gelen alarmlar yakalanır', () {
      final r = rule(
        start: 23 * 60 + 50,
        end: 10,
        interval: 5,
        recurrence: const Weekly({DateTime.monday}),
      );
      // Salı 00:02 — pencere pazartesi 23:50'de başladı, hâlâ sürüyor.
      final now = DateTime(2026, 9, 29, 0, 2);
      final next = nextOccurrences(r, now, limit: 2).map(hhmm).toList();

      expect(next.first, '00:05', reason: 'dün başlayan pencere devam ediyor');
    });

    test('sonuçlar artan sırada', () {
      final r = rule(recurrence: const Weekly({DateTime.monday, DateTime.friday}));
      final list = nextOccurrences(r, DateTime(2026, 9, 28, 7, 0), limit: 20);

      for (var i = 1; i < list.length; i++) {
        expect(list[i].isAfter(list[i - 1]), isTrue);
      }
    });
  });

  group('tek alarm', () {
    IntervalRule single({int at = 7 * 60 + 30}) => IntervalRule(
          id: 'tek',
          label: 'kalk',
          startMinute: at,
          endMinute: at,
          intervalMinutes: 1,
          recurrence: const OneShot(),
        );

    test('baslangic ve bitis ayniysa tek alarm uretir', () {
      final r = single();
      expect(r.isSingle, isTrue);
      expect(r.occurrenceCount, 1);
      expect(r.windowLengthMinutes, 0);
    });

    test('uretilen tek zaman dogru saatte', () {
      final times = occurrencesOnDay(single(), DateTime(2026, 9, 28));
      expect(times, [DateTime(2026, 9, 28, 7, 30)]);
    });

    test('araliklı kural tek alarm sayilmaz', () {
      final r = IntervalRule(
        id: 'a',
        label: '',
        startMinute: 8 * 60,
        endMinute: 8 * 60 + 20,
        intervalMinutes: 2,
        recurrence: const OneShot(),
      );
      expect(r.isSingle, isFalse);
    });

    test('haftalik tek alarm secili gunlerde calar', () {
      final r = IntervalRule(
        id: 'tek',
        label: '',
        startMinute: 7 * 60 + 30,
        endMinute: 7 * 60 + 30,
        intervalMinutes: 1,
        recurrence: const Weekly({DateTime.monday, DateTime.friday}),
      );
      final next = nextOccurrences(r, DateTime(2026, 9, 28, 8, 0), limit: 3);

      expect(next.length, 3);
      expect(next[0], DateTime(2026, 10, 2, 7, 30), reason: 'cuma');
      expect(next[1], DateTime(2026, 10, 5, 7, 30), reason: 'pazartesi');
      expect(next.every((d) => d.hour == 7 && d.minute == 30), isTrue);
    });
  });
}
