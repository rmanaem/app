import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:starter_app/main_dev.dart' as dev_main;
import 'package:starter_app/src/features/onboarding/presentation/pages/welcome_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dev flavor boots to welcome page', (tester) async {
    await dev_main.main();
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
