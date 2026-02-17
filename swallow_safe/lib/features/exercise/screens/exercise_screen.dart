import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../shared/widgets/exercise_progress_dots.dart';
import '../../../shared/widgets/glassmorphic_button.dart';
import '../../../shared/widgets/why_exercise_panel.dart';
import '../bloc/session_bloc.dart';
import '../widgets/exercise_video_player.dart';
import '../widgets/guided_exercise_overlay.dart';

/// Immersive exercise screen - PreHab inspired
/// Full-screen video with floating controls and progress indicators
class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    // Always reload the session when this screen opens,
    // regardless of the current SessionBloc state (handles re-entry
    // after SessionComplete, stale SessionReady, etc.)
    context.read<SessionBloc>().add(const LoadSession());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SessionBloc, SessionState>(
      listener: (context, state) {
        if (state is SessionComplete) {
          context.go(AppRoutes.sessionComplete);
        }
        // Auto-start the session once it's ready
        if (state is SessionReady && !_sessionStarted) {
          _sessionStarted = true;
          context.read<SessionBloc>().add(const StartSession());
        }
      },
      builder: (context, state) {
        if (state is SessionActive) {
          return _ExerciseView(state: state);
        }

        if (state is SessionTransitioning) {
          return _TransitionView(state: state);
        }

        if (state is SessionError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Colors.white70, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(
              color: PremiumTheme.accent,
            ),
          ),
        );
      },
    );
  }
}

class _ExerciseView extends StatefulWidget {
  final SessionActive state;

  const _ExerciseView({required this.state});

  @override
  State<_ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<_ExerciseView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _tutorVoiceEnabled = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Set to immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    
    // Pulse animation for the done button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<SessionBloc>();
    if (state == AppLifecycleState.paused) {
      bloc.add(const PauseSession());
    } else if (state == AppLifecycleState.resumed) {
      bloc.add(const ResumeSession());
    }
  }

  void _skipExercise() {
    HapticFeedback.lightImpact();
    context.read<SessionBloc>().add(const CompleteExercise());
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.state.currentExercise;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe left to skip to next exercise
        if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
          _skipExercise();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video player (full screen, auto-looping)
          // Cache-aware: uses local file when available, shows illustrated
          // fallback with written instructions when offline.
          Positioned.fill(
            child: ExerciseVideoPlayer(
              videoUrl: exercise.videoUrl,
              isMuted: !_tutorVoiceEnabled,
              isPaused: widget.state.isPaused,
              exerciseName: exercise.name,
              instructions: exercise.instructions,
            ),
          ),

          // Top gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingScreen),
                child: Column(
                  children: [
                    // Close button and progress
                    Row(
                      children: [
                        // Close button (glassmorphic)
                        GlassmorphicIconButton(
                          icon: Icons.close_rounded,
                          size: 48,
                          onPressed: () => _showExitConfirmation(context),
                        ),
                        
                        const Spacer(),
                        
                        // Progress dots
                        ExerciseProgressDots(
                          totalCount: widget.state.totalExercises,
                          currentIndex: widget.state.exerciseNumber - 1,
                          completedCount: widget.state.exerciseNumber - 1,
                        ),
                        
                        const Spacer(),
                        
                        // Sound toggle
                        GlassmorphicIconButton(
                          icon: _tutorVoiceEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          size: 48,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() => _tutorVoiceEnabled = !_tutorVoiceEnabled);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Guided exercise overlay (timer, reps, hold)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingScreen),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Exercise info card (glassmorphic)
                    _ExerciseInfoCard(
                      name: exercise.name,
                      repsDisplay: exercise.repsDisplay,
                      instructions: exercise.instructions,
                    ),

                    const SizedBox(height: AppDimensions.spacingS),

                    // Why this exercise? (educational panel)
                    WhyExercisePanel(
                      exerciseId: exercise.id,
                      exerciseName: exercise.name,
                    ),

                    const SizedBox(height: AppDimensions.spacingL),

                    // Guided exercise overlay with timer + rep counter
                    GuidedExerciseOverlay(
                      key: ValueKey('guided_${exercise.id}'),
                      exercise: exercise,
                      onComplete: () {
                        context.read<SessionBloc>().add(const CompleteExercise());
                      },
                      onSkip: () {
                        HapticFeedback.lightImpact();
                        context.read<SessionBloc>().add(const CompleteExercise());
                      },
                    ),

                    const SizedBox(height: AppDimensions.spacingM),

                    // Skip / Next exercise button — prominent
                    GestureDetector(
                      onTap: _skipExercise,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.state.isLastExercise
                                  ? 'Skip & finish'
                                  : 'Skip to next exercise',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white.withOpacity(0.85),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Subtle swipe hint
                    Text(
                      'or swipe left to skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Pause overlay
          if (widget.state.isPaused) _buildPauseOverlay(context),
        ],
      ),
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_filled_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              Text(
                'Paused',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXL),
              PrimaryButton(
                label: 'Resume',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  context.read<SessionBloc>().add(const ResumeSession());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ExitConfirmationSheet(
        onContinue: () => Navigator.pop(ctx),
        onExit: () {
          Navigator.pop(ctx);
          context.read<SessionBloc>().add(const EndSession());
          context.go(AppRoutes.home);
        },
      ),
    );
  }
}

class _ExerciseInfoCard extends StatelessWidget {
  final String name;
  final String repsDisplay;
  final String? instructions;

  const _ExerciseInfoCard({
    required this.name,
    required this.repsDisplay,
    this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingCard),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Exercise name
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: AppDimensions.spacingS),
              
              // Reps display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: PremiumTheme.accent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusPill),
                ),
                child: Text(
                  repsDisplay,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PremiumTheme.accent,
                  ),
                ),
              ),
              
              // Instructions
              if (instructions != null && instructions!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  instructions!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DoneButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Mark exercise as done',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: AppDimensions.buttonHeightLarge,
          decoration: BoxDecoration(
            gradient: PremiumTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: PremiumTheme.accent.withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_rounded,
                size: 28,
                color: Colors.white,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Done',
                style: GoogleFonts.dmSans(
                  fontSize: AppDimensions.fontSizeLabel,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExitConfirmationSheet extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onExit;

  const _ExitConfirmationSheet({
    required this.onContinue,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingScreen),
      decoration: const BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.bottomSheetRadius),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PremiumTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: AppDimensions.spacingXL),
            
            Text(
              'Heading out?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            const SizedBox(height: AppDimensions.spacingM),
            
            Text(
              'No worries — but your progress from this session won\'t be saved.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PremiumTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppDimensions.spacingXL),
            
            PrimaryButton(
              label: 'Keep going',
              icon: Icons.play_arrow_rounded,
              onPressed: onContinue,
            ),
            
            const SizedBox(height: AppDimensions.spacingM),
            
            TextButton(
              onPressed: onExit,
              child: Text(
                'End session',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PremiumTheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// BREATHING TRANSITION SCREEN
// ═══════════════════════════════════════════════════════════════════

class _TransitionView extends StatefulWidget {
  final SessionTransitioning state;

  const _TransitionView({required this.state});

  @override
  State<_TransitionView> createState() => _TransitionViewState();
}

class _TransitionViewState extends State<_TransitionView>
    with TickerProviderStateMixin {
  // Entrance animation
  late AnimationController _entranceController;
  late Animation<double> _entranceFade;
  late Animation<double> _entranceScale;

  // Breathing circle animation — one full breath cycle (inhale + exhale)
  late AnimationController _breathController;
  late Animation<double> _breathScale;
  late Animation<double> _breathOpacity;

  // Preview card slide-up
  late AnimationController _previewController;
  late Animation<Offset> _previewSlide;
  late Animation<double> _previewFade;

  // Auto-advance timer
  bool _autoAdvanced = false;

  // Breathing phase label
  String _breathLabel = 'Breathe in…';

  @override
  void initState() {
    super.initState();

    // ── Entrance ──
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _entranceScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    // ── Breathing circle (7 seconds total: 4s inhale + 3s exhale) ──
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _breathScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 57, // ~4s inhale
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 43, // ~3s exhale
      ),
    ]).animate(_breathController);
    _breathOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.5), weight: 57),
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.25), weight: 43),
    ]).animate(_breathController);

    // Update label at midpoint
    _breathController.addListener(() {
      if (!mounted) return;
      final newLabel =
          _breathController.value < 0.57 ? 'Breathe in…' : 'Breathe out…';
      if (newLabel != _breathLabel) {
        setState(() => _breathLabel = newLabel);
      }
    });

    // ── Preview card ──
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _previewSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOutCubic,
    ));
    _previewFade = CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOut,
    );

    // Kick off sequence
    HapticFeedback.mediumImpact();
    _entranceController.forward();
    _breathController.forward();

    // Show preview card after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _previewController.forward();
    });

    // Auto-advance once the breathing cycle completes
    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted && !_autoAdvanced) {
        _autoAdvanced = true;
        // Short pause after breath completes, then advance
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) _continueToNext();
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _breathController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  void _continueToNext() {
    HapticFeedback.mediumImpact();
    context.read<SessionBloc>().add(const ContinueToNext());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextExercise = widget.state.nextExercise;
    final completedIdx = widget.state.completedExerciseIndex + 1;
    final totalExercises = widget.state.program.exercises.length;

    return Scaffold(
      backgroundColor:
          isDark ? PremiumTheme.darkBackground : PremiumTheme.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _continueToNext,
          child: AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return Opacity(
                opacity: _entranceFade.value,
                child: Transform.scale(
                  scale: _entranceScale.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // ─── Celebration message ───
                  Text(
                    '✨ Nice work!',
                    style: PremiumTheme.headlineLarge.copyWith(
                      color: isDark ? Colors.white : PremiumTheme.textPrimary,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completedIdx of $totalExercises done',
                    style: PremiumTheme.bodyMedium.copyWith(
                      color: PremiumTheme.textTertiary,
                    ),
                  ),

                  const Spacer(),

                  // ─── Breathing circle ───
                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 140 * _breathScale.value,
                            height: 140 * _breathScale.value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  PremiumTheme.primary
                                      .withOpacity(_breathOpacity.value + 0.15),
                                  PremiumTheme.primaryLight
                                      .withOpacity(_breathOpacity.value),
                                  PremiumTheme.primarySoft
                                      .withOpacity(_breathOpacity.value * 0.5),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumTheme.primary
                                      .withOpacity(_breathOpacity.value * 0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _breathLabel,
                            style: PremiumTheme.bodyMedium.copyWith(
                              color: isDark
                                  ? Colors.white.withOpacity(0.6)
                                  : PremiumTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const Spacer(),

                  // ─── Next exercise preview card ───
                  SlideTransition(
                    position: _previewSlide,
                    child: FadeTransition(
                      opacity: _previewFade,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? PremiumTheme.darkCardColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : PremiumTheme.surfaceVariant,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: PremiumTheme.shadow,
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color:
                                        PremiumTheme.accent.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.skip_next_rounded,
                                      size: 16,
                                      color: PremiumTheme.accent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Up next',
                                  style: PremiumTheme.labelSmall.copyWith(
                                    color: PremiumTheme.textTertiary,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              nextExercise.name,
                              style: PremiumTheme.headlineSmall.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : PremiumTheme.textPrimary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nextExercise.repsDisplay,
                              style: PremiumTheme.bodySmall.copyWith(
                                color: PremiumTheme.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (nextExercise.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                nextExercise.description,
                                style: PremiumTheme.bodySmall.copyWith(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.5)
                                      : PremiumTheme.textTertiary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tap to skip hint
                  Text(
                    'Tap anywhere to continue',
                    style: PremiumTheme.labelSmall.copyWith(
                      color: PremiumTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
