import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/interval_rule.dart';
import '../../providers.dart';
import '../settings/settings_page.dart';
import 'rule_edit_page.dart';

String formatMinute(int minute) {
  final h = (minute ~/ 60) % 24;
  final m = minute % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

const _dayLabels = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

String describeRecurrence(Recurrence r) {
  return switch (r) {
    OneShot() => 'Bir kez',
    Weekly(weekdays: final d) when d.length == 7 => 'Her gün',
    Weekly(weekdays: final d)
        when d.length == 5 && !d.contains(6) && !d.contains(7) =>
      'Hafta içi',
    Weekly(weekdays: final d)
        when d.length == 2 && d.contains(6) && d.contains(7) =>
      'Hafta sonu',
    Weekly(weekdays: final d) =>
      (d.toList()..sort()).map((x) => _dayLabels[x - 1]).join(' '),
  };
}

class RuleListPage extends ConsumerWidget {
  const RuleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Alarm'),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Ayarlar',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SliverToBoxAdapter(child: _PermissionCard()),
          rules.when(
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Hata: $e'),
              ),
            ),
            data: (list) => list.isEmpty
                ? const SliverFillRemaining(
                    hasScrollBody: false, child: _EmptyState())
                : SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) => _AlarmRow(rule: list[i]),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RuleEditPage()),
        ),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

/// Stok saat uygulamalarındaki alarm satırı: büyük saat, altında özet,
/// sağda anahtar.
class _AlarmRow extends ConsumerWidget {
  const _AlarmRow({required this.rule});

  final IntervalRule rule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final on = rule.isEnabled;
    final fg = on ? scheme.onSurface : scheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Dismissible(
      key: ValueKey(rule.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => ref.read(ruleActionsProvider).delete(rule),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => RuleEditPage(rule: rule)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatMinute(rule.startMinute),
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w300,
                        height: 1.05,
                        letterSpacing: -1,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rule.isSingle
                          ? describeRecurrence(rule.recurrence)
                          : '${describeRecurrence(rule.recurrence)} · '
                              '${formatMinute(rule.endMinute)}\'ye kadar '
                              '${rule.intervalMinutes} dk arayla',
                      style: TextStyle(fontSize: 13, color: fg),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rule.isSingle
                          ? (rule.label.isEmpty ? 'Tek alarm' : rule.label)
                          : '${rule.occurrenceCount} alarm'
                              '${rule.label.isEmpty ? '' : ' · ${rule.label}'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: on ? scheme.primary : fg,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: rule.isEnabled,
                onChanged: (v) => ref.read(ruleActionsProvider).toggle(rule, v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm, size: 72, color: scheme.outlineVariant),
            const SizedBox(height: 20),
            Text('Alarm yok', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Bir saat aralığı seç, uygulama o aralıkta\n'
              'belirlediğin sıklıkta alarm kursun.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// İzin eksikse alarm sessizce çalmaz; kullanıcıyı uyarmak zorundayız.
class _PermissionCard extends ConsumerWidget {
  const _PermissionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsProvider);
    final scheme = Theme.of(context).colorScheme;

    return perms.maybeWhen(
      data: (p) {
        if (p.canSchedule) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Material(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await ref.read(alarmSinkProvider).requestPermissions();
                ref.invalidate(permissionsProvider);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: scheme.onErrorContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Alarmların çalması için izin gerekiyor '
                        '(${p.missing.join(', ')}). Vermek için dokun.',
                        style: TextStyle(color: scheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
