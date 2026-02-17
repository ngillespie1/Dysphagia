import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../bloc/onboarding_bloc.dart';

/// Baseline symptom screen — Step 3 of 6
/// Asks "How are you feeling today?" with friendly emoji sliders
/// so the app can personalize intensity and show progress from day 1.
class BaselineSymptomScreen extends StatefulWidget {
  const BaselineSymptomScreen({super.key});

  @override
  State<BaselineSymptomScreen> createState() => _BaselineSymptomScreenState();
}

class _BaselineSymptomScreenState extends State<BaselineSymptomScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  double _painLevel = 3;
  double _swallowingEase = 3;
  double _energyLevel = 3;

  final _labels = const ['Great', 'Good', 'Okay', 'Hard', 'Tough'];
  final _emojis = const ['😊', '🙂', '😐', '😟', '😣'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: PremiumTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Semantics(
                      button: true,
                      label: 'Go back',
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: PremiumTheme.softShadow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: PremiumTheme.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Progress indicator (step 3 of 6)
                    _buildProgressIndicator(3, 6),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'How are you\nfeeling today?',
                      style: PremiumTheme.displayMedium,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'This helps us personalise your starting point. You can always update these later.',
                      style: PremiumTheme.bodyMedium.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Symptom sliders
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _SymptomSlider(
                              label: 'Pain level',
                              icon: Icons.favorite_rounded,
                              iconColor: PremiumTheme.error,
                              value: _painLevel,
                              emojis: _emojis,
                              labels: _labels,
                              onChanged: (v) =>
                                  setState(() => _painLevel = v),
                            ),

                            const SizedBox(height: 28),

                            _SymptomSlider(
                              label: 'Swallowing ease',
                              icon: Icons.water_drop_rounded,
                              iconColor: PremiumTheme.primary,
                              value: _swallowingEase,
                              emojis: const [
                                '😣',
                                '😟',
                                '😐',
                                '🙂',
                                '😊'
                              ],
                              labels: const [
                                'Tough',
                                'Hard',
                                'Okay',
                                'Good',
                                'Great'
                              ],
                              onChanged: (v) =>
                                  setState(() => _swallowingEase = v),
                            ),

                            const SizedBox(height: 28),

                            _SymptomSlider(
                              label: 'Energy today',
                              icon: Icons.bolt_rounded,
                              iconColor: PremiumTheme.accent,
                              value: _energyLevel,
                              emojis: const [
                                '😴',
                                '🥱',
                                '😐',
                                '😊',
                                '🤩'
                              ],
                              labels: const [
                                'Low',
                                'Tired',
                                'Okay',
                                'Good',
                                'Great'
                              ],
                              onChanged: (v) =>
                                  setState(() => _energyLevel = v),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text('Continue', style: PremiumTheme.button),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Skip
                    Center(
                      child: TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          context.go(AppRoutes.onboardingGoals);
                        },
                        child: Text(
                          'Skip for now',
                          style: PremiumTheme.bodySmall.copyWith(
                            color: PremiumTheme.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int current, int total) {
    return Row(
      children: List.generate(total, (index) {
        final isActive = index < current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? PremiumTheme.primary
                  : PremiumTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    context.read<OnboardingBloc>().add(SetBaselineSymptoms(
          painLevel: _painLevel.round(),
          swallowingEase: _swallowingEase.round(),
          energyLevel: _energyLevel.round(),
        ));
    context.go(AppRoutes.onboardingGoals);
  }
}

/// A symptom slider with emoji feedback
class _SymptomSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final double value;
  final List<String> emojis;
  final List<String> labels;
  final ValueChanged<double> onChanged;

  const _SymptomSlider({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.emojis,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final index = (value - 1).round().clamp(0, 4);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: PremiumTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Text(label, style: PremiumTheme.headlineSmall),
              const Spacer(),
              Text(
                emojis[index],
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Slider
          Semantics(
            label: '$label slider, currently ${labels[index]}',
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: iconColor,
                inactiveTrackColor: iconColor.withOpacity(0.15),
                thumbColor: iconColor,
                overlayColor: iconColor.withOpacity(0.1),
                trackHeight: 6,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: value,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  onChanged(v);
                },
              ),
            ),
          ),

          // Label
          Center(
            child: Text(
              labels[index],
              style: PremiumTheme.labelMedium.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
