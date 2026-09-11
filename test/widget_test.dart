import 'package:flutter_test/flutter_test.dart';
import 'package:sauvaad/main.dart';
import 'package:sauvaad/screens/splash_screen.dart';

void main() {
  testWidgets('SauvaadApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SauvaadApp());
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
