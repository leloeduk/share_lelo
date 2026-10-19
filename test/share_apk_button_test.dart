import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_lelo/share_lelo.dart';

void main() {
  testWidgets('ShareApkButton renders its label and icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShareApkButton(
            label: Text('Send'),
            icon: Icon(Icons.bluetooth),
          ),
        ),
      ),
    );
    expect(find.text('Send'), findsOneWidget);
    expect(find.byIcon(Icons.bluetooth), findsOneWidget);
  });
}
