import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:grocery/views/entrypoint/entrypoint_ui.dart';

void main() {
  testWidgets('EntryPointUI shows the main navigation shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: EntryPointUI()),
      ),
    );

    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
