import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../platform/widget_pin.dart';
import '../settings/settings_state.dart';

import '../rules/rule_list_page.dart';
import '../settings/settings_page.dart';
import '../stopwatch/stopwatch_page.dart';
import '../timer/timer_page.dart';
import '../worldclock/world_clock_page.dart';

/// Stok saat uygulamalarındaki alt sekme düzeni.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _offerWidgetOnce());
  }

  /// İlk açılışta ana ekran widget'ını bir kez teklif eder.
  ///
  /// Android uygulamaların ana ekrana kendiliğinden widget koymasına izin
  /// vermiyor; sistemin onay diyaloğunu açmak yapılabilecek tek şey.
  Future<void> _offerWidgetOnce() async {
    final settings = ref.read(settingsProvider);
    if (settings.widgetPromptShown) return;
    if (!await WidgetPin.isSupported()) return;
    if (await WidgetPin.isAdded()) {
      await ref.read(settingsProvider.notifier).markWidgetPromptShown();
      return;
    }
    if (!mounted) return;

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.widgets_outlined),
        title: const Text('Ana ekrana ekleyelim mi?'),
        content: const Text(
          'Saati ve sıradaki alarmı ana ekranından görebilirsin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Şimdi değil'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    await ref.read(settingsProvider.notifier).markWidgetPromptShown();
    if (accepted == true) await WidgetPin.request();
  }

  static const _titles = ['Alarm', 'Dünya saati', 'Zamanlayıcı', 'Kronometre'];

  @override
  Widget build(BuildContext context) {
    // Alarm sekmesi kendi Scaffold'unu kuruyor (büyük başlık ve FAB'i var);
    // diğerleri ortak başlığı kullanıyor.
    final body = switch (_index) {
      0 => const RuleListPage(),
      1 => const WorldClockPage(),
      2 => const TimerPage(),
      _ => const StopwatchPage(),
    };

    return Scaffold(
      appBar: _index == 0
          ? null
          : AppBar(
              title: Text(_titles[_index]),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  ),
                ),
              ],
            ),
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Alarm',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Dünya',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty),
            selectedIcon: Icon(Icons.hourglass_full),
            label: 'Zamanlayıcı',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Kronometre',
          ),
        ],
      ),
    );
  }
}
