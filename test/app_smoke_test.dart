import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/src/app/app.dart';

void main() {
  testWidgets('renders template root', (tester) async {
    await tester.pumpWidget(const App(envName: 'test'));
    expect(find.textContaining('Nutrition'), findsOneWidget);
  });
}
