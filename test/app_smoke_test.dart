import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/app/app.dart';
import 'package:starter_app/src/presentation/pages/auth/welcome_page.dart'
    show WelcomePage;

void main() {
  testWidgets('renders template root', (tester) async {
    await tester.pumpWidget(const App(envName: 'test'));
    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
