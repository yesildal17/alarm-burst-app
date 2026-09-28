import 'dart:convert';

import 'package:alarm_plus/alarm_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

/// Şu anda çalan alarm.
@immutable
class RingingAlarm {
  const RingingAlarm({
    required this.id,
    required this.label,
    required this.scheduledAt,
  });

  final String id;
  final String label;
  final DateTime scheduledAt;

  /// Bir alarmın "hâlâ çalıyor" sayılacağı en uzun süre.
  ///
  /// Eklenti alarmı susturulana kadar `triggered` durumunda tutuyor. Telefon
  /// kapalıyken geçen alarmlar veya uygulama yeniden kurulduğunda yeniden
  /// tetiklenen eski kayıtlar bu durumda kalıyor; bu sınır olmadan uygulama
  /// her açılışta sahte bir alarm ekranı gösteriyor.
  static const maxRingingAge = Duration(minutes: 15);

  /// Yalnızca gerçekten çalan bir alarm için nesne üretir.
  ///
  /// `getLaunchAlarm()` susturulmuş veya çok eski alarmları da döndürebiliyor;
  /// açılış yolunda bu kullanılmalı.
  static RingingAlarm? fromModelIfRinging(AlarmModel? m, {DateTime? now}) {
    if (m == null || m.status != 'triggered') return null;

    final alarm = fromModel(m);
    if (alarm == null) return null;

    final age = (now ?? DateTime.now()).difference(alarm.scheduledAt);
    if (age > maxRingingAge) return null;

    return alarm;
  }

  /// Bir alarm listesindeki gerçekten çalan alarmı seçer.
  ///
  /// Uygulama alarm bildirimiyle öne getirildiğinde hangi alarmın çaldığını
  /// bu yolla buluyoruz; `getLaunchAlarm()` yalnızca uygulama o an
  /// başlatıldığında sonuç veriyor.
  static RingingAlarm? pickRinging(List<AlarmModel> all, {DateTime? now}) {
    for (final m in all) {
      final a = fromModelIfRinging(m, now: now);
      if (a != null) return a;
    }
    return null;
  }

  /// Eklentinin alarm modelinden üretir; etiket `data` içindeki JSON'dan gelir.
  static RingingAlarm? fromModel(AlarmModel? m) {
    if (m == null) return null;

    var label = '';
    final raw = m.payloadJson;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['label'] is String) {
          label = decoded['label'] as String;
        }
      } on FormatException {
        // Etiket süs; okunamazsa alarm yine de gösterilmeli.
      }
    }

    return RingingAlarm(
      id: m.id,
      label: label,
      scheduledAt:
          DateTime.fromMillisecondsSinceEpoch(m.scheduledTimeUtcMs, isUtc: true)
              .toLocal(),
    );
  }
}

/// Çalan alarmı tutar. Boş olması "alarm çalmıyor" demektir.
class RingingNotifier extends Notifier<RingingAlarm?> {
  @override
  RingingAlarm? build() => null;

  void show(RingingAlarm alarm) => state = alarm;

  void clear() => state = null;

  /// Alarmı susturur. Kayan pencerenin ilerlemesi ayrıca `events` akışındaki
  /// `triggered` olayıyla yürüyor, burada tekrar tetiklemiyoruz.
  Future<void> stop() async {
    state = null;
    if (!kIsWeb) await AlarmPlus.stop();
  }

  Future<void> snooze(int minutes) async {
    final current = state;
    state = null;
    if (current == null || kIsWeb) return;

    await AlarmPlus.snooze(current.id, minutes);
    // Kendi tablomuza da yazıyoruz; kural kapatılırsa iptal edebilelim.
    await ref.read(syncServiceProvider).recordSnooze(current.id, minutes);
  }
}

final ringingAlarmProvider =
    NotifierProvider<RingingNotifier, RingingAlarm?>(RingingNotifier.new);
