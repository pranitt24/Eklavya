
import 'package:flutter_test/flutter_test.dart';
import 'package:majhe_gaon/nova_main/app.dart';
import 'package:majhe_gaon/nova_main/services/app_state.dart';

void main() {
  testWidgets('NOVA app starts on the splash screen', (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      AppStateScope(
        appState: appState,
        child: const NovaApp(),
      ),
    );

    await tester.pump();
    expect(find.text('NOVA'), findsWidgets);
  });
}
