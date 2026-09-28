import 'package:alarm_plus/alarm_plus.dart';
import 'package:flutter/services.dart';

import 'alarm_sink.dart';

/// [AlarmSink]'in alarm_plus üzerindeki gerçek uygulaması.
///
/// Android'de `AlarmManager.setExactAndAllowWhileIdle` + ön plan servisi,
/// iOS 26+'da AlarmKit kullanılır.
class AlarmPlusSink implements AlarmSink {
  const AlarmPlusSink();

  @override
  Future<void> schedule({
    required String id,
    required DateTime at,
    required String label,
    String soundUri = '',
    bool vibrate = true,
  }) async {
    try {
      await AlarmPlus.schedule(
        id: id,
        time: at,
        data: {'label': label},
        notificationSettings: AlarmNotificationSettings(
          title: label.isEmpty ? 'Alarm' : label,
          body: _formatTime(at),
          stopButtonText: 'Kapat',
          snoozeButtonText: 'Ertele',
          // Boş bırakılırsa eklenti telefonun varsayılan alarm sesine düşüyor.
          soundAsset: soundUri.isEmpty ? null : soundUri,
          vibrationSettings: VibrationSettings(
            enabled: vibrate,
            preset: VibrationPreset.strong,
          ),
        ),
      );
    } on PlatformException catch (e) {
      // AlarmKit limiti bu yolla geliyor; çağıran pencereyi daraltabilsin diye
      // ayrı bir istisnaya çeviriyoruz.
      if (_isLimitError(e)) {
        throw const AlarmLimitReachedException(-1);
      }
      rethrow;
    }
  }

  @override
  Future<void> cancel(String id) => AlarmPlus.cancel(id);

  @override
  Future<AlarmPermissions> permissions() async {
    return _map(await AlarmPlus.getPermissionStatus());
  }

  @override
  Future<AlarmPermissions> requestPermissions() async {
    return _map(await AlarmPlus.requestPermissions());
  }

  AlarmPermissions _map(AlarmPermissionStatus s) => AlarmPermissions(
        notifications: s.notificationsGranted,
        exactAlarms: s.exactAlarmsGranted,
        fullScreenIntent: s.fullScreenIntentGranted,
      );

  bool _isLimitError(PlatformException e) {
    final haystack = '${e.code} ${e.message ?? ''}'.toLowerCase();
    return haystack.contains('maximumlimitreached') ||
        haystack.contains('limit');
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
