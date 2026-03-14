import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hsk_teacher/app.dart';
import 'package:hsk_teacher/services/storage_service.dart';
import 'package:hsk_teacher/word_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'package:hsk_teacher/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('WordDetailPage toggle learned status', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        home: Scaffold(
          body: StorageServiceProvider(
            storageService: storageService,
            child: const SingleChildScrollView(
              child: WordDetailPage(
                level: 1,
                index: 0,
                hanzi: '我',
                pinyin: 'wǒ',
                meanings: 'I, me',
              ),
            ),
          ),
        ),
      ),
    );

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Mark as learned'), findsOneWidget);
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    
    Switch switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, isFalse);

    // Toggle to true
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, isTrue);
    expect(storageService.isWordLearned(1, '我'), isTrue);

    // Toggle back to false
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    switchWidget = tester.widget(switchFinder);
    expect(switchWidget.value, isFalse);
    expect(storageService.isWordLearned(1, '我'), isFalse);
  });
}
