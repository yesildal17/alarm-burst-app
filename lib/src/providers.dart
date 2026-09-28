import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/database.dart';
import 'features/settings/settings_state.dart';
import 'platform/widget_bridge.dart';
import 'data/rule_mapper.dart';
import 'domain/interval_rule.dart';
import 'scheduler/alarm_plus_sink.dart';
import 'scheduler/alarm_sink.dart';
import 'scheduler/alarm_sync_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Web'de gerçek alarm kurulamıyor; arayüzü orada da çalıştırabilmek için
/// sahte bir hedef kullanıyoruz.
final alarmSinkProvider = Provider<AlarmSink>((ref) {
  if (kIsWeb) return _NoopSink();
  return const AlarmPlusSink();
});

final syncServiceProvider = Provider<AlarmSyncService>((ref) {
  final settings = ref.watch(settingsProvider);
  return AlarmSyncService(
    db: ref.watch(databaseProvider),
    sink: ref.watch(alarmSinkProvider),
    soundUri: settings.soundUri,
    vibrate: settings.vibrate,
  );
});

/// Kural listesi; veritabanı değiştikçe kendiliğinden güncellenir.
final rulesProvider = StreamProvider<List<IntervalRule>>((ref) {
  return ref.watch(databaseProvider).watchRules().map((rows) {
    final rules = rows.map(ruleFromRow).toList();
    // Kural listesi her değiştiğinde ana ekran widget'ı da tazelensin.
    updateAlarmWidget(rules);
    return rules;
  });
});

final permissionsProvider = FutureProvider<AlarmPermissions>((ref) {
  return ref.watch(alarmSinkProvider).permissions();
});

/// Kural ekleme/düzenleme/silme işlemleri; her değişiklikten sonra işletim
/// sistemi alarmlarını yeniden eşitler.
class RuleActions {
  RuleActions(this._db, this._sync);

  final AppDatabase _db;
  final AlarmSyncService _sync;

  Future<SyncResult> save(IntervalRule rule) async {
    await _db.upsertRule(rowFromRule(rule));
    return _sync.syncRule(rule);
  }

  Future<void> toggle(IntervalRule rule, bool enabled) async {
    await save(rule.copyWith(isEnabled: enabled));
  }

  Future<void> delete(IntervalRule rule) async {
    // Önce alarmları iptal et, sonra kuralı sil: sıra tersine olursa
    // kurulu alarmlar sahipsiz kalır.
    await _sync.syncRule(rule.copyWith(isEnabled: false));
    await _db.deleteRule(rule.id);
  }
}

final ruleActionsProvider = Provider<RuleActions>((ref) {
  return RuleActions(ref.watch(databaseProvider), ref.watch(syncServiceProvider));
});

class _NoopSink implements AlarmSink {
  @override
  Future<void> schedule({
    required String id,
    required DateTime at,
    required String label,
    String soundUri = '',
    bool vibrate = true,
  }) async {}

  @override
  Future<void> cancel(String id) async {}

  @override
  Future<AlarmPermissions> permissions() async =>
      const AlarmPermissions.allGranted();

  @override
  Future<AlarmPermissions> requestPermissions() async =>
      const AlarmPermissions.allGranted();
}
