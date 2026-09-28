import 'package:alarm_plus/alarm_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/data/rule_mapper.dart';
import 'src/platform/alarm_service_probe.dart';
import 'src/features/ringing/ringing_page.dart';
import 'src/features/ringing/ringing_state.dart';
import 'src/features/settings/settings_state.dart';
import 'src/features/shell/app_shell.dart';
import 'src/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dünya saati için saat dilimi veritabanı.
  tzdata.initializeTimeZones();

  if (!kIsWeb) {
    await AlarmPlus.initialize();
  }

  runApp(const ProviderScope(child: IntervalAlarmApp()));
}

class IntervalAlarmApp extends ConsumerWidget {
  const IntervalAlarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider).themeMode;

    return MaterialApp(
      title: 'Alarm Burst',
      debugShowCheckedModeBanner: false,
      // Bunlar olmadan Flutter'ın hazır bileşenleri (saat seçici, kaydırarak
      // silme, tarih adları) İngilizce çıkıyor.
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3D5AFE),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF3D5AFE),
        brightness: Brightness.dark,
      ),
      themeMode: themeMode,
      home: const _AlarmHost(),
    );
  }
}

/// Alarm olaylarını dinler ve çalan alarm varsa her şeyin üstünde gösterir.
class _AlarmHost extends ConsumerStatefulWidget {
  const _AlarmHost();

  @override
  ConsumerState<_AlarmHost> createState() => _AlarmHostState();
}

class _AlarmHostState extends ConsumerState<_AlarmHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;

    WidgetsBinding.instance.addObserver(this);
    AlarmPlus.events.listen(_onEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _syncRingingState();
      await _reconcile();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Alarm çalınca tam ekran intent uygulamayı öne getiriyor. Uygulama zaten
    // çalışıyorsa initState bir daha işlemiyor ve olay akışı donmuş süreçte
    // kaçabiliyor; öne gelindiğinde durumu yeniden okumak şart.
    if (state == AppLifecycleState.resumed && !kIsWeb) {
      _syncRingingState();
    }
  }

  /// Şu anda çalan bir alarm var mı diye eklentiye sorar.
  Future<void> _syncRingingState() async {
    // Once servise sor: alarm kaydi susturulana kadar "triggered" kaldigi
    // icin tek basina ona guvenmek, sesi susmus alarmlar icin de ekran
    // aciyordu.
    final actuallyRinging = await isAlarmServiceRunning();

    final ringing = !actuallyRinging
        ? null
        : RingingAlarm.fromModelIfRinging(await AlarmPlus.getLaunchAlarm()) ??
            RingingAlarm.pickRinging(await AlarmPlus.getAll());

    if (!mounted) return;
    final notifier = ref.read(ringingAlarmProvider.notifier);

    if (ringing != null) {
      notifier.show(ringing);
    } else if (ref.read(ringingAlarmProvider) != null) {
      // Alarm dışarıdan susturulmuş (bildirimdeki Kapat düğmesi gibi);
      // ekranı açık bırakmamalıyız.
      notifier.clear();
    }
  }

  Future<void> _onEvent(AlarmEvent event) async {
    switch (event.type) {
      case 'triggered':
        final ringing = RingingAlarm.fromModel(event.alarm);
        if (ringing != null && mounted) {
          ref.read(ringingAlarmProvider.notifier).show(ringing);
        }
        final id = event.id;
        if (id != null) {
          await ref.read(syncServiceProvider).handleRang(id);
        }
      case 'stopped':
        if (mounted) ref.read(ringingAlarmProvider.notifier).clear();
    }
  }

  /// Uygulama kapalıyken çalan alarmları telafi eder.
  ///
  /// `events` yalnızca uygulama çalışırken olay veriyor; bu olmadan kurulu
  /// alarmlar tükenir ve kural sessizce durur — alarm uygulamasında en kötü
  /// hata türü, çünkü kullanıcı ancak uyanamadığında fark eder.
  Future<void> _reconcile() async {
    final db = ref.read(databaseProvider);
    final sync = ref.read(syncServiceProvider);
    final now = DateTime.now();

    for (final row in await db.allRules()) {
      final rule = ruleFromRow(row);
      if (!rule.isEnabled) continue;

      final stale = await db.pendingAlarmsBefore(rule.id, now);
      for (final a in stale) {
        await db.markAlarmRang(a.id, a.fireAt);
      }
      await sync.topUp(rule, now: now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ringing = ref.watch(ringingAlarmProvider);
    if (ringing != null) return RingingPage(alarm: ringing);
    return const AppShell();
  }
}
