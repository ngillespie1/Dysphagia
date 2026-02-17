import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/data_sync_service.dart';
import '../../core/services/service_locator.dart';
import '../../core/theme/premium_theme.dart';
import '../../data/models/food_entry.dart';

/// Compact hydration tracker card for the Today screen.
/// Shows water glass count with tap-to-add and animated fill.
class HydrationTrackerCard extends StatefulWidget {
  const HydrationTrackerCard({super.key});

  @override
  State<HydrationTrackerCard> createState() => _HydrationTrackerCardState();
}

class _HydrationTrackerCardState extends State<HydrationTrackerCard>
    with SingleTickerProviderStateMixin {
  final _dataService = getIt<DataSyncService>();
  late HydrationEntry _hydration;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _hydration = _dataService.getTodayHydration();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  Future<void> _addGlass() async {
    HapticFeedback.lightImpact();
    final updated = await _dataService.addGlass();
    _bounceController.forward().then((_) => _bounceController.reverse());
    setState(() => _hydration = updated);
  }

  Future<void> _removeGlass() async {
    if (_hydration.glassesDrunk <= 0) return;
    HapticFeedback.selectionClick();
    final updated = await _dataService.removeGlass();
    setState(() => _hydration = updated);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _hydration.progress;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : PremiumTheme.surfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('💧', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Hydration',
                style: PremiumTheme.headlineSmall.copyWith(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '${_hydration.mlDrunk}ml / ${_hydration.mlTarget}ml',
                style: PremiumTheme.labelSmall.copyWith(
                  color: PremiumTheme.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Water glass row
          Row(
            children: [
              // Glass icons
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(_hydration.targetGlasses, (i) {
                    final isFilled = i < _hydration.glassesDrunk;
                    return ScaleTransition(
                      scale: i == _hydration.glassesDrunk - 1
                          ? _bounceAnimation
                          : const AlwaysStoppedAnimation(1.0),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isFilled
                              ? PremiumTheme.info.withOpacity(0.12)
                              : isDark
                                  ? Colors.white.withOpacity(0.04)
                                  : PremiumTheme.surfaceVariant.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          border: isFilled
                              ? Border.all(
                                  color: PremiumTheme.info.withOpacity(0.2),
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Icon(
                            isFilled
                                ? Icons.water_drop_rounded
                                : Icons.water_drop_outlined,
                            size: 16,
                            color: isFilled
                                ? PremiumTheme.info
                                : isDark
                                    ? Colors.white.withOpacity(0.15)
                                    : PremiumTheme.textTertiary.withOpacity(0.4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Add/remove buttons
              Column(
                children: [
                  _MiniButton(
                    icon: Icons.add_rounded,
                    onTap: _addGlass,
                    color: PremiumTheme.primary,
                  ),
                  const SizedBox(height: 4),
                  _MiniButton(
                    icon: Icons.remove_rounded,
                    onTap: _removeGlass,
                    color: PremiumTheme.textTertiary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.06)
                      : PremiumTheme.surfaceVariant.withOpacity(0.5),
                  valueColor:
                      AlwaysStoppedAnimation(PremiumTheme.info),
                );
              },
            ),
          ),
          if (progress >= 1.0) ...[
            const SizedBox(height: 6),
            Text(
              '🎉 Hydration goal reached!',
              style: PremiumTheme.labelSmall.copyWith(
                color: PremiumTheme.success,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _MiniButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
