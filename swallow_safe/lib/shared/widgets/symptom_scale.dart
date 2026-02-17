import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/dimensions.dart';
import '../../core/constants/strings.dart';
import '../../core/services/service_locator.dart';
import '../../core/services/haptic_service.dart';
import '../../core/theme/premium_theme.dart';

/// Visual 1-5 symptom scale with icon buttons
class SymptomScale extends StatelessWidget {
  final String title;
  final SymptomType type;
  final int? selectedValue;
  final ValueChanged<int> onSelected;
  
  const SymptomScale({
    super.key,
    required this.title,
    required this.type,
    required this.selectedValue,
    required this.onSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = selectedValue == value;
            
            return _SymptomButton(
              value: value,
              type: type,
              isSelected: isSelected,
              onTap: () {
                getIt<HapticService>().mediumImpact();
                onSelected(value);
              },
            );
          }),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.symptomLabels.first,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              AppStrings.symptomLabels.last,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _SymptomButton extends StatelessWidget {
  final int value;
  final SymptomType type;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _SymptomButton({
    required this.value,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = PremiumTheme.symptomScale[value - 1];
    
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${type.name} level $value of 5${isSelected ? ", selected" : ""}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: AppDimensions.symptomButtonSize,
          height: AppDimensions.symptomButtonSize,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
          child: Center(
            child: Icon(
              _getIcon(),
              size: 28,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scale(duration: 150.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
  }
  
  IconData _getIcon() {
    switch (type) {
      case SymptomType.pain:
        return _painIcons[value - 1];
      case SymptomType.swallowingEase:
        return _swallowingIcons[value - 1];
      case SymptomType.dryMouth:
        return _dryMouthIcons[value - 1];
    }
  }
  
  // Pain level icons (face expressions)
  static const List<IconData> _painIcons = [
    Icons.sentiment_very_satisfied_rounded, // 1 - Great
    Icons.sentiment_satisfied_rounded,       // 2 - Good
    Icons.sentiment_neutral_rounded,         // 3 - Okay
    Icons.sentiment_dissatisfied_rounded,    // 4 - Difficult
    Icons.sentiment_very_dissatisfied_rounded, // 5 - Very difficult
  ];
  
  // Swallowing ease icons
  static const List<IconData> _swallowingIcons = [
    Icons.thumb_up_rounded,         // 1 - Great
    Icons.thumb_up_outlined,        // 2 - Good
    Icons.thumbs_up_down_rounded,   // 3 - Okay
    Icons.thumb_down_outlined,      // 4 - Difficult
    Icons.thumb_down_rounded,       // 5 - Very difficult
  ];
  
  // Dry mouth icons (water drop levels)
  static const List<IconData> _dryMouthIcons = [
    Icons.water_drop_rounded,       // 1 - Great (well hydrated)
    Icons.water_drop_outlined,      // 2 - Good
    Icons.opacity_rounded,          // 3 - Okay
    Icons.water_damage_outlined,    // 4 - Difficult
    Icons.warning_amber_rounded,    // 5 - Very dry
  ];
}

enum SymptomType {
  pain,
  swallowingEase,
  dryMouth,
}
