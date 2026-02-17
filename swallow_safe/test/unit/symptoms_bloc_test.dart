import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:swallow_safe/features/tracking/bloc/symptoms_bloc.dart';
import 'package:swallow_safe/data/repositories/symptoms_repository.dart';
import 'package:swallow_safe/core/services/haptic_service.dart';
import 'package:swallow_safe/data/models/symptom_entry.dart';

// Mocks
class MockSymptomsRepository extends Mock implements SymptomsRepository {}
class MockHapticService extends Mock implements HapticService {}

// Fake for SymptomEntry
class FakeSymptomEntry extends Fake implements SymptomEntry {}

void main() {
  late SymptomsBloc symptomsBloc;
  late MockSymptomsRepository mockRepository;
  late MockHapticService mockHapticService;
  
  setUpAll(() {
    registerFallbackValue(FakeSymptomEntry());
  });
  
  setUp(() {
    mockRepository = MockSymptomsRepository();
    mockHapticService = MockHapticService();
    
    // Default mock behaviors
    when(() => mockRepository.getTodayEntry())
        .thenAnswer((_) async => null);
    when(() => mockRepository.saveEntry(any()))
        .thenAnswer((_) async {});
    when(() => mockHapticService.successPattern())
        .thenAnswer((_) async {});
    
    symptomsBloc = SymptomsBloc(
      repository: mockRepository,
      hapticService: mockHapticService,
    );
  });
  
  tearDown(() {
    symptomsBloc.close();
  });
  
  group('SymptomsBloc', () {
    test('initial state is SymptomsInitial', () {
      expect(symptomsBloc.state, isA<SymptomsInitial>());
    });
    
    blocTest<SymptomsBloc, SymptomsState>(
      'emits [SymptomsLoading, SymptomsEditing] when LoadTodaySymptoms is added',
      build: () => symptomsBloc,
      act: (bloc) => bloc.add(const LoadTodaySymptoms()),
      expect: () => [
        isA<SymptomsLoading>(),
        isA<SymptomsEditing>(),
      ],
    );
    
    blocTest<SymptomsBloc, SymptomsState>(
      'loads existing entry if available',
      setUp: () {
        when(() => mockRepository.getTodayEntry())
            .thenAnswer((_) async => SymptomEntry(
              id: 'test',
              date: DateTime.now(),
              painLevel: 2,
              swallowingEase: 3,
              dryMouth: 1,
              createdAt: DateTime.now(),
            ));
      },
      build: () => symptomsBloc,
      act: (bloc) => bloc.add(const LoadTodaySymptoms()),
      expect: () => [
        isA<SymptomsLoading>(),
        isA<SymptomsEditing>()
            .having((s) => s.painLevel, 'painLevel', 2)
            .having((s) => s.swallowingEase, 'swallowingEase', 3)
            .having((s) => s.dryMouth, 'dryMouth', 1)
            .having((s) => s.hasExistingEntry, 'hasExistingEntry', true),
      ],
    );
    
    blocTest<SymptomsBloc, SymptomsState>(
      'updates pain level correctly',
      build: () => symptomsBloc,
      seed: () => const SymptomsEditing(),
      act: (bloc) => bloc.add(const UpdatePainLevel(3)),
      expect: () => [
        isA<SymptomsEditing>().having((s) => s.painLevel, 'painLevel', 3),
      ],
    );
    
    blocTest<SymptomsBloc, SymptomsState>(
      'updates swallowing ease correctly',
      build: () => symptomsBloc,
      seed: () => const SymptomsEditing(),
      act: (bloc) => bloc.add(const UpdateSwallowingEase(4)),
      expect: () => [
        isA<SymptomsEditing>()
            .having((s) => s.swallowingEase, 'swallowingEase', 4),
      ],
    );
    
    blocTest<SymptomsBloc, SymptomsState>(
      'updates dry mouth correctly',
      build: () => symptomsBloc,
      seed: () => const SymptomsEditing(),
      act: (bloc) => bloc.add(const UpdateDryMouth(2)),
      expect: () => [
        isA<SymptomsEditing>().having((s) => s.dryMouth, 'dryMouth', 2),
      ],
    );
    
    blocTest<SymptomsBloc, SymptomsState>(
      'saves entry when all symptoms are selected',
      build: () => symptomsBloc,
      seed: () => const SymptomsEditing(
        painLevel: 2,
        swallowingEase: 3,
        dryMouth: 1,
      ),
      act: (bloc) => bloc.add(const SaveSymptomEntry()),
      expect: () => [
        isA<SymptomsEditing>().having((s) => s.isSaving, 'isSaving', true),
        isA<SymptomsSaved>(),
      ],
      verify: (_) {
        verify(() => mockRepository.saveEntry(any())).called(1);
        verify(() => mockHapticService.successPattern()).called(1);
      },
    );
    
    blocTest<SymptomsBloc, SymptomsState>(
      'does not save when symptoms incomplete',
      build: () => symptomsBloc,
      seed: () => const SymptomsEditing(
        painLevel: 2,
        // swallowingEase and dryMouth are null
      ),
      act: (bloc) => bloc.add(const SaveSymptomEntry()),
      expect: () => [], // No state change
      verify: (_) {
        verifyNever(() => mockRepository.saveEntry(any()));
      },
    );
  });
}
