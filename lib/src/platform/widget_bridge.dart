import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../domain/interval_rule.dart';
import '../domain/occurrence_generator.dart';

const _widgetName = 'AlarmWidgetProvider';
const _keyNextAlarm = 'next_alarm';

const _days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Ana ekran widget'ındaki "sıradaki alarm" satırını günceller.
///
/// Saat ve tarih widget'ta TextClock ile gösteriliyor ve sistem tarafından
/// güncelleniyor; buradan yalnızca alarm bilgisi besleniyor.
Future<void> updateAlarmWidget(List<IntervalRule> rules, {DateTime? now}) async {
  if (kIsWeb) return;

  final from = now ?? DateTime.now();
  DateTime? soonest;

  for (final rule in rules.where((r) => r.isEnabled)) {
    final next = nextOccurrences(rule, from, limit: 1);
    if (next.isEmpty) continue;
    if (soonest == null || next.first.isBefore(soonest)) soonest = next.first;
  }

  final text = soonest == null ? '' : describeNextAlarm(soonest, from);

  try {
    await HomeWidget.saveWidgetData<String>(_keyNextAlarm, text);
    await HomeWidget.updateWidget(name: _widgetName, androidName: _widgetName);
  } on Exception {
    // Widget eklenmemişse veya güncellenemiyorsa uygulama çalışmaya devam eder.
  }
}

/// Widget satırındaki metin: "⏰ 08:00", "⏰ Yarın 08:00", "⏰ Cum 08:00".
String describeNextAlarm(DateTime at, DateTime from) {
  final time = '${at.hour.toString().padLeft(2, '0')}:'
      '${at.minute.toString().padLeft(2, '0')}';

  final today = DateTime(from.year, from.month, from.day);
  final day = DateTime(at.year, at.month, at.day);
  final diff = day.difference(today).inDays;

  return switch (diff) {
    0 => '⏰ $time',
    1 => '⏰ Yarın $time',
    _ => '⏰ ${_days[at.weekday - 1]} $time',
  };
}
