import 'package:alarm_burst/src/scheduler/alarm_sink.dart';

/// Gerçek alarm kurmadan zamanlayıcı mantığını sınamak için.
class FakeAlarmSink implements AlarmSink {
  final Map<String, DateTime> scheduled = {};
  final List<String> cancelled = [];

  /// Bu sayıdan sonraki her kurma denemesi limit hatası atar.
  /// iOS'taki AlarmKit limitini taklit ediyor.
  int? failAfter;

  /// Son kurulan alarmda kullanılan ses ve titreşim ayarı.
  String lastSoundUri = '';
  bool lastVibrate = true;

  @override
  Future<void> schedule({
    required String id,
    required DateTime at,
    required String label,
    String soundUri = '',
    bool vibrate = true,
  }) async {
    lastSoundUri = soundUri;
    lastVibrate = vibrate;
    if (failAfter != null && scheduled.length >= failAfter!) {
      throw AlarmLimitReachedException(scheduled.length);
    }
    scheduled[id] = at;
  }

  @override
  Future<void> cancel(String id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<AlarmPermissions> permissions() async =>
      const AlarmPermissions.allGranted();

  @override
  Future<AlarmPermissions> requestPermissions() async =>
      const AlarmPermissions.allGranted();
}
