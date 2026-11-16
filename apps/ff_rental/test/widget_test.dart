import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ff_rental/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
          if (call.method == 'read') return null;
          if (call.method == 'readAll') return <String, String>{};
          if (call.method == 'containsKey') return false;
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
  });

  testWidgets('Inicia o aplicativo FF Rental', (tester) async {
    await tester.pumpWidget(const FFRentalApp());

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
