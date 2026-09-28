import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama ayarları. Basit anahtar-değer olduğu için veritabanı yerine
/// shared_preferences'ta tutuluyor.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.vibrate = true,
    this.soundUri = '',
    this.soundLabel = 'Telefonun alarm sesi',
    this.snoozeMinutes = 5,
    this.widgetPromptShown = false,
  });

  final ThemeMode themeMode;
  final bool vibrate;

  /// Boşsa telefonun varsayılan alarm sesi kullanılır.
  final String soundUri;
  final String soundLabel;
  final int snoozeMinutes;

  /// Ana ekran widget'ı teklifi bir kez gösterildi mi?
  final bool widgetPromptShown;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? vibrate,
    String? soundUri,
    String? soundLabel,
    int? snoozeMinutes,
    bool? widgetPromptShown,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      vibrate: vibrate ?? this.vibrate,
      soundUri: soundUri ?? this.soundUri,
      soundLabel: soundLabel ?? this.soundLabel,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      widgetPromptShown: widgetPromptShown ?? this.widgetPromptShown,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const _kTheme = 'theme_mode';
  static const _kVibrate = 'vibrate';
  static const _kSoundUri = 'sound_uri';
  static const _kSoundLabel = 'sound_label';
  static const _kSnooze = 'snooze_minutes';
  static const _kWidgetPrompt = 'widget_prompt_shown';

  @override
  AppSettings build() {
    _load();
    return const AppSettings();
  }

  Future<void> _load() async {
    // Ayarlar süs; okunamazsa varsayılanlarla devam etmek, uygulamayı
    // açılışta düşürmekten iyidir.
    final SharedPreferences p;
    try {
      p = await SharedPreferences.getInstance();
    } on Exception {
      return;
    }

    state = AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == (p.getString(_kTheme) ?? 'system'),
        orElse: () => ThemeMode.system,
      ),
      vibrate: p.getBool(_kVibrate) ?? true,
      soundUri: p.getString(_kSoundUri) ?? '',
      soundLabel: p.getString(_kSoundLabel) ?? 'Telefonun alarm sesi',
      snoozeMinutes: p.getInt(_kSnooze) ?? 5,
      widgetPromptShown: p.getBool(_kWidgetPrompt) ?? false,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    (await SharedPreferences.getInstance()).setString(_kTheme, mode.name);
  }

  Future<void> setVibrate(bool value) async {
    state = state.copyWith(vibrate: value);
    (await SharedPreferences.getInstance()).setBool(_kVibrate, value);
  }

  Future<void> setSound(String uri, String label) async {
    state = state.copyWith(soundUri: uri, soundLabel: label);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSoundUri, uri);
    await p.setString(_kSoundLabel, label);
  }

  Future<void> markWidgetPromptShown() async {
    state = state.copyWith(widgetPromptShown: true);
    (await SharedPreferences.getInstance()).setBool(_kWidgetPrompt, true);
  }

  Future<void> setSnoozeMinutes(int minutes) async {
    state = state.copyWith(snoozeMinutes: minutes);
    (await SharedPreferences.getInstance()).setInt(_kSnooze, minutes);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
