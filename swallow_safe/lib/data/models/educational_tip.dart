import 'package:equatable/equatable.dart';

/// Category of educational content
enum TipCategory {
  anatomy,
  nutrition,
  technique,
  motivation,
  safety,
  lifestyle,
}

extension TipCategoryExt on TipCategory {
  String get label {
    switch (this) {
      case TipCategory.anatomy:
        return 'Anatomy';
      case TipCategory.nutrition:
        return 'Nutrition';
      case TipCategory.technique:
        return 'Technique';
      case TipCategory.motivation:
        return 'Motivation';
      case TipCategory.safety:
        return 'Safety';
      case TipCategory.lifestyle:
        return 'Lifestyle';
    }
  }

  String get icon {
    switch (this) {
      case TipCategory.anatomy:
        return '🧠';
      case TipCategory.nutrition:
        return '🥗';
      case TipCategory.technique:
        return '💡';
      case TipCategory.motivation:
        return '💪';
      case TipCategory.safety:
        return '🛡️';
      case TipCategory.lifestyle:
        return '🌿';
    }
  }
}

/// A single educational tip shown to the user
class EducationalTip extends Equatable {
  final String id;
  final String title;
  final String body;
  final TipCategory category;
  final String? source; // Citation or source

  const EducationalTip({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.source,
  });

  @override
  List<Object?> get props => [id, title, category];
}

/// Hardcoded library of educational tips — rotated daily
class EducationalTipLibrary {
  static const List<EducationalTip> all = [
    // ─── Anatomy ───
    EducationalTip(
      id: 'anat_01',
      title: 'Your Swallowing Muscles',
      body:
          'Swallowing involves over 30 pairs of muscles working in perfect coordination. '
          'Each exercise you do strengthens specific muscles in this chain — just like going to the gym for your throat.',
      category: TipCategory.anatomy,
    ),
    EducationalTip(
      id: 'anat_02',
      title: 'The Three Phases of Swallowing',
      body:
          'A single swallow has three phases: oral (mouth), pharyngeal (throat), and esophageal (food tube). '
          'Most exercises target the first two phases, which are under your voluntary control.',
      category: TipCategory.anatomy,
    ),
    EducationalTip(
      id: 'anat_03',
      title: 'The Hyoid Bone',
      body:
          'Your hyoid bone is the only bone in your body not connected to another bone. '
          'It moves upward and forward during swallowing to protect your airway. Chin tuck and Mendelsohn exercises strengthen this movement.',
      category: TipCategory.anatomy,
    ),
    EducationalTip(
      id: 'anat_04',
      title: 'Neural Plasticity & Swallowing',
      body:
          'Your brain can form new neural pathways through repetition. '
          'Each exercise repetition helps your brain re-learn the complex timing of swallowing — this is called neuroplasticity.',
      category: TipCategory.anatomy,
      source: 'Robbins et al., 2008',
    ),

    // ─── Nutrition ───
    EducationalTip(
      id: 'nutr_01',
      title: 'Texture-Modified Diets',
      body:
          'The IDDSI framework classifies food into 8 levels (0–7) from thin liquids to regular food. '
          'Your speech pathologist recommends the safest level for you. As you progress, you may advance to less modified textures.',
      category: TipCategory.nutrition,
      source: 'IDDSI Framework, 2019',
    ),
    EducationalTip(
      id: 'nutr_02',
      title: 'Staying Hydrated',
      body:
          'Dehydration is common with dysphagia because drinking can feel difficult. '
          'Try thickened fluids, gelatin, or ice chips to help meet your hydration goals safely.',
      category: TipCategory.nutrition,
    ),
    EducationalTip(
      id: 'nutr_03',
      title: 'Small Bites, Big Nutrition',
      body:
          'Eating smaller, more frequent meals (5–6 per day) can help you get proper nutrition '
          'without fatigue. Focus on calorie-dense foods like avocado, nut butters, and yogurt.',
      category: TipCategory.nutrition,
    ),

    // ─── Technique ───
    EducationalTip(
      id: 'tech_01',
      title: 'Why Repetitions Matter',
      body:
          'Research shows that 60–120 swallowing exercise repetitions per day leads to measurable strength gains. '
          'Consistency is more important than intensity — doing a little every day beats long sporadic sessions.',
      category: TipCategory.technique,
      source: 'Burkhead et al., 2007',
    ),
    EducationalTip(
      id: 'tech_02',
      title: 'The Chin Tuck Secret',
      body:
          'Tucking your chin toward your chest while swallowing widens the space in your throat '
          'and narrows the airway entrance. This simple posture change can reduce aspiration risk by up to 50%.',
      category: TipCategory.technique,
    ),
    EducationalTip(
      id: 'tech_03',
      title: 'Effortful Swallowing',
      body:
          'When you swallow as hard as you can, you activate muscles that a normal swallow might not fully engage. '
          'Think of it as "weightlifting" for your throat — the extra effort builds real strength.',
      category: TipCategory.technique,
    ),
    EducationalTip(
      id: 'tech_04',
      title: 'The Shaker Exercise',
      body:
          'Lying flat and lifting just your head strengthens the muscles that open your upper food tube (UES). '
          'This exercise has strong research support for improving swallowing safety.',
      category: TipCategory.technique,
      source: 'Shaker et al., 2002',
    ),

    // ─── Motivation ───
    EducationalTip(
      id: 'moti_01',
      title: 'Progress Takes Time',
      body:
          'Most swallowing exercise programs show measurable improvement in 4–8 weeks. '
          'If progress feels slow, remember: your muscles and brain ARE changing — the results just need time to show.',
      category: TipCategory.motivation,
    ),
    EducationalTip(
      id: 'moti_02',
      title: 'Every Rep Counts',
      body:
          'Each exercise repetition sends signals through your neural pathways, making them a little stronger. '
          'Even on days when you don\'t feel like practicing, doing even a few reps keeps the momentum going.',
      category: TipCategory.motivation,
    ),
    EducationalTip(
      id: 'moti_03',
      title: 'Celebrate Small Wins',
      body:
          'Did you complete your session today? That\'s a win. Did you drink a whole glass of water? Win. '
          'Recovery is built on small victories — acknowledge each one.',
      category: TipCategory.motivation,
    ),

    // ─── Safety ───
    EducationalTip(
      id: 'safe_01',
      title: 'Signs of Aspiration',
      body:
          'Watch for: coughing during or after eating, a wet/gurgly voice after swallowing, '
          'or recurring chest infections. If you notice these, contact your care team promptly.',
      category: TipCategory.safety,
    ),
    EducationalTip(
      id: 'safe_02',
      title: 'Posture Matters',
      body:
          'Always sit upright at 90° when eating or drinking, and stay upright for 30 minutes after meals. '
          'Good posture helps gravity guide food safely into your stomach.',
      category: TipCategory.safety,
    ),
    EducationalTip(
      id: 'safe_03',
      title: 'When to Pause Exercises',
      body:
          'If you experience sharp pain, severe coughing, or difficulty breathing during exercises, stop and rest. '
          'Mild discomfort is normal, but pain is not. Report persistent issues to your care team.',
      category: TipCategory.safety,
    ),

    // ─── Lifestyle ───
    EducationalTip(
      id: 'life_01',
      title: 'Eating Socially',
      body:
          'Dysphagia can make social eating feel stressful. Talk to friends and family about your needs. '
          'Most people are understanding — and sharing a meal together is about more than just the food.',
      category: TipCategory.lifestyle,
    ),
    EducationalTip(
      id: 'life_02',
      title: 'Oral Hygiene Matters',
      body:
          'Good oral care reduces the risk of aspiration pneumonia. '
          'Brush teeth (and tongue!) at least twice daily, and rinse with alcohol-free mouthwash.',
      category: TipCategory.lifestyle,
    ),
    EducationalTip(
      id: 'life_03',
      title: 'Mindful Eating',
      body:
          'Minimize distractions during meals — turn off the TV, put down your phone. '
          'Focusing on each bite helps your brain coordinate swallowing more effectively.',
      category: TipCategory.lifestyle,
    ),
  ];

  /// Get tip for a given day (deterministic rotation)
  static EducationalTip tipOfTheDay() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return all[dayOfYear % all.length];
  }

  /// Get next N tips starting from today
  static List<EducationalTip> upcomingTips(int count) {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return List.generate(
      count,
      (i) => all[(dayOfYear + i) % all.length],
    );
  }
}
