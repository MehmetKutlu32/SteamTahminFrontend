import 'package:flutter_test/flutter_test.dart';
import 'package:steam_tahmin_frontend/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GameGuessApp());
    expect(find.byType(GameGuessApp), findsOneWidget);
  });
}
