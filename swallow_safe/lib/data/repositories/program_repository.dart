import '../../core/models/program.dart' as core;
import '../models/program.dart';
import '../models/exercise.dart';

/// Publicly accessible placeholder video URLs for testing.
/// These are short, reliable MP4 clips hosted by Google & Flutter.
class _PlaceholderVideos {
  static const butterfly =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
  static const bee =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';
  static const forBiggerBlazes =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';
  static const forBiggerEscapes =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4';
  static const forBiggerFun =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4';
  static const forBiggerJoyrides =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4';
  static const forBiggerMeltdowns =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4';
  static const subaru =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4';
  static const elephantsDream =
      'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4';

  /// Rotate through videos so each exercise gets a different clip
  static const all = [
    butterfly,
    bee,
    forBiggerBlazes,
    forBiggerEscapes,
    forBiggerFun,
    forBiggerJoyrides,
    forBiggerMeltdowns,
  ];

  static String forIndex(int index) => all[index % all.length];
}

/// Repository for managing exercise programs
class ProgramRepository {
  // ── Currently selected program type ──
  core.ProgramType _selectedType = core.ProgramType.headNeckCancer;

  /// Set the active program type (called when user selects from ProgramSelector)
  void setSelectedProgramType(core.ProgramType type) {
    _selectedType = type;
  }

  /// Get the currently selected program type
  core.ProgramType get selectedProgramType => _selectedType;

  // ───────────────────────────────────────────────
  // Public API
  // ───────────────────────────────────────────────

  /// Get program by ID
  Future<Program?> getProgram(String programId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPrograms[programId];
  }

  /// Get user's current program based on selected type
  Future<Program> getCurrentProgram(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return getProgramForType(_selectedType);
  }

  /// Get the session-level Program for a given ProgramType
  Program getProgramForType(core.ProgramType type) {
    switch (type) {
      case core.ProgramType.postStroke:
        return _mockPrograms['stroke_recovery']!;
      case core.ProgramType.postSurgery:
        return _mockPrograms['post_surgery_recovery']!;
      case core.ProgramType.neurological:
        return _mockPrograms['neurological_recovery']!;
      case core.ProgramType.headNeckCancer:
        return _mockPrograms['hnc_recovery']!;
      case core.ProgramType.aging:
        return _mockPrograms['aging_recovery']!;
    }
  }

  /// Get all available programs
  Future<List<Program>> getAllPrograms() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPrograms.values.toList();
  }

  // ───────────────────────────────────────────────
  // Mock program data – all 5 ailment types
  // ───────────────────────────────────────────────

  static final Map<String, Program> _mockPrograms = {
    // ════════════════════════════════════════════
    // 1. POST-STROKE RECOVERY (4 exercises)
    // ════════════════════════════════════════════
    'stroke_recovery': Program(
      id: 'stroke_recovery',
      title: 'Post-Stroke Recovery',
      description:
          'Rebuild swallowing function after stroke with targeted exercises '
          'that reactivate neural pathways and strengthen weakened muscles.',
      difficulty: 'beginner',
      estimatedDuration: const Duration(minutes: 12),
      exercises: [
        Exercise(
          id: 'stroke_lip_closure',
          name: 'Lip Closure',
          description: 'Strengthens lip seal to prevent drooling and '
              'improve oral containment of food and liquid.',
          instructions:
              'Press your lips together firmly. Hold for 5 seconds, '
              'then relax. Repeat.',
          videoUrl: _PlaceholderVideos.forIndex(0),
          reps: 10,
          holdDuration: const Duration(seconds: 5),
        ),
        Exercise(
          id: 'stroke_tongue_rom',
          name: 'Tongue Range of Motion',
          description: 'Improves tongue mobility for moving food around '
              'your mouth and initiating swallows.',
          instructions:
              'Stick your tongue straight out, then move it up toward '
              'your nose, down toward your chin, then left and right. '
              'Hold each position for 2 seconds.',
          videoUrl: _PlaceholderVideos.forIndex(1),
          reps: 5,
          holdDuration: const Duration(seconds: 2),
        ),
        Exercise(
          id: 'stroke_chin_tuck',
          name: 'Chin Tuck',
          description: 'Protects your airway by pushing the tongue base '
              'backward and narrowing the airway entrance.',
          instructions:
              'Lower your chin toward your chest. Hold for 3 seconds, '
              'then return to a neutral position.',
          videoUrl: _PlaceholderVideos.forIndex(2),
          reps: 10,
          holdDuration: const Duration(seconds: 3),
        ),
        Exercise(
          id: 'stroke_effortful_swallow',
          name: 'Effortful Swallow',
          description: 'Increases the force of your swallow to clear '
              'residue from the throat.',
          instructions:
              'Swallow as hard as you can, squeezing all of your '
              'swallowing muscles at the same time. Relax, then repeat.',
          videoUrl: _PlaceholderVideos.forIndex(3),
          reps: 8,
        ),
        Exercise(
          id: 'stroke_cheek_puff',
          name: 'Cheek Puff',
          description: 'Strengthens cheek muscles needed to manage food '
              'in the mouth.',
          instructions:
              'Puff out both cheeks with air and hold for 5 seconds. '
              'Release and repeat. Then alternate cheeks.',
          videoUrl: _PlaceholderVideos.forIndex(4),
          reps: 10,
          holdDuration: const Duration(seconds: 5),
        ),
      ],
    ),

    // ════════════════════════════════════════════
    // 2. POST-SURGERY REHABILITATION (4 exercises)
    // ════════════════════════════════════════════
    'post_surgery_recovery': Program(
      id: 'post_surgery_recovery',
      title: 'Post-Surgery Rehabilitation',
      description:
          'Gentle exercises to restore swallowing function after head, '
          'neck, or throat surgery. Progresses gradually to avoid strain.',
      difficulty: 'beginner',
      estimatedDuration: const Duration(minutes: 10),
      exercises: [
        Exercise(
          id: 'surgery_intro_swallow',
          name: 'Gentle Conscious Swallow',
          description: 'Re-establishes the basic neural signals between '
              'your brain and throat muscles.',
          instructions:
              'Take a small sip of water. Focus on every phase of the '
              'swallow: hold the water on your tongue, push it backward, '
              'feel the swallow happen. Rest between swallows.',
          videoUrl: _PlaceholderVideos.forIndex(0),
          reps: 6,
        ),
        Exercise(
          id: 'surgery_tongue_press',
          name: 'Tongue Press',
          description: 'Builds tongue strength needed to propel food '
              'backward during the oral phase of swallowing.',
          instructions:
              'Press the tip of your tongue firmly against the roof of '
              'your mouth (just behind your front teeth). Hold for '
              '5 seconds, relax, and repeat.',
          videoUrl: _PlaceholderVideos.forIndex(1),
          reps: 10,
          holdDuration: const Duration(seconds: 5),
        ),
        Exercise(
          id: 'surgery_breath_hold',
          name: 'Breath Hold',
          description: 'Strengthens vocal fold closure to protect the '
              'airway during swallowing.',
          instructions:
              'Take a deep breath in. Hold your breath for 5 seconds, '
              'keeping your throat closed. Release and breathe normally.',
          videoUrl: _PlaceholderVideos.forIndex(2),
          reps: 8,
          holdDuration: const Duration(seconds: 5),
        ),
        Exercise(
          id: 'surgery_chin_tuck',
          name: 'Chin Tuck Against Resistance',
          description: 'Strengthens suprahyoid muscles and base-of-tongue '
              'retraction for safer swallowing.',
          instructions:
              'Place a small towel roll under your chin. Tuck your chin '
              'and press down against the towel. Hold for 3 seconds.',
          videoUrl: _PlaceholderVideos.forIndex(3),
          reps: 10,
          holdDuration: const Duration(seconds: 3),
        ),
      ],
    ),

    // ════════════════════════════════════════════
    // 3. NEUROLOGICAL CONDITIONS (5 exercises)
    // ════════════════════════════════════════════
    'neurological_recovery': Program(
      id: 'neurological_recovery',
      title: 'Neurological Conditions',
      description:
          'Maintain and improve swallowing function for Parkinson\'s, '
          'MS, ALS, and other neurological conditions. Focuses on '
          'coordination, strength, and compensatory strategies.',
      difficulty: 'intermediate',
      estimatedDuration: const Duration(minutes: 15),
      exercises: [
        Exercise(
          id: 'neuro_mendelsohn',
          name: 'Mendelsohn Maneuver',
          description: 'Keeps the upper esophageal sphincter open longer, '
              'allowing food to pass through safely.',
          instructions:
              'Begin to swallow. When you feel your Adam\'s apple rise, '
              'squeeze and hold it at its highest point for 3 seconds. '
              'Then release.',
          videoUrl: _PlaceholderVideos.forIndex(0),
          reps: 8,
          holdDuration: const Duration(seconds: 3),
        ),
        Exercise(
          id: 'neuro_supraglottic',
          name: 'Supraglottic Swallow',
          description: 'Closes the vocal folds before and during the '
              'swallow, protecting your airway.',
          instructions:
              'Take a deep breath and hold it. While still holding your '
              'breath, swallow. Immediately after swallowing, cough '
              'to clear any residue. Then breathe normally.',
          videoUrl: _PlaceholderVideos.forIndex(1),
          reps: 6,
        ),
        Exercise(
          id: 'neuro_shaker',
          name: 'Shaker Exercise',
          description: 'Strengthens the muscles that pull open the upper '
              'esophageal sphincter for easier food passage.',
          instructions:
              'Lie flat on your back. Lift only your head (keep shoulders '
              'down) and look at your toes. Hold for 5 seconds. '
              'Lower and repeat.',
          videoUrl: _PlaceholderVideos.forIndex(2),
          reps: 6,
          holdDuration: const Duration(seconds: 5),
        ),
        Exercise(
          id: 'neuro_masako',
          name: 'Masako Maneuver',
          description: 'Forces the posterior pharyngeal wall to work harder, '
              'building pharyngeal muscle strength.',
          instructions:
              'Hold your tongue gently between your front teeth. '
              'Swallow while keeping your tongue in place. You should '
              'feel the muscles at the back of your throat working harder.',
          videoUrl: _PlaceholderVideos.forIndex(3),
          reps: 10,
        ),
        Exercise(
          id: 'neuro_tongue_resistance',
          name: 'Tongue Resistance Training',
          description: 'Builds isometric tongue strength through '
              'progressive resistance, like a workout for your tongue.',
          instructions:
              'Press the tip of your tongue against a spoon or tongue '
              'depressor that is pushing back against you. Hold for '
              '5 seconds. Then push with the sides and back of your tongue.',
          videoUrl: _PlaceholderVideos.forIndex(4),
          reps: 10,
          holdDuration: const Duration(seconds: 5),
        ),
        Exercise(
          id: 'neuro_vocal_exercise',
          name: 'Vocal Fold Strengthening',
          description: 'Strengthens the same muscles used to close the '
              'airway during swallowing.',
          instructions:
              'Say "EEE" as loud as you can and hold it for 5 seconds. '
              'Then do the same with "AHH." Repeat, alternating between '
              'the two sounds.',
          videoUrl: _PlaceholderVideos.forIndex(5),
          reps: 8,
          holdDuration: const Duration(seconds: 5),
        ),
      ],
    ),

    // ════════════════════════════════════════════
    // 4. HEAD & NECK CANCER (5 exercises)
    // ════════════════════════════════════════════
    'hnc_recovery': Program(
      id: 'hnc_recovery',
      title: 'Head & Neck Cancer Recovery',
      description:
          'Exercises designed for patients during and after radiation or '
          'chemotherapy treatment. Gentle progression to maintain and '
          'restore swallowing ability.',
      difficulty: 'beginner',
      estimatedDuration: const Duration(minutes: 12),
      exercises: [
        Exercise(
          id: 'hnc_masako',
          name: 'Masako Maneuver',
          description: 'Strengthens the back of the throat for better '
              'swallowing by forcing pharyngeal muscles to compensate.',
          instructions:
              'Hold your tongue gently between your front teeth and '
              'swallow. You should feel the muscles at the back of '
              'your throat working.',
          videoUrl: _PlaceholderVideos.forIndex(0),
          reps: 10,
        ),
        Exercise(
          id: 'hnc_chin_tuck',
          name: 'Chin Tuck',
          description: 'Protects your airway during swallowing by '
              'widening the throat and narrowing the airway entrance.',
          instructions:
              'Lower your chin toward your chest. Hold for 3 seconds, '
              'then return to normal position.',
          videoUrl: _PlaceholderVideos.forIndex(1),
          reps: 10,
          holdDuration: const Duration(seconds: 3),
        ),
        Exercise(
          id: 'hnc_effortful_swallow',
          name: 'Effortful Swallow',
          description: 'Increases the force of your swallow to clear '
              'residue from the throat.',
          instructions:
              'Swallow as hard as you can, squeezing all of your '
              'swallowing muscles at once.',
          videoUrl: _PlaceholderVideos.forIndex(2),
          reps: 8,
        ),
        Exercise(
          id: 'hnc_tongue_hold',
          name: 'Tongue Hold (Masako)',
          description: 'Builds tongue base strength to improve bolus '
              'propulsion during the pharyngeal phase.',
          instructions:
              'Stick your tongue out slightly and hold it between your '
              'teeth while swallowing. Focus on feeling the squeeze '
              'at the back of your throat.',
          videoUrl: _PlaceholderVideos.forIndex(3),
          reps: 10,
        ),
        Exercise(
          id: 'hnc_mendelsohn',
          name: 'Mendelsohn Maneuver',
          description: 'Keeps your throat open longer for easier and '
              'safer swallowing.',
          instructions:
              'When you swallow, focus on keeping your Adam\'s apple '
              'raised for 2-3 seconds before relaxing.',
          videoUrl: _PlaceholderVideos.forIndex(4),
          reps: 8,
          holdDuration: const Duration(seconds: 3),
        ),
      ],
    ),

    // ════════════════════════════════════════════
    // 5. AGE-RELATED CHANGES (4 exercises)
    // ════════════════════════════════════════════
    'aging_recovery': Program(
      id: 'aging_recovery',
      title: 'Age-Related Swallowing Support',
      description:
          'Preventive exercises to maintain swallowing strength and '
          'coordination as muscles naturally weaken with age.',
      difficulty: 'beginner',
      estimatedDuration: const Duration(minutes: 9),
      exercises: [
        Exercise(
          id: 'aging_chin_tuck',
          name: 'Chin Tuck',
          description: 'Protects the airway by positioning the tongue '
              'base to cover the airway entrance.',
          instructions:
              'Gently lower your chin toward your chest. Hold for '
              '3 seconds. Return to neutral. Keep movements smooth.',
          videoUrl: _PlaceholderVideos.forIndex(0),
          reps: 10,
          holdDuration: const Duration(seconds: 3),
        ),
        Exercise(
          id: 'aging_tongue_press',
          name: 'Tongue Press',
          description: 'Maintains tongue strength for moving food '
              'through the mouth effectively.',
          instructions:
              'Press your tongue firmly against the roof of your mouth. '
              'Hold for 5 seconds, then relax. '
              'You should feel the muscles under your chin working.',
          videoUrl: _PlaceholderVideos.forIndex(1),
          reps: 10,
          holdDuration: const Duration(seconds: 5),
        ),
        Exercise(
          id: 'aging_effortful_swallow',
          name: 'Effortful Swallow',
          description: 'Keeps swallowing muscles strong to prevent '
              'food from lingering in the throat.',
          instructions:
              'Swallow as hard as you can, focusing on squeezing '
              'every muscle. Pause and repeat.',
          videoUrl: _PlaceholderVideos.forIndex(2),
          reps: 8,
        ),
        Exercise(
          id: 'aging_rapid_swallow',
          name: 'Rapid Repetitive Swallow',
          description: 'Trains swallowing coordination and endurance '
              'for full meals requiring many consecutive swallows.',
          instructions:
              'Swallow 3 times in a row as quickly as you can. '
              'Rest for 5 seconds. Then repeat the set.',
          videoUrl: _PlaceholderVideos.forIndex(3),
          reps: 5,
        ),
      ],
    ),
  };
}
