import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../bloc/onboarding_bloc.dart';

/// Premium name capture screen with floating label animation
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _fadeController;
  bool _isValid = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _validateName() {
    setState(() {
      _isValid = _nameController.text.trim().length >= 2;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
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

                    // Progress indicator (step 2 of 6)
                    _buildProgressIndicator(2, 6),

                    const SizedBox(height: 40),

                    // Title with serif font
                    Text(
                      'What should we\ncall you?',
                      style: PremiumTheme.displayMedium,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'This helps personalize your experience',
                      style: PremiumTheme.bodyMedium,
                    ),

                    const SizedBox(height: 48),

                    // Animated name input
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isFocused
                              ? PremiumTheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: _isFocused
                            ? PremiumTheme.accentGlow
                            : PremiumTheme.softShadow,
                      ),
                      child: TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.words,
                        style: PremiumTheme.headlineMedium,
                        decoration: InputDecoration(
                          hintText: 'Your name',
                          hintStyle: PremiumTheme.headlineMedium.copyWith(
                            color: PremiumTheme.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton(
                          onPressed: _isValid ? _continue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isValid
                                ? PremiumTheme.primary
                                : PremiumTheme.surfaceVariant,
                            foregroundColor: _isValid
                                ? Colors.white
                                : PremiumTheme.textTertiary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Continue',
                            style: PremiumTheme.button,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
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
        final isCurrent = index == current - 1;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: index < total - 1 ? 8 : 0),
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
    final name = _nameController.text.trim();

    context.read<OnboardingBloc>().add(SetName(name));
    context.go(AppRoutes.onboardingBaseline);
  }
}
