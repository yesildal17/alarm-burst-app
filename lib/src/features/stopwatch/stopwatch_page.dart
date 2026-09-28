import 'dart:async';

import 'package:flutter/material.dart';

String formatElapsed(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  final cs = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s,$cs' : '$m:$s,$cs';
}

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});

  @override
  State<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  final _watch = Stopwatch();
  final _laps = <Duration>[];
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      if (_watch.isRunning) {
        _watch.stop();
        _ticker?.cancel();
      } else {
        _watch.start();
        // 30 ms: yüzde birlik hane akıcı görünsün, gereksiz kare çizilmesin.
        _ticker = Timer.periodic(
          const Duration(milliseconds: 30),
          (_) => setState(() {}),
        );
      }
    });
  }

  void _reset() {
    setState(() {
      _ticker?.cancel();
      _watch
        ..stop()
        ..reset();
      _laps.clear();
    });
  }

  void _lap() => setState(() => _laps.insert(0, _watch.elapsed));

  /// Turun kendi süresi: listedeki bir sonraki (daha eski) turdan farkı.
  Duration _lapDuration(int index) {
    final older = index + 1 < _laps.length ? _laps[index + 1] : Duration.zero;
    return _laps[index] - older;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final running = _watch.isRunning;
    final started = _watch.elapsed > Duration.zero;

    return Column(
      children: [
        const SizedBox(height: 48),
        Text(
          formatElapsed(_watch.elapsed),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w200,
            letterSpacing: -2,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundButton(
              label: started ? 'Sıfırla' : 'Tur',
              onTap: started ? _reset : null,
              tonal: true,
            ),
            const SizedBox(width: 40),
            _RoundButton(
              label: running ? 'Durdur' : (started ? 'Devam' : 'Başlat'),
              onTap: _toggle,
              tonal: false,
            ),
            const SizedBox(width: 40),
            _RoundButton(
              label: 'Tur',
              onTap: running ? _lap : null,
              tonal: true,
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(height: 1),
        Expanded(
          child: _laps.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  itemCount: _laps.length,
                  itemBuilder: (context, i) {
                    final no = _laps.length - i;
                    return ListTile(
                      dense: true,
                      leading: Text('Tur $no',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                      title: Text(
                        formatElapsed(_lapDuration(i)),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      trailing: SizedBox(
                        width: 100,
                        child: Text(
                          formatElapsed(_laps[i]),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.label,
    required this.onTap,
    required this.tonal,
  });

  final String label;
  final VoidCallback? onTap;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final bg = tonal ? scheme.surfaceContainerHighest : scheme.primary;
    final fg = tonal ? scheme.onSurface : scheme.onPrimary;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 84,
            height: 84,
            child: Center(
              child: Text(label, style: TextStyle(color: fg, fontSize: 15)),
            ),
          ),
        ),
      ),
    );
  }
}
