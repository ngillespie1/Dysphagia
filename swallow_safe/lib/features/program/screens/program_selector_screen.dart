import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/program.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../bloc/program_bloc.dart';
import '../bloc/program_event.dart';
import '../bloc/program_state.dart';

/// Program selector screen - Choose from condition-based programs
/// Apple-style card selection with clean typography
class ProgramSelectorScreen extends StatefulWidget {
  const ProgramSelectorScreen({super.key});

  @override
  State<ProgramSelectorScreen> createState() => _ProgramSelectorScreenState();
}

class _ProgramSelectorScreenState extends State<ProgramSelectorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ProgramType? _selectedType;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: PremiumTheme.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),

              // Program list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  children: [
                    // Title and description
                    Text(
                      'Choose Your Program',
                      style: PremiumTheme.displayLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select the program prescribed by your healthcare provider. Each program is tailored to specific conditions and recovery goals.',
                      style: PremiumTheme.bodyLarge,
                    ),

                    const SizedBox(height: 32),

                    // Program cards
                    ...ProgramType.values.asMap().entries.map((entry) {
                      final index = entry.key;
                      final type = entry.value;
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final delay = index * 0.1;
                          final progress = (_animationController.value - delay)
                              .clamp(0.0, 1.0);
                          final curve = Curves.easeOutCubic.transform(progress);

                          return Transform.translate(
                            offset: Offset(0, 20 * (1 - curve)),
                            child: Opacity(
                              opacity: curve,
                              child: child,
                            ),
                          );
                        },
                        child: _ProgramCard(
                          type: type,
                          isSelected: _selectedType == type,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedType = type;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Continue button
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.close_rounded,
                color: PremiumTheme.textTertiary,
                size: 22,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Programs',
            style: PremiumTheme.headlineMedium,
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BlocListener<ProgramBloc, ProgramState>(
      listener: (context, state) {
        if (state is ProgramLoaded) {
          context.go(AppRoutes.home);
        }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BlocBuilder<ProgramBloc, ProgramState>(
          builder: (context, state) {
            final isLoading = state is ProgramLoading;

            return SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _selectedType != null && !isLoading
                      ? () {
                          HapticFeedback.mediumImpact();
                          context.read<ProgramBloc>().add(
                                SelectProgramType(_selectedType!),
                              );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType != null
                        ? PremiumTheme.primary
                        : PremiumTheme.surfaceVariant,
                    foregroundColor: _selectedType != null
                        ? Colors.white
                        : PremiumTheme.textTertiary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final ProgramType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? PremiumTheme.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? PremiumTheme.primary.withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? PremiumTheme.primary.withOpacity(0.1)
                          : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        type.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: PremiumTheme.headlineSmall.copyWith(
                            color: isSelected
                                ? PremiumTheme.primary
                                : PremiumTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.description,
                          style: PremiumTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? PremiumTheme.primary : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? PremiumTheme.primary
                            : PremiumTheme.textMuted,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
