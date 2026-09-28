import 'dart:async';

import 'package:flutter/material.dart';

/// Hazır süreler; stok zamanlayıcılardaki gibi tek dokunuşla kurulur.
const _presets = [1, 3, 5, 10, 15, 30];

String formatRemaining(Duration d) {
  final total = d.isNegative ? Duration.zero : d;
  final h = total.inHours;
  final m = total.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = total.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Duration _total = const Duration(minutes: 5);
  Duration _remaining = const Duration(minutes: 5);
  Timer? _ticker;
  bool _running = false;
  bool _finished = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _setTotal(Duration d) {
    setState(() {
      _ticker?.cancel();
      _running = false;
      _finished = false;
      _total = d;
      _remaining = d;
    });
  }

  void _toggle() {
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
      return;
    }
    if (_remaining <= Duration.zero) return;

    setState(() {
      _running = true;
      _finished = false;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining <= Duration.zero) {
          _remaining = Duration.zero;
          _running = false;
          _finished = true;
          _ticker?.cancel();
        }
      });
    });
  }

  void _reset() {
    setState(() {
      _ticker?.cancel();
      _running = false;
      _finished = false;
      _remaining = _total;
    });
  }

  Future<void> _pickCustom() async {
    final picked = await showDialog<Duration>(
      context: context,
      builder: (_) => const _DurationDialog(),
    );
    if (picked != null && picked > Duration.zero) _setTotal(picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = _total.inSeconds == 0
        ? 0.0
        : _remaining.inSeconds / _total.inSeconds;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: scheme.surfaceContainerHighest,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatRemaining(_remaining),
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -1,
                        color: scheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (_finished)
                      Text('Süre doldu',
                          style: TextStyle(color: scheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final m in _presets)
                ChoiceChip(
                  label: Text('$m dk'),
                  selected: _total == Duration(minutes: m),
                  onSelected: (_) => _setTotal(Duration(minutes: m)),
                ),
              ActionChip(
                avatar: const Icon(Icons.edit, size: 18),
                label: const Text('Özel'),
                onPressed: _pickCustom,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: _remaining == _total && !_running ? null : _reset,
                child: const Text('Sıfırla'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _remaining > Duration.zero ? _toggle : null,
                child: Text(_running ? 'Duraklat' : 'Başlat'),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DurationDialog extends StatefulWidget {
  const _DurationDialog();

  @override
  State<_DurationDialog> createState() => _DurationDialogState();
}

class _DurationDialogState extends State<_DurationDialog> {
  int _hours = 0;
  int _minutes = 5;
  int _seconds = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Süre seç'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Spinner(
            label: 'saat',
            value: _hours,
            max: 23,
            onChanged: (v) => setState(() => _hours = v),
          ),
          _Spinner(
            label: 'dakika',
            value: _minutes,
            max: 59,
            onChanged: (v) => setState(() => _minutes = v),
          ),
          _Spinner(
            label: 'saniye',
            value: _seconds,
            max: 59,
            onChanged: (v) => setState(() => _seconds = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            Duration(hours: _hours, minutes: _minutes, seconds: _seconds),
          ),
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => onChanged(value >= max ? 0 : value + 1),
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          Text(value.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 24)),
          IconButton(
            onPressed: () => onChanged(value <= 0 ? max : value - 1),
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
