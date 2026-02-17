import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dimensions.dart';
import '../../../core/constants/strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../shared/widgets/glassmorphic_button.dart';

/// Onboarding screen - Headspace inspired
/// Soft, calming, welcoming design with rounded elements
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.favorite_rounded,
      color: PremiumTheme.accent,
      bgColor: PremiumTheme.accentSoft,
      title: 'Welcome to SwallowSafe',
      body: 'Your gentle companion on the path to recovery. We\'re here to support you every step of the way.',
    ),
    _OnboardingPage(
      icon: Icons.play_circle_rounded,
      color: PremiumTheme.primary,
      bgColor: PremiumTheme.primarySoft,
      title: 'Guided Exercises',
      body: 'Follow along with calming video exercises designed by specialists to help strengthen your swallowing.',
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      color: PremiumTheme.aiPrimary,
      bgColor: PremiumTheme.aiBackground,
      title: 'Track Your Progress',
      body: 'See how far you\'ve come with easy progress tracking and celebrate your daily achievements.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    HapticFeedback.mediumImpact();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _pages[_currentPage].bgColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Column(
              children: [
                // Header with skip
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingScreen,
                    vertical: AppDimensions.spacingM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: PremiumTheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'SwallowSafe',
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: PremiumTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Skip button
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          AppStrings.skip,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PremiumTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPageView(
                        page: _pages[index],
                        isActive: index == _currentPage,
                      );
                    },
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingScreen),
                  child: Column(
                    children: [
                      // Page indicators
                      Semantics(
                        label: 'Page ${_currentPage + 1} of ${_pages.length}',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (index) {
                            final isActive = _currentPage == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? _pages[_currentPage].color
                                    : PremiumTheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingXL),

                      // Action button
                      PrimaryButton(
                        label: _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Continue',
                        icon: _currentPage == _pages.length - 1
                            ? Icons.arrow_forward_rounded
                            : null,
                        onPressed: _nextPage,
                        backgroundColor: _pages[_currentPage].color,
                      ),

                      const SizedBox(height: AppDimensions.spacingM),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.body,
  });
}

class _OnboardingPageView extends StatefulWidget {
  final _OnboardingPage page;
  final bool isActive;

  const _OnboardingPageView({
    required this.page,
    required this.isActive,
  });

  @override
  State<_OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<_OnboardingPageView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_OnboardingPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingScreen),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration container
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: widget.page.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: widget.page.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.page.icon,
                    size: 64,
                    color: widget.page.color,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXXL),

            // Title
            Text(
              widget.page.title,
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: PremiumTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingM),

            // Body
            Text(
              widget.page.body,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: PremiumTheme.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
