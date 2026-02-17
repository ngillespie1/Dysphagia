import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/premium_theme.dart';
import '../../features/gamification/bloc/gamification_bloc.dart';

/// Main scaffold with premium floating glass bottom navigation bar.
/// Listens for gamification XP events and shows toasts.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<GamificationBloc, GamificationState>(
      listenWhen: (prev, curr) {
        if (curr is GamificationLoaded) {
          return curr.xpJustEarned != null || curr.badgeJustUnlocked != null;
        }
        return false;
      },
      listener: (context, state) {
        if (state is! GamificationLoaded) return;

        if (state.xpJustEarned != null && state.xpJustEarned! > 0) {
          _showXPSnackBar(context, state);
        }

        Future.delayed(const Duration(milliseconds: 2500), () {
          if (context.mounted) {
            context
                .read<GamificationBloc>()
                .add(const DismissGamificationToast());
          }
        });
      },
      child: Scaffold(
        body: child,
        extendBody: true,
        bottomNavigationBar: const _FloatingGlassNavBar(),
      ),
    );
  }

  void _showXPSnackBar(BuildContext context, GamificationLoaded state) {
    final badge = state.badgeJustUnlocked;
    final xp = state.xpJustEarned ?? 0;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        backgroundColor: PremiumTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Text('⚡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              '+$xp XP',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 10),
              Text(
                badge.icon,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  badge.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (state.leveledUp) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LEVEL UP! 🎉',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FLOATING GLASS BOTTOM NAV BAR
// ═══════════════════════════════════════════════════════════════════

class _FloatingGlassNavBar extends StatefulWidget {
  const _FloatingGlassNavBar();

  @override
  State<_FloatingGlassNavBar> createState() => _FloatingGlassNavBarState();
}

class _FloatingGlassNavBarState extends State<_FloatingGlassNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  static const _tabs = [
    _TabDef(
      route: AppRoutes.home,
      activeIcon: Icons.wb_sunny_rounded,
      inactiveIcon: Icons.wb_sunny_outlined,
      label: 'Today',
    ),
    _TabDef(
      route: AppRoutes.journey,
      activeIcon: Icons.route_rounded,
      inactiveIcon: Icons.route_outlined,
      label: 'Journey',
    ),
    _TabDef(
      route: AppRoutes.settings,
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'Me',
    ),
  ];

  int _activeIndex(String location) {
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].route) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeIdx = _activeIndex(location);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottomPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : PremiumTheme.shadowColor.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : PremiumTheme.shadowColor.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        PremiumTheme.darkCardColor.withOpacity(0.85),
                        PremiumTheme.darkSurface.withOpacity(0.75),
                      ]
                    : [
                        Colors.white.withOpacity(0.88),
                        Colors.white.withOpacity(0.78),
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabWidth = constraints.maxWidth / _tabs.length;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sliding pill indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: tabWidth * activeIdx +
                          (tabWidth - 56) / 2, // center the pill
                      top: 8,
                      child: Container(
                        width: 56,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? PremiumTheme.primary.withOpacity(0.15)
                              : PremiumTheme.primarySoft,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTheme.primary.withOpacity(
                                  isDark ? 0.08 : 0.12),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tab items
                    Row(
                      children: List.generate(_tabs.length, (i) {
                        final tab = _tabs[i];
                        final isActive = i == activeIdx;

                        return Expanded(
                          child: _GlassNavItem(
                            tab: tab,
                            isActive: isActive,
                            isDark: isDark,
                            onTap: () {
                              if (i != activeIdx) {
                                HapticFeedback.selectionClick();
                                _bounceController.forward(from: 0.0);
                                context.go(tab.route);
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TabDef {
  final String route;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _TabDef({
    required this.route,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

class _GlassNavItem extends StatelessWidget {
  final _TabDef tab;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _GlassNavItem({
    required this.tab,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tab.label,
      selected: isActive,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with bounce scale on active
              TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: isActive ? 1.0 : 1.0,
                  end: isActive ? 1.15 : 1.0,
                ),
                duration: const Duration(milliseconds: 280),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle glow behind active icon
                    if (isActive)
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTheme.primary.withOpacity(0.25),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    Icon(
                      isActive ? tab.activeIcon : tab.inactiveIcon,
                      size: 24,
                      color: isActive
                          ? PremiumTheme.primary
                          : (isDark
                              ? Colors.white.withOpacity(0.45)
                              : PremiumTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? PremiumTheme.primary
                      : (isDark
                          ? Colors.white.withOpacity(0.45)
                          : PremiumTheme.textTertiary),
                ),
                child: Text(tab.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
