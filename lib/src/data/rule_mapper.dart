import '../domain/interval_rule.dart';
import 'database.dart';

/// Haftanın günleri bit maskesi ↔ DateTime.weekday kümesi dönüşümü.
///
/// Maske: pazartesi = 1<<0 ... pazar = 1<<6. 0 ise kural tek seferlik.
int weekdaysToMask(Set<int> weekdays) {
  var mask = 0;
  for (final d in weekdays) {
    if (d >= DateTime.monday && d <= DateTime.sunday) {
      mask |= 1 << (d - 1);
    }
  }
  return mask;
}

Set<int> maskToWeekdays(int mask) {
  return {
    for (var d = DateTime.monday; d <= DateTime.sunday; d++)
      if (mask & (1 << (d - 1)) != 0) d,
  };
}

IntervalRule ruleFromRow(Rule row) {
  return IntervalRule(
    id: row.id,
    label: row.label,
    startMinute: row.startMinute,
    endMinute: row.endMinute,
    intervalMinutes: row.intervalMinutes,
    recurrence: row.weekdayMask == 0
        ? const OneShot()
        : Weekly(maskToWeekdays(row.weekdayMask)),
    isEnabled: row.isEnabled,
  );
}

Rule rowFromRule(IntervalRule rule, {DateTime? createdAt}) {
  return Rule(
    id: rule.id,
    label: rule.label,
    startMinute: rule.startMinute,
    endMinute: rule.endMinute,
    intervalMinutes: rule.intervalMinutes,
    weekdayMask: switch (rule.recurrence) {
      OneShot() => 0,
      Weekly(weekdays: final d) => weekdaysToMask(d),
    },
    isEnabled: rule.isEnabled,
    createdAt: createdAt ?? DateTime.now(),
  );
}
