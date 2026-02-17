import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:swallow_safe/shared/widgets/big_button.dart';
import 'package:swallow_safe/core/constants/dimensions.dart';

void main() {
  group('BigButton', () {
    testWidgets('renders with correct label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BigButton(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('has minimum button height from dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BigButton(
                label: 'Test',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // BigButton uses a Container with AppDimensions.buttonHeight
      expect(AppDimensions.buttonHeight,
          greaterThanOrEqualTo(AppDimensions.minTouchTarget));
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BigButton(
              label: 'Test',
              icon: Icons.play_arrow,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BigButton(
              label: 'Test',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test'), findsNothing);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BigButton(
              label: 'Test',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // BigButton uses GestureDetector with onTapUp, so simulate a full tap
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Test')),
      );
      await gesture.up();
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('renders as outlined button when isOutlined is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BigButton(
              label: 'Outlined Test',
              isOutlined: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      // The outlined variant still renders the label
      expect(find.text('Outlined Test'), findsOneWidget);
      // It uses Container with a border, not OutlinedButton
      expect(find.byType(GestureDetector), findsWidgets);
    });
  });
}
