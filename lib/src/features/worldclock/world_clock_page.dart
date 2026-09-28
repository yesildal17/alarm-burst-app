import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// Seçili şehirler; sadece saat dilimi adları tutuluyor.
class WorldClockNotifier extends Notifier<List<String>> {
  static const _key = 'world_clock_zones';

  @override
  List<String> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getStringList(_key) ?? const [];
  }

  Future<void> add(String zone) async {
    if (state.contains(zone)) return;
    state = [...state, zone];
    (await SharedPreferences.getInstance()).setStringList(_key, state);
  }

  Future<void> remove(String zone) async {
    state = state.where((z) => z != zone).toList();
    (await SharedPreferences.getInstance()).setStringList(_key, state);
  }
}

final worldClockProvider =
    NotifierProvider<WorldClockNotifier, List<String>>(WorldClockNotifier.new);

/// Saat dilimi adından okunabilir şehir adı: "Europe/Istanbul" → "Istanbul".
String cityOf(String zone) => zone.split('/').last.replaceAll('_', ' ');

/// Saat farkını okunabilir metne çevirir: "+2 saat", "-5,5 saat", "Aynı saat".
///
/// Saat dilimi hesabından ayrı duruyor ki sistem saat diliminden bağımsız
/// olarak test edilebilsin.
String formatOffset(Duration diff) {
  if (diff == Duration.zero) return 'Aynı saat';

  final sign = diff.isNegative ? '-' : '+';
  final abs = diff.abs();
  final h = abs.inHours;
  final m = abs.inMinutes.remainder(60);
  final hours = m == 0 ? '$h' : '$h,${(m / 60 * 10).round()}';
  return '$sign$hours saat';
}

/// Yerel saate göre fark metni.
String offsetLabel(tz.Location loc, DateTime now) {
  final there = tz.TZDateTime.from(now, loc);
  return formatOffset(there.timeZoneOffset - now.timeZoneOffset);
}

class WorldClockPage extends ConsumerStatefulWidget {
  const WorldClockPage({super.key});

  @override
  ConsumerState<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends ConsumerState<WorldClockPage> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _addCity() async {
    final zone = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CityPicker(),
    );
    if (zone != null) await ref.read(worldClockProvider.notifier).add(zone);
  }

  @override
  Widget build(BuildContext context) {
    final zones = ref.watch(worldClockProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                Text(
                  '${_now.hour.toString().padLeft(2, '0')}:'
                  '${_now.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w200,
                    letterSpacing: -2,
                    height: 1,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Bulunduğun yer',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: zones.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Şehir eklemek için + düğmesine dokun.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: zones.length,
                    itemBuilder: (context, i) {
                      final zone = zones[i];
                      final loc = tz.getLocation(zone);
                      final there = tz.TZDateTime.from(_now, loc);
                      final dayDiff = there.day != _now.day;

                      return Dismissible(
                        key: ValueKey(zone),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: scheme.errorContainer,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: Icon(Icons.delete_outline,
                              color: scheme.onErrorContainer),
                        ),
                        onDismissed: (_) =>
                            ref.read(worldClockProvider.notifier).remove(zone),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          title: Text(cityOf(zone),
                              style: const TextStyle(fontSize: 18)),
                          subtitle: Text(
                            '${offsetLabel(loc, _now)}'
                            '${dayDiff ? (there.isAfter(_now) ? ' · yarın' : ' · dün') : ''}',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          trailing: Text(
                            '${there.hour.toString().padLeft(2, '0')}:'
                            '${there.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w300,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCity,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CityPicker extends StatefulWidget {
  const _CityPicker();

  @override
  State<_CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<_CityPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Yalnızca şehir içeren bölgeler; "UTC", "GMT+3" gibi teknik girdiler
    // kullanıcıya bir şey ifade etmiyor.
    final zones = tz.timeZoneDatabase.locations.keys
        .where((z) => z.contains('/') && !z.startsWith('Etc/'))
        .where((z) => _query.isEmpty ||
            cityOf(z).toLowerCase().contains(_query.toLowerCase()))
        .toList()
      ..sort((a, b) => cityOf(a).compareTo(cityOf(b)));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Şehir ara',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: zones.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(cityOf(zones[i])),
                  subtitle: Text(zones[i].split('/').first),
                  onTap: () => Navigator.pop(context, zones[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
