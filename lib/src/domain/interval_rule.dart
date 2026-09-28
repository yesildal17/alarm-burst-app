import 'package:flutter/foundation.dart';

/// Kuralın hangi günlerde geçerli olduğunu belirler.
sealed class Recurrence {
  const Recurrence();
}

/// Tek seferlik: sonraki ilk uygun pencerede bir kez çalar, sonra devre dışı kalır.
final class OneShot extends Recurrence {
  const OneShot();
}

/// Haftalık tekrar. Değerler DateTime.monday (1) .. DateTime.sunday (7).
final class Weekly extends Recurrence {
  const Weekly(this.weekdays);

  final Set<int> weekdays;
}

/// Bir alarm serisinin kuralı: "08:00 ile 08:20 arası 2 dakikada bir".
///
/// Saatler gün başından itibaren dakika olarak tutulur. Bunun sebebi yaz saati
/// geçişleri: kullanıcı 08:00 dediyse, saat ileri/geri alınsa da alarm duvar
/// saatinde 08:00'de çalmalı. Mutlak zaman tutulsaydı bir saat kayardı.
@immutable
class IntervalRule {
  const IntervalRule({
    required this.id,
    required this.label,
    required this.startMinute,
    required this.endMinute,
    required this.intervalMinutes,
    required this.recurrence,
    this.isEnabled = true,
  });

  final String id;
  final String label;

  /// Gün başından itibaren dakika, 0-1439.
  final int startMinute;

  /// Gün başından itibaren dakika, 0-1439.
  /// [startMinute]'dan küçükse pencere gece yarısını aşıp ertesi güne taşar.
  final int endMinute;

  final int intervalMinutes;
  final Recurrence recurrence;
  final bool isEnabled;

  /// Pencerenin dakika cinsinden uzunluğu.
  /// 23:50 → 00:10 gibi gece yarısını aşan pencereleri de doğru hesaplar.
  int get windowLengthMinutes {
    final raw = endMinute - startMinute;
    return raw >= 0 ? raw : raw + Duration.minutesPerDay;
  }

  /// Bu kuralın bir pencerede ürettiği alarm sayısı. İki uç da dahil:
  /// 08:00–08:20 / 2 dk → 11 alarm.
  int get occurrenceCount {
    if (intervalMinutes <= 0) return 0;
    return windowLengthMinutes ~/ intervalMinutes + 1;
  }

  /// Tek bir alarm mı? Başlangıç ve bitiş aynıysa kural tek alarm üretir.
  bool get isSingle => startMinute == endMinute;

  /// Pencere gece yarısını aşıyor mu?
  bool get crossesMidnight => endMinute < startMinute;

  IntervalRule copyWith({
    String? id,
    String? label,
    int? startMinute,
    int? endMinute,
    int? intervalMinutes,
    Recurrence? recurrence,
    bool? isEnabled,
  }) {
    return IntervalRule(
      id: id ?? this.id,
      label: label ?? this.label,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      recurrence: recurrence ?? this.recurrence,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
