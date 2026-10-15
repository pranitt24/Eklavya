// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:majhe_gaon/main.dart';
import 'package:majhe_gaon/nova_main/services/app_state.dart';

void main() {
  testWidgets('Smoke test for MajheGaonApp', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(
      ProviderScope(
        child: AppStateScope(
          appState: appState,
          child: const MajheGaonApp(),
        ),
      ),
    );

    expect(find.byType(MajheGaonApp), findsOneWidget);
  });
}
