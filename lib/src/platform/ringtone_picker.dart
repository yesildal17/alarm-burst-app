import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Kullanıcının seçtiği zil sesi.
@immutable
class PickedRingtone {
  const PickedRingtone({required this.uri, required this.title});

  /// Boş dize telefonun varsayılan alarm sesi demektir.
  final String uri;
  final String title;
}

const _channel = MethodChannel('alarmburst/native');

/// Sistemin zil sesi seçicisini açar.
///
/// Kendi ses listemizi paketlemek yerine sistemi kullanıyoruz: kullanıcı
/// telefonunda zaten tanıdığı seslerden seçiyor.
Future<PickedRingtone?> pickRingtone({String current = ''}) async {
  if (kIsWeb) return null;
  try {
    final result = await _channel.invokeMapMethod<String, String>(
      'pick',
      {'current': current},
    );
    if (result == null) return null;
    return PickedRingtone(
      uri: result['uri'] ?? '',
      title: result['title'] ?? 'Telefonun alarm sesi',
    );
  } on PlatformException {
    return null;
  } on MissingPluginException {
    return null;
  }
}
