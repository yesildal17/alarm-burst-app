import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('alarmburst/native');

/// Ana ekrana widget ekleme akışı.
///
/// Android uygulamaların ana ekrana kendiliğinden widget koymasına izin
/// vermiyor — izin verilseydi her uygulama ana ekranı doldururdu. Yapılabilecek
/// tek şey sistemin "bu widget'ı ekleyeyim mi?" diyaloğunu açmak.
class WidgetPin {
  const WidgetPin._();

  /// Başlatıcı bu diyaloğu destekliyor mu?
  static Future<bool> isSupported() => _call('canPinWidget');

  /// Ana ekranda zaten bir widget var mı?
  static Future<bool> isAdded() => _call('isWidgetAdded');

  /// Sistem diyaloğunu açar. Kullanıcının onaylayıp onaylamadığını
  /// öğrenemiyoruz; dönen değer yalnızca isteğin iletilip iletilmediği.
  static Future<bool> request() => _call('requestPinWidget');

  static Future<bool> _call(String method) async {
    if (kIsWeb) return false;
    try {
      return await _channel.invokeMethod<bool>(method) ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
