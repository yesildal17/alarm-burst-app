import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('alarmburst/native');

/// Alarm çalma servisinin gerçekten ayakta olup olmadığını sorar.
///
/// Eklentinin alarm kaydı susturulana kadar `triggered` durumunda kalıyor;
/// tek başına ona bakmak, sesi çoktan susmuş bir alarm için de ekran
/// açılmasına yol açıyordu.
Future<bool> isAlarmServiceRunning() async {
  if (kIsWeb) return false;
  try {
    return await _channel.invokeMethod<bool>('isAlarmRinging') ?? false;
  } on PlatformException {
    return true;
  } on MissingPluginException {
    return true;
  }
}
