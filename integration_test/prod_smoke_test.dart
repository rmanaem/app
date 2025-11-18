import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:starter_app/main_prod.dart' as prod_main;
import 'package:starter_app/src/presentation/pages/auth/welcome_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prod flavor boots to welcome page', (tester) async {
    await prod_main.main();
    await tester.pumpAndSettle();

    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
