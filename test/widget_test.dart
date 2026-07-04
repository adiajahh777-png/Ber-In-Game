import 'package:flutter_test/flutter_test.dart';
import 'package:cari_teman_mabar/main.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EsportNewsApp());
    expect(find.byType(EsportNewsApp), findsOneWidget);
  });
}
