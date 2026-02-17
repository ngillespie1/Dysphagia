/// Educational context for exercises — explains *why* each exercise helps.
/// Keyed by exercise name prefix so it works with generated exercise IDs.
class ExerciseEducation {
  final String whyItHelps;
  final List<String> musclesTargeted;
  final String? researchNote;

  const ExerciseEducation({
    required this.whyItHelps,
    required this.musclesTargeted,
    this.researchNote,
  });

  /// Lookup educational info by exercise ID or name substring.
  /// Returns null if no match.
  static ExerciseEducation? forExercise(String exerciseIdOrName) {
    final lower = exerciseIdOrName.toLowerCase();
    for (final entry in _library.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static const Map<String, ExerciseEducation> _library = {
    'chin_tuck': ExerciseEducation(
      whyItHelps:
          'Tucking your chin pushes the base of your tongue backward, '
          'widening the throat space and narrowing the airway entrance. '
          'This reduces the chance of food or liquid entering your lungs.',
      musclesTargeted: ['Suprahyoid muscles', 'Base of tongue'],
      researchNote: 'Shown to reduce aspiration in thin-liquid swallows.',
    ),
    'tongue_press': ExerciseEducation(
      whyItHelps:
          'Pressing your tongue against the roof of your mouth builds the strength '
          'needed to propel food backward during the oral phase of swallowing.',
      musclesTargeted: ['Intrinsic tongue muscles', 'Genioglossus'],
    ),
    'effortful_swallow': ExerciseEducation(
      whyItHelps:
          'Swallowing with maximum effort increases pressure at the base of the tongue, '
          'pushing food more forcefully into the throat. This clears residue that a '
          'normal swallow might leave behind.',
      musclesTargeted: ['Tongue base', 'Pharyngeal constrictors'],
      researchNote:
          'Increases base-of-tongue to posterior pharyngeal wall pressure.',
    ),
    'mendelsohn': ExerciseEducation(
      whyItHelps:
          'Holding your Adam\'s apple at its highest point during a swallow keeps '
          'the upper esophageal sphincter open longer, allowing food to pass through safely.',
      musclesTargeted: [
        'Submental muscles',
        'Thyrohyoid',
        'Upper esophageal sphincter',
      ],
      researchNote: 'Improves UES opening duration and hyoid excursion.',
    ),
    'supraglottic': ExerciseEducation(
      whyItHelps:
          'Taking a deep breath, holding it, swallowing, and then coughing '
          'closes the vocal folds before and during the swallow. This protects '
          'your airway from any material that might enter.',
      musclesTargeted: ['Vocal folds', 'Arytenoid cartilages'],
    ),
    'shaker': ExerciseEducation(
      whyItHelps:
          'Lifting your head while lying flat strengthens the muscles that '
          'pull open the upper food tube. A stronger opening means food passes '
          'through more easily and safely.',
      musclesTargeted: [
        'Anterior belly of digastric',
        'Mylohyoid',
        'Geniohyoid',
      ],
      researchNote:
          'Shaker et al. (2002) showed significant UES opening improvement.',
    ),
    'masako': ExerciseEducation(
      whyItHelps:
          'Swallowing while holding your tongue between your teeth forces '
          'the back wall of your throat to work harder to contact the tongue base. '
          'Over time, this builds pharyngeal muscle strength.',
      musclesTargeted: ['Superior pharyngeal constrictor', 'Tongue base'],
    ),
    'tongue_resistance': ExerciseEducation(
      whyItHelps:
          'Pushing your tongue against resistance (like a spoon or depressor) '
          'builds isometric strength — similar to how a bicep curl builds arm strength.',
      musclesTargeted: [
        'Genioglossus',
        'Intrinsic tongue muscles',
        'Palatoglossus',
      ],
    ),
    'breath_hold': ExerciseEducation(
      whyItHelps:
          'Holding your breath voluntarily closes the vocal folds. '
          'Practicing this improves your ability to protect the airway on command, '
          'which is critical during the pharyngeal swallow phase.',
      musclesTargeted: ['Thyroarytenoid', 'Lateral cricoarytenoid'],
    ),
    'vocal_exercise': ExerciseEducation(
      whyItHelps:
          'Voice exercises strengthen the same muscles used to close the airway '
          'during swallowing. Better vocal fold closure means better airway protection.',
      musclesTargeted: ['Thyroarytenoid', 'Cricothyroid'],
    ),
    'rapid_swallow': ExerciseEducation(
      whyItHelps:
          'Swallowing multiple times in quick succession trains coordination and '
          'endurance. This helps when eating full meals that require many consecutive swallows.',
      musclesTargeted: ['All swallowing muscles', 'Central pattern generators'],
    ),
    'intro_swallow': ExerciseEducation(
      whyItHelps:
          'Starting with gentle, conscious swallowing helps re-establish the basic '
          'neural signals between your brain and throat muscles. Think of it as warming up before a workout.',
      musclesTargeted: ['All swallowing muscles'],
    ),
  };
}
