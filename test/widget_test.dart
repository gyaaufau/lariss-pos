import 'package:flutter_test/flutter_test.dart';

import 'package:lariss/core/di/service_locator.dart';
import 'package:lariss/main.dart';

void main() {
  testWidgets('app shows foundation home screen', (WidgetTester tester) async {
    await setupServiceLocator();
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lariss POS'), findsWidgets);
    expect(find.text('Daftar produk'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
  });
}
