import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/interval_rule.dart';
import '../../domain/occurrence_generator.dart';
import '../../providers.dart';
import 'rule_list_page.dart' show formatMinute;

/// Bunun üstü büyük olasılıkla yanlış girilmiş bir aralıktır.
const _warnAbove = 60;

/// Gerçekte kullanılan aralıklar; tek dokunuşla seçilsin diye hazır duruyor.
const _quickIntervals = [1, 2, 3, 5, 10, 15, 20, 30];

const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

class RuleEditPage extends ConsumerStatefulWidget {
  const RuleEditPage({super.key, this.rule});

  final IntervalRule? rule;

  @override
  ConsumerState<RuleEditPage> createState() => _RuleEditPageState();
}

class _RuleEditPageState extends ConsumerState<RuleEditPage> {
  late int _start;
  late int _end;
  late int _interval;
  late Set<int> _weekdays;
  late TextEditingController _label;
  late bool _single;

  @override
  void initState() {
    super.initState();
    final r = widget.rule;
    _start = r?.startMinute ?? 8 * 60;
    _end = r?.endMinute ?? 8 * 60 + 20;
    _interval = r?.intervalMinutes ?? 2;
    _single = r?.isSingle ?? false;
    _label = TextEditingController(text: r?.label ?? '');
    _weekdays = switch (r?.recurrence) {
      Weekly(weekdays: final d) => {...d},
      _ => <int>{},
    };
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  IntervalRule get _draft => IntervalRule(
        id: widget.rule?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        label: _label.text.trim(),
        startMinute: _start,
        // Tek alarmda pencere yok: başlangıç ve bitiş aynı olunca
        // kural tam olarak bir alarm üretiyor.
        endMinute: _single ? _start : _end,
        intervalMinutes: _single ? 1 : _interval,
        recurrence:
            _weekdays.isEmpty ? const OneShot() : Weekly(_weekdays),
      );

  Future<void> _pickTime({required bool isStart}) async {
    final current = isStart ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: isStart ? 'BAŞLANGIÇ SAATİ' : 'BİTİŞ SAATİ',
      // Kadran yerine sayı girişi: alarm kurarken saati yazmak, 24 saatlik
      // çift halkalı kadranda hedef aramaktan hızlı.
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked == null) return;
    setState(() {
      final v = picked.hour * 60 + picked.minute;
      if (isStart) {
        _start = v;
      } else {
        _end = v;
      }
    });
  }

  Future<void> _save() async {
    final rule = _draft;
    final result = await ref.read(ruleActionsProvider).save(rule);
    if (!mounted) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.trimmedByLimit
              ? '${result.scheduled} alarm kuruldu, kalanlar sırayla eklenecek.'
              : rule.isSingle
                  ? 'Alarm kuruldu.'
                  : '${rule.occurrenceCount} alarm kuruldu.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rule = _draft;
    final count = rule.occurrenceCount;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rule == null ? 'Alarm ekle' : 'Alarmı düzenle'),
        actions: [
          TextButton(
            onPressed: count > 0 ? _save : null,
            child: const Text('Kaydet'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // Tek alarm mı, aralıklı dizi mi?
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.alarm),
                label: Text('Tek alarm'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.repeat),
                label: Text('Aralıklı'),
              ),
            ],
            selected: {_single},
            onSelectionChanged: (v) => setState(() => _single = v.first),
          ),
          const SizedBox(height: 24),

          if (_single)
            _BigTime(
              caption: 'Saat',
              value: formatMinute(_start),
              onTap: () => _pickTime(isStart: true),
            )
          else
            Row(
              children: [
                Expanded(
                  child: _BigTime(
                    caption: 'Başlangıç',
                    value: formatMinute(_start),
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward,
                      color: scheme.onSurfaceVariant),
                ),
                Expanded(
                  child: _BigTime(
                    caption: 'Bitiş',
                    value: formatMinute(_end),
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
          if (!_single && rule.crossesMidnight)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Bitiş başlangıçtan önce — alarmlar gece yarısını aşıp '
                'ertesi güne taşıyor.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            ),

          if (!_single) ...[
            const SizedBox(height: 32),
            _SectionLabel('Kaç dakikada bir'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in _quickIntervals)
                  ChoiceChip(
                    label: Text('$v dk'),
                    selected: _interval == v,
                    onSelected: (_) => setState(() => _interval = v),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _Stepper(
              value: _interval,
              onChanged: (v) => setState(() => _interval = v),
            ),
          ],

          const SizedBox(height: 32),
          _SectionLabel('Tekrar'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var d = 1; d <= 7; d++)
                FilterChip(
                  label: Text(_dayNames[d - 1]),
                  selected: _weekdays.contains(d),
                  onSelected: (sel) => setState(() {
                    sel ? _weekdays.add(d) : _weekdays.remove(d);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _weekdays.isEmpty
                ? 'Gün seçilmedi — alarm bir kez çalar.'
                : 'Seçili günlerde her hafta tekrarlanır.',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),

          const SizedBox(height: 32),
          TextField(
            controller: _label,
            decoration: const InputDecoration(
              labelText: 'Etiket',
              hintText: 'Örn. sabah kalkış',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),

          if (!_single) ...[
            const SizedBox(height: 32),
            _Preview(
              count: count,
              times: occurrencesOnDay(rule, DateTime(2026, 1, 1)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _BigTime extends StatelessWidget {
  const _BigTime({
    required this.caption,
    required this.value,
    required this.onTap,
  });

  final String caption;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Text(caption,
                  style: TextStyle(
                      fontSize: 12, color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  height: 1.1,
                  letterSpacing: -1,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: value > 1 ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        const SizedBox(width: 12),
        Text('$value dakika',
            style: TextStyle(fontSize: 16, color: scheme.onSurface)),
        const SizedBox(width: 12),
        IconButton.filledTonal(
          onPressed: value < 720 ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Kaydetmeden önce tam olarak hangi alarmların kurulacağını gösterir.
///
/// "08:00–08:20 arası 2 dakika" ifadesinin kaç alarm demek olduğu kullanıcı
/// için de belirsiz; listeyi göstermek soruyu ortadan kaldırıyor.
class _Preview extends StatelessWidget {
  const _Preview({required this.count, required this.times});

  final int count;
  final List<DateTime> times;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (count == 0) {
      return Card(
        color: scheme.errorContainer,
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Bu aralık hiç alarm üretmiyor.'),
        ),
      );
    }

    final shown = times.take(24).toList();
    final labels = shown
        .map((d) =>
            '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}')
        .join('   ');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: count > _warnAbove
            ? scheme.tertiaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$count alarm çalacak',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(
            labels + (times.length > shown.length ? '   …' : ''),
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (count > _warnAbove) ...[
            const SizedBox(height: 12),
            Text(
              'Bu çok fazla alarm. Telefon bir uygulamanın aynı anda '
              'kurabileceği alarm sayısını sınırlıyor; en yakın olanlar '
              'kurulup kalanlar sırayla eklenecek.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}
