
import 'package:flutter_test/flutter_test.dart';
import 'package:foodshare_kugompo/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('FoodShare welcome screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FoodShareApp());
    await tester.pumpAndSettle();

    expect(find.text('FoodShare'), findsOneWidget);
    expect(find.text('KuGompo'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('Navigation to registration works',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FoodShareApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Join FoodShare!'), findsOneWidget);
    expect(find.text('Account type'), findsOneWidget);
  });
}
