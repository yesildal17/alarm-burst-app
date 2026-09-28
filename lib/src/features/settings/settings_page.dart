import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/ringtone_picker.dart';
import '../../platform/widget_pin.dart';
import 'settings_state.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        children: [
          const _SectionHeader('Görünüm'),
          RadioGroup<ThemeMode>(
            groupValue: s.themeMode,
            onChanged: (m) => m == null ? null : notifier.setThemeMode(m),
            child: const Column(
              children: [
                RadioListTile(
                    value: ThemeMode.system, title: Text('Sistem ayarını kullan')),
                RadioListTile(value: ThemeMode.light, title: Text('Açık')),
                RadioListTile(value: ThemeMode.dark, title: Text('Karanlık')),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader('Ana ekran'),
          ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: const Text('Ana ekrana widget ekle'),
            subtitle: const Text('Saat ve sıradaki alarm'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              if (await WidgetPin.isAdded()) {
                messenger.showSnackBar(const SnackBar(
                  content: Text('Widget zaten ana ekranda.'),
                ));
                return;
              }
              final ok = await WidgetPin.request();
              if (!ok) {
                messenger.showSnackBar(const SnackBar(
                  content: Text(
                    'Başlatıcın bu özelliği desteklemiyor. Ana ekranda boş bir '
                    'yere uzun basıp Widget\'lar arasından ekleyebilirsin.',
                  ),
                ));
              }
            },
          ),
          const Divider(),
          const _SectionHeader('Alarm'),
          ListTile(
            leading: const Icon(Icons.music_note_outlined),
            title: const Text('Alarm sesi'),
            subtitle: Text(s.soundLabel),
            onTap: () async {
              final picked = await pickRingtone(current: s.soundUri);
              if (picked != null) {
                await notifier.setSound(picked.uri, picked.title);
              }
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text('Titreşim'),
            subtitle: const Text('Alarm çalarken telefon titresin'),
            value: s.vibrate,
            onChanged: notifier.setVibrate,
          ),
          ListTile(
            leading: const Icon(Icons.snooze),
            title: const Text('Erteleme süresi'),
            subtitle: Text('${s.snoozeMinutes} dakika'),
            onTap: () async {
              final picked = await showDialog<int>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: const Text('Erteleme süresi'),
                  children: [
                    for (final m in [1, 3, 5, 10, 15, 20])
                      SimpleDialogOption(
                        onPressed: () => Navigator.pop(context, m),
                        child: Text('$m dakika'),
                      ),
                  ],
                ),
              );
              if (picked != null) await notifier.setSnoozeMinutes(picked);
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
