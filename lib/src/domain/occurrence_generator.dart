import 'interval_rule.dart';

/// Bir kuralın tek bir gün için ürettiği alarm zamanları.
///
/// [day] penceresinin *başladığı* gündür. Gece yarısını aşan pencerelerde
/// (23:50 → 00:10) son alarmlar ertesi güne düşer, ama pencere hâlâ [day]'e aittir.
List<DateTime> occurrencesOnDay(IntervalRule rule, DateTime day) {
  if (rule.intervalMinutes <= 0) return const [];

  final result = <DateTime>[];
  for (var k = 0; k < rule.occurrenceCount; k++) {
    final total = rule.startMinute + k * rule.intervalMinutes;
    final dayOffset = total ~/ Duration.minutesPerDay;
    final inDay = total % Duration.minutesPerDay;
    // Duration eklemek yerine kurucuyu kullanmak kritik: yaz saati geçişinde
    // Duration bir saat kaydırır, kurucu duvar saatini korur. Gün taşması
    // (32. gün) DateTime tarafından kendiliğinden normalize edilir.
    result.add(
      DateTime(day.year, day.month, day.day + dayOffset, inDay ~/ 60, inDay % 60),
    );
  }
  return result;
}

/// Kuralın [from] anından *sonraki* ilk [limit] alarm zamanını üretir.
///
/// İşletim sistemine tüm gelecek alarmları kaydetmiyoruz: iOS'ta AlarmKit'in
/// uygulama başına açıklanmamış bir limiti var ve aşılınca hata dönüyor.
/// Bunun yerine en yakın [limit] alarmı kurup, her alarm çaldıkça pencereyi
/// ileri kaydırıyoruz.
List<DateTime> nextOccurrences(
  IntervalRule rule,
  DateTime from, {
  int limit = 20,
  int searchDayLimit = 400,
}) {
  if (!rule.isEnabled || rule.intervalMinutes <= 0 || limit <= 0) {
    return const [];
  }

  final result = <DateTime>[];
  // Dünden başlıyoruz: gece yarısını aşan bir pencere dün başlamış olsa bile
  // bugüne düşen alarmları hâlâ üretebilir.
  var day = DateTime(from.year, from.month, from.day - 1);

  for (var i = 0; i < searchDayLimit && result.length < limit; i++) {
    if (_appliesOn(rule, day)) {
      for (final t in occurrencesOnDay(rule, day)) {
        if (t.isAfter(from)) {
          result.add(t);
          if (result.length == limit) break;
        }
      }
      // Tek seferlik kural: ilk uygun pencere bulunduysa daha ileriye bakmıyoruz.
      if (rule.recurrence is OneShot && result.isNotEmpty) break;
    }
    day = DateTime(day.year, day.month, day.day + 1);
  }

  return result;
}

bool _appliesOn(IntervalRule rule, DateTime day) {
  return switch (rule.recurrence) {
    OneShot() => true,
    Weekly(weekdays: final days) => days.contains(day.weekday),
  };
}
