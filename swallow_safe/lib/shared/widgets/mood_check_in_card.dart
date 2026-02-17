import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/daily_progress.dart';
import '../../core/models/check_in.dart';
import '../../core/theme/premium_theme.dart';
import 'glass_card.dart';
import 'illustrated_empty_state.dart';

/// Quick mood check-in card for the dashboard
/// One-tap mood selection with optional details
class MoodCheckInCard extends StatefulWidget {
  final CheckIn? todayCheckIn;
  final ValueChanged<CheckIn>? onCheckInSaved;
  final VoidCallback? onExpandTap;

  const MoodCheckInCard({
    super.key,
    this.todayCheckIn,
    this.onCheckInSaved,
    this.onExpandTap,
  });

  @override
  State<MoodCheckInCard> createState() => _MoodCheckInCardState();
}

class _MoodCheckInCardState extends State<MoodCheckInCard> {
  Mood? _selectedMood;
  bool _showDetails = false;
  int _swallowingDifficulty = 5;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.todayCheckIn != null) {
      _selectedMood = widget.todayCheckIn!.overallFeeling;
      _swallowingDifficulty = widget.todayCheckIn!.swallowingDifficulty;
      _notesController.text = widget.todayCheckIn!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(PremiumTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: PremiumTheme.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: PremiumTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.todayCheckIn != null
                          ? 'Today\'s Check-In'
                          : 'How are you feeling?',
                      style: PremiumTheme.headlineSmall,
                    ),
                    if (widget.todayCheckIn == null)
                      Text(
                        'Tap to record your mood',
                        style: PremiumTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (_selectedMood != null && !_showDetails)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _showDetails = true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PremiumTheme.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_selectedMood!.emoji,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          _selectedMood!.label,
                          style: PremiumTheme.labelMedium.copyWith(
                            color: PremiumTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Mood selection row
          _buildMoodSelector(),

          // Expanded details section
          if (_showDetails) ...[
            const SizedBox(height: 20),
            _buildDetailsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: Mood.values.map((mood) {
        final isSelected = _selectedMood == mood;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedMood = mood;
              if (widget.todayCheckIn == null && !_showDetails) {
                // Quick save for new check-in
                _saveCheckIn();
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected
                  ? PremiumTheme.primary.withOpacity(0.15)
                  : const Color(0xFFF5F7F8),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: PremiumTheme.primary, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: PremiumTheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: TextStyle(fontSize: isSelected ? 26 : 22),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Swallowing difficulty slider
        Text(
          'Swallowing difficulty',
          style: PremiumTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Easy',
              style: PremiumTheme.bodySmall,
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: PremiumTheme.primary,
                  inactiveTrackColor: PremiumTheme.primarySoft,
                  thumbColor: PremiumTheme.primary,
                  overlayColor: PremiumTheme.primary.withOpacity(0.2),
                ),
                child: Slider(
                  value: _swallowingDifficulty.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() => _swallowingDifficulty = value.round());
                  },
                ),
              ),
            ),
            Text(
              'Hard',
              style: PremiumTheme.bodySmall,
            ),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: PremiumTheme.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_swallowingDifficulty/10',
              style: PremiumTheme.labelMedium.copyWith(
                color: PremiumTheme.primary,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Notes field
        Text(
          'Notes (optional)',
          style: PremiumTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: PremiumTheme.bodyMedium.copyWith(
            color: PremiumTheme.textPrimary,
          ),
          decoration: PremiumTheme.inputDecoration(
            hintText: 'How was your day?',
          ),
        ),

        const SizedBox(height: 16),

        // Save button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedMood != null ? _saveCheckIn : null,
            style: PremiumTheme.primaryButton,
            child: const Text('Save Check-In'),
          ),
        ),
      ],
    );
  }

  void _saveCheckIn() {
    if (_selectedMood == null) return;

    final checkIn = CheckIn.create(
      overallFeeling: _selectedMood!,
      swallowingDifficulty: _swallowingDifficulty,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    widget.onCheckInSaved?.call(checkIn);
    setState(() => _showDetails = false);
  }
}

/// Recent check-ins feed for dashboard
class RecentCheckInsFeed extends StatelessWidget {
  final List<CheckIn> checkIns;
  final int maxItems;
  final VoidCallback? onViewAll;

  const RecentCheckInsFeed({
    super.key,
    required this.checkIns,
    this.maxItems = 3,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (checkIns.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Recent Check-Ins',
              style: PremiumTheme.headlineSmall,
            ),
            const Spacer(),
            if (checkIns.length > maxItems)
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View All',
                  style: PremiumTheme.labelMedium.copyWith(
                    color: PremiumTheme.primary,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Check-in items
        ...checkIns.take(maxItems).map((checkIn) => _CheckInItem(checkIn: checkIn)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const IllustratedEmptyState(
      type: EmptyStateType.checkIn,
      title: 'Your story starts here',
      subtitle:
          'Each check-in helps you and your care team see how you\'re doing over time. You\'ve got this!',
    );
  }
}

class _CheckInItem extends StatelessWidget {
  final CheckIn checkIn;

  const _CheckInItem({required this.checkIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(PremiumTheme.spacingM),
      decoration: BoxDecoration(
        color: PremiumTheme.bgCard,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusMedium),
        border: Border.all(
          color: const Color(0xFFE8ECEF),
        ),
      ),
      child: Row(
        children: [
          // Mood emoji
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PremiumTheme.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                checkIn.overallFeeling.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      checkIn.dateLabel,
                      style: PremiumTheme.labelMedium,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(checkIn.swallowingDifficulty)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${checkIn.swallowingDifficulty}/10',
                        style: PremiumTheme.labelSmall.copyWith(
                          color: _getDifficultyColor(checkIn.swallowingDifficulty),
                        ),
                      ),
                    ),
                  ],
                ),
                if (checkIn.notes != null && checkIn.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    checkIn.notes!,
                    style: PremiumTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    if (difficulty <= 3) return PremiumTheme.success;
    if (difficulty <= 6) return PremiumTheme.warning;
    return PremiumTheme.error;
  }
}
