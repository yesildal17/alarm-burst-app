import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ringing_state.dart';

/// Varsayılan erteleme süresi; eklentinin kendi varsayılanıyla aynı.
const _snoozeMinutes = 5;

/// Alarm çalarken tam ekran açılan sayfa.
///
/// Stok saat uygulamalarının alarm ekranını taklit ediyor: büyük saat,
/// altında etiket, altta iki büyük eylem. Kilit ekranının üstünde açıldığı
/// için (MainActivity'de setShowWhenLocked) tanıdık ve doğrudan olmalı.
class RingingPage extends ConsumerStatefulWidget {
  const RingingPage({super.key, required this.alarm});

  final RingingAlarm alarm;

  @override
  ConsumerState<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends ConsumerState<RingingPage> {
  late Timer _clock;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    // Alarm ekranında durum çubuğu dikkat dağıtıyor; stok uygulamalar da
    // burada tam ekrana geçiyor.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _clock.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String get _time =>
      '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}';

  String get _dateLine {
    const days = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
    ];
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return '${days[_now.weekday - 1]}, ${_now.day} ${months[_now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      // Geri tuşuyla alarmdan kaçılmamalı; susturmak için açık bir eylem şart.
      canPop: false,
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Icon(Icons.alarm, size: 48, color: scheme.primary),
                const SizedBox(height: 24),
                Text(
                  _time,
                  style: TextStyle(
                    fontSize: 88,
                    fontWeight: FontWeight.w200,
                    height: 1,
                    color: scheme.onSurface,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _dateLine,
                  style: TextStyle(
                    fontSize: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (widget.alarm.label.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    widget.alarm.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
                const Spacer(flex: 3),
                Row(
                  children: [
                    Expanded(
                      child: _RingAction(
                        icon: Icons.snooze,
                        label: '$_snoozeMinutes dk ertele',
                        filled: false,
                        onTap: () =>
                            ref.read(ringingAlarmProvider.notifier)
                                .snooze(_snoozeMinutes),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RingAction(
                        icon: Icons.alarm_off,
                        label: 'Kapat',
                        filled: true,
                        onTap: () =>
                            ref.read(ringingAlarmProvider.notifier).stop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingAction extends StatelessWidget {
  const _RingAction({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = filled ? scheme.primary : scheme.surfaceContainerHighest;
    final fg = filled ? scheme.onPrimary : scheme.onSurface;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: fg, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: fg, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
