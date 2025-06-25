import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_frontend/main.dart';

void main() {
  testWidgets('App loads and renders TicTacToe UI', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Verify main app bar and key texts appear.
    expect(find.text('Tic Tac Toe'), findsOneWidget);
    expect(find.text('Player X'), findsOneWidget);
    expect(find.text('Player O'), findsOneWidget);
    expect(find.text('Draws'), findsOneWidget);
    // Control buttons are present.
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
    // Board is present (CustomPaint for the empty grid/cells or X/O).
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
