/// İşletim sistemine alarm kuran katmanın soyutlaması.
///
/// Soyutlamanın iki somut faydası var: kayan pencere mantığını gerçek alarm
/// kurmadan test edebiliyoruz, ve web'de (alarm desteği olmayan hedefte)
/// arayüzü çalıştırabiliyoruz.
abstract interface class AlarmSink {
  Future<void> schedule({
    required String id,
    required DateTime at,
    required String label,
    String soundUri = '',
    bool vibrate = true,
  });

  Future<void> cancel(String id);

  Future<AlarmPermissions> permissions();

  Future<AlarmPermissions> requestPermissions();
}

/// Alarm kurmak için gereken izinlerin durumu.
class AlarmPermissions {
  const AlarmPermissions({
    required this.notifications,
    required this.exactAlarms,
    required this.fullScreenIntent,
  });

  const AlarmPermissions.allGranted()
      : notifications = true,
        exactAlarms = true,
        fullScreenIntent = true;

  /// Android'de bildirim izni; iOS 26+'da AlarmKit yetkilendirmesi.
  final bool notifications;

  /// Android 12+ kesin alarm izni. Bu olmadan alarmlar gecikebilir.
  final bool exactAlarms;

  /// Android 14+ kilit ekranında tam ekran alarm gösterme izni.
  final bool fullScreenIntent;

  /// Alarm kurmak için yeterli mi? Tam ekran intent olmadan alarm çalar ama
  /// kilit ekranında tam ekran açılmaz, o yüzden zorunlu saymıyoruz.
  bool get canSchedule => notifications && exactAlarms;

  List<String> get missing => [
        if (!notifications) 'bildirim',
        if (!exactAlarms) 'kesin alarm',
        if (!fullScreenIntent) 'tam ekran',
      ];
}

/// İşletim sistemi alarm limitine ulaşıldığında atılır.
///
/// iOS'ta AlarmKit'in uygulama başına açıklanmamış bir limiti var; aşılınca
/// `maximumLimitReached` döner. Kayan pencereyi daraltarak tepki veriyoruz.
class AlarmLimitReachedException implements Exception {
  const AlarmLimitReachedException(this.scheduledCount);

  final int scheduledCount;

  @override
  String toString() =>
      'İşletim sistemi alarm limitine ulaşıldı ($scheduledCount alarm kurulmuştu)';
}
