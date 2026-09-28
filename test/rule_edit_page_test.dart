import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarm_burst/src/data/database.dart';
import 'package:alarm_burst/src/domain/interval_rule.dart';
import 'package:alarm_burst/src/features/rules/rule_edit_page.dart';
import 'package:alarm_burst/src/features/rules/rule_list_page.dart';
import 'package:alarm_burst/src/providers.dart';
import 'package:alarm_burst/src/scheduler/alarm_sink.dart';

import 'fake_alarm_sink.dart';

/// Varsayılan test ekranı 800x600; düzenleme sayfasının alt kısmı (önizleme)
/// bu boyutta hiç inşa edilmiyor. Gerçek telefon boyutuna çıkarıyoruz.
void _phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  late AppDatabase db;
  late FakeAlarmSink sink;

  setUp(() {
    // Ayarlar sağlayıcısı shared_preferences okuyor; testte taklit gerekiyor.
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    sink = FakeAlarmSink();
  });

  tearDown(() => db.close());

  Widget wrap(Widget child, {AlarmSink? overrideSink}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        alarmSinkProvider.overrideWithValue(overrideSink ?? sink),
        rulesProvider.overrideWith((ref) => Stream.value(const <IntervalRule>[])),
      ],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('varsayilan aralik onizlemede 11 alarm gosterir', (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(wrap(const RuleEditPage()));
    await tester.pumpAndSettle();

    // 08:00-08:20 / 2 dk varsayilani, iki uc dahil
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('08:20'), findsOneWidget);
    expect(find.text('11 alarm çalacak'), findsOneWidget);
  });

  testWidgets('onizleme tam alarm saatlerini listeler', (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(wrap(const RuleEditPage()));
    await tester.pumpAndSettle();

    final preview = tester.widget<Text>(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data?.startsWith('08:00') ?? false) &&
            (w.data?.contains('08:02') ?? false),
      ),
    );
    expect(preview.data, contains('08:20'));
    expect(
      RegExp(r'\d{2}:\d{2}').allMatches(preview.data!).length,
      11,
      reason: 'iki uc dahil 11 saat listelenir',
    );
  });

  testWidgets('aralik degisince onizleme aninda guncellenir', (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(wrap(const RuleEditPage()));
    await tester.pumpAndSettle();

    // 2 dk -> 5 dk: 08:00,05,10,15,20 = 5 alarm
    await tester.tap(find.widgetWithText(ChoiceChip, '5 dk'));
    await tester.pumpAndSettle();

    expect(find.text('5 alarm çalacak'), findsOneWidget);
  });

  testWidgets('gun secilince tekrarli kurala doner', (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(wrap(const RuleEditPage()));
    await tester.pumpAndSettle();

    expect(find.textContaining('alarm bir kez çalar'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'Pzt'));
    await tester.pumpAndSettle();

    expect(find.textContaining('her hafta tekrarlanır'), findsOneWidget);
  });

  testWidgets('kaydetme kurali yazar ve alarmlari kurar', (tester) async {
    _phoneSize(tester);
    await tester.pumpWidget(wrap(const RuleListPage()));
    await tester.pump();
    expect(find.text('Alarm yok'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Kaydet'));
    // Veritabani yazimi ve alarm kurulumu gercek asenkron is; runAsync
    // olmadan tester sahte zamanda kaldigi icin tamamlanmiyorlar.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();

    final saved = await db.allRules();
    expect(saved.length, 1);
    expect(saved.single.startMinute, 8 * 60);
    expect(saved.single.endMinute, 8 * 60 + 20);
    expect(saved.single.intervalMinutes, 2);
    expect(saved.single.weekdayMask, 0, reason: 'gun secilmedi, tek seferlik');

    // Kayan pencere: 11'in tamami degil, pencere kadari kurulur.
    expect(sink.scheduled, isNotEmpty);
    expect(sink.scheduled.length, lessThanOrEqualTo(15));

    // SnackBar kendini kapatmak icin zamanlayici kuruyor.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('izin eksikse uyari gorunur', (tester) async {
    await tester.pumpWidget(
        wrap(const RuleListPage(), overrideSink: _DeniedSink()));
    await tester.pump();

    expect(find.textContaining('izin gerekiyor'), findsOneWidget);
    expect(find.textContaining('kesin alarm'), findsOneWidget);
  });
}

class _DeniedSink extends FakeAlarmSink {
  @override
  Future<AlarmPermissions> permissions() async => const AlarmPermissions(
        notifications: true,
        exactAlarms: false,
        fullScreenIntent: false,
      );
}
