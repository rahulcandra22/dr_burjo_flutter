import 'package:flutter_test/flutter_test.dart';
import 'package:dr_burjo/main.dart';

void main() {
  testWidgets('App starts correctly', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('DR BURJO'), findsOneWidget);
  });
}
