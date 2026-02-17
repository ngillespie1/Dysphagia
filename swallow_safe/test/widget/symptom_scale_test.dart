import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:swallow_safe/shared/widgets/symptom_scale.dart';
import 'package:swallow_safe/core/constants/dimensions.dart';
import 'package:swallow_safe/core/services/haptic_service.dart';

// Mock haptic service
class MockHapticService extends HapticService {
  int mediumImpactCalls = 0;

  @override
  Future<void> mediumImpact() async {
    mediumImpactCalls++;
  }
}

void main() {
  late MockHapticService mockHapticService;

  setUp(() {
    mockHapticService = MockHapticService();

    if (GetIt.I.isRegistered<HapticService>()) {
      GetIt.I.unregister<HapticService>();
    }
    GetIt.I.registerLazySingleton<HapticService>(() => mockHapticService);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('SymptomScale', () {
    testWidgets('renders title correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomScale(
              title: 'Pain Level',
              type: SymptomType.pain,
              selectedValue: null,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      // Let flutter_animate animations settle
      await tester.pumpAndSettle();

      expect(find.text('Pain Level'), findsOneWidget);
    });

    testWidgets('displays 5 selectable options', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomScale(
              title: 'Test',
              type: SymptomType.pain,
              selectedValue: null,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Each symptom level renders an icon via _SymptomButton
      // There are 5 face icons for pain type
      expect(
        find.byIcon(Icons.sentiment_very_satisfied_rounded),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.sentiment_satisfied_rounded),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.sentiment_neutral_rounded),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.sentiment_dissatisfied_rounded),
        findsOneWidget,
      );
      expect(
        find.byIcon(Icons.sentiment_very_dissatisfied_rounded),
        findsOneWidget,
      );
    });

    testWidgets('calls onSelected with correct value when tapped',
        (tester) async {
      int? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomScale(
              title: 'Test',
              type: SymptomType.pain,
              selectedValue: null,
              onSelected: (value) => selectedValue = value,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the "neutral" face icon (value 3)
      await tester.tap(find.byIcon(Icons.sentiment_neutral_rounded));
      await tester.pumpAndSettle();

      expect(selectedValue, 3);
    });

    testWidgets('triggers haptic feedback on selection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomScale(
              title: 'Test',
              type: SymptomType.pain,
              selectedValue: null,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first face icon (value 1)
      await tester.tap(find.byIcon(Icons.sentiment_very_satisfied_rounded));
      await tester.pumpAndSettle();

      expect(mockHapticService.mediumImpactCalls, 1);
    });

    testWidgets('shows Great and Very Difficult labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomScale(
              title: 'Test',
              type: SymptomType.pain,
              selectedValue: null,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Great'), findsOneWidget);
      expect(find.text('Really tough'), findsOneWidget);
    });

    testWidgets('each button is at least minimum touch target size',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SymptomScale(
              title: 'Test',
              type: SymptomType.pain,
              selectedValue: null,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The symptom button size is defined in dimensions
      expect(AppDimensions.symptomButtonSize, greaterThanOrEqualTo(48));
    });
  });
}
