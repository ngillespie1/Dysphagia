import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/data_sync_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../data/models/check_in.dart';
import '../../../shared/widgets/animated_mesh_background.dart';
import '../../../shared/widgets/glass_card.dart';

/// Premium Check-in screen for daily symptom tracking
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  
  int? _painLevel;
  int? _swallowingEase;
  int? _dryMouth;
  String? _overallFeeling;
  final _notesController = TextEditingController();
  
  bool _isSaving = false;
  bool _hasExistingEntry = false;
  List<CheckIn> _recentCheckIns = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadData();
  }

  Future<void> _loadData() async {
    final dataService = getIt<DataSyncService>();
    
    // Load today's check-in if exists (now typed CheckIn)
    final todayCheckIn = await dataService.getTodayCheckIn();
    if (todayCheckIn != null) {
      setState(() {
        _hasExistingEntry = true;
        _painLevel = todayCheckIn.painLevel;
        _swallowingEase = todayCheckIn.swallowingEase;
        _dryMouth = todayCheckIn.dryMouth;
        _overallFeeling = todayCheckIn.overallFeeling;
        _notesController.text = todayCheckIn.notes ?? '';
      });
    }
    
    // Load recent check-ins
    final recent = await dataService.getRecentCheckIns(limit: 5);
    setState(() => _recentCheckIns = recent);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isComplete => 
      _painLevel != null && 
      _swallowingEase != null && 
      _dryMouth != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedMeshBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How are you feeling?',
                              style: PremiumTheme.displayMedium,
                            ),
                            const SizedBox(height: 8),
                            if (_hasExistingEntry)
                              Container(
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
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 14,
                                      color: PremiumTheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Updating today\'s check-in',
                                      style: PremiumTheme.labelMedium.copyWith(
                                        color: PremiumTheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Pain level
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: _SymptomCard(
                          title: 'Comfort Level',
                          description: 'How does your throat feel?',
                          icon: Icons.sentiment_dissatisfied_rounded,
                          iconColor: PremiumTheme.error,
                          child: _SymptomScale(
                            selectedValue: _painLevel,
                            labels: const ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'],
                            colors: const [
                              Color(0xFF4CAF50),
                              Color(0xFF8BC34A),
                              Color(0xFFFFEB3B),
                              Color(0xFFFF9800),
                              Color(0xFFF44336),
                            ],
                            onSelected: (value) {
                              HapticFeedback.selectionClick();
                              setState(() => _painLevel = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Swallowing ease
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: _SymptomCard(
                          title: 'Swallowing Ease',
                          description: 'How is swallowing going today?',
                          icon: Icons.water_drop_rounded,
                          iconColor: PremiumTheme.primaryLight,
                          child: _SymptomScale(
                            selectedValue: _swallowingEase,
                            labels: const ['Very Hard', 'Hard', 'Okay', 'Easy', 'Very Easy'],
                            colors: const [
                              Color(0xFFF44336),
                              Color(0xFFFF9800),
                              Color(0xFFFFEB3B),
                              Color(0xFF8BC34A),
                              Color(0xFF4CAF50),
                            ],
                            onSelected: (value) {
                              HapticFeedback.selectionClick();
                              setState(() => _swallowingEase = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Dry mouth
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: _SymptomCard(
                          title: 'Dry Mouth',
                          description: 'Any dryness today?',
                          icon: Icons.wb_sunny_rounded,
                          iconColor: PremiumTheme.warning,
                          child: _SymptomScale(
                            selectedValue: _dryMouth,
                            labels: const ['None', 'Mild', 'Moderate', 'Severe', 'Extreme'],
                            colors: const [
                              Color(0xFF4CAF50),
                              Color(0xFF8BC34A),
                              Color(0xFFFFEB3B),
                              Color(0xFFFF9800),
                              Color(0xFFF44336),
                            ],
                            onSelected: (value) {
                              HapticFeedback.selectionClick();
                              setState(() => _dryMouth = value);
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Overall feeling
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: _SymptomCard(
                          title: 'Overall Mood',
                          description: 'How are you feeling right now?',
                          icon: Icons.emoji_emotions_rounded,
                          iconColor: PremiumTheme.accent,
                          child: _MoodSelector(
                            selectedMood: _overallFeeling,
                            onSelected: (mood) {
                              HapticFeedback.selectionClick();
                              setState(() => _overallFeeling = mood);
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    // Notes
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Anything else on your mind?', style: PremiumTheme.headlineSmall),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                style: PremiumTheme.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: 'Jot down anything you\'d like to remember…',
                                  hintStyle: PremiumTheme.bodyMedium.copyWith(
                                    color: PremiumTheme.textTertiary,
                                  ),
                                  filled: true,
                                  fillColor: PremiumTheme.bgWarm,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Recent check-ins
                    if (_recentCheckIns.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: _buildRecentCheckIns(),
                        ),
                      ),
                    
                    // Bottom padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 120),
                    ),
                  ],
                ),
                
                // Save button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      top: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          PremiumTheme.bgCream.withOpacity(0),
                          PremiumTheme.bgCream.withOpacity(0.9),
                          PremiumTheme.bgCream,
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _isComplete && !_isSaving ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isComplete 
                            ? PremiumTheme.primary 
                            : PremiumTheme.textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _hasExistingEntry ? 'Update check-in' : 'Save check-in',
                                  style: PremiumTheme.button.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCheckIns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent check-ins', style: PremiumTheme.headlineSmall),
        const SizedBox(height: 12),
        ...(_recentCheckIns.take(3).map((checkIn) {
          final date = DateTime.parse(checkIn.date);
          final isToday = _isToday(date);
          final feeling = checkIn.overallFeeling;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PremiumTheme.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getMoodEmoji(feeling),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isToday ? 'Today' : _formatDate(date),
                          style: PremiumTheme.labelLarge,
                        ),
                        Text(
                          'Pain: ${_getLevelLabel(checkIn.painLevel)} • Swallowing: ${_getLevelLabel(checkIn.swallowingEase)}',
                          style: PremiumTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getMoodEmoji(String? feeling) {
    switch (feeling) {
      case 'great': return '😊';
      case 'good': return '🙂';
      case 'okay': return '😐';
      case 'bad': return '😕';
      case 'terrible': return '😢';
      default: return '📋';
    }
  }

  String _getLevelLabel(int level) {
    switch (level) {
      case 0: return 'None';
      case 1: return 'Mild';
      case 2: return 'Moderate';
      case 3: return 'Severe';
      case 4: return 'Extreme';
      default: return '-';
    }
  }

  Future<void> _save() async {
    if (!_isComplete) return;
    
    setState(() => _isSaving = true);
    
    try {
      final dataService = getIt<DataSyncService>();
      await dataService.saveCheckIn(
        painLevel: _painLevel!,
        swallowingEase: _swallowingEase!,
        dryMouth: _dryMouth!,
        overallFeeling: _overallFeeling,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );
      
      HapticFeedback.mediumImpact();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Check-in saved — thank you 🙏'),
              ],
            ),
            backgroundColor: PremiumTheme.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        
        // Reload data
        await _loadData();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _SymptomCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _SymptomCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: PremiumTheme.headlineSmall),
                    Text(description, style: PremiumTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SymptomScale extends StatelessWidget {
  final int? selectedValue;
  final List<String> labels;
  final List<Color> colors;
  final ValueChanged<int> onSelected;

  const _SymptomScale({
    required this.selectedValue,
    required this.labels,
    required this.colors,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        final isSelected = selectedValue == index;
        final color = colors[index];
        
        return Expanded(
          child: Semantics(
            button: true,
            selected: isSelected,
            label: '${labels[index]}, level ${index + 1} of ${labels.length}',
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: index < labels.length - 1 ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected 
                      ? Border.all(color: color, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${index + 1}',
                      style: PremiumTheme.labelLarge.copyWith(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[index],
                      style: PremiumTheme.labelSmall.copyWith(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.9) 
                            : PremiumTheme.textTertiary,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onSelected;

  const _MoodSelector({
    required this.selectedMood,
    required this.onSelected,
  });

  static const moods = [
    {'id': 'great', 'emoji': '😊', 'label': 'Great'},
    {'id': 'good', 'emoji': '🙂', 'label': 'Good'},
    {'id': 'okay', 'emoji': '😐', 'label': 'Okay'},
    {'id': 'bad', 'emoji': '😕', 'label': 'Bad'},
    {'id': 'terrible', 'emoji': '😢', 'label': 'Terrible'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood['id'];
        
        return Semantics(
          button: true,
          selected: isSelected,
          label: 'Feeling ${mood['label']}',
          child: GestureDetector(
            onTap: () => onSelected(mood['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              decoration: BoxDecoration(
                color: isSelected 
                    ? PremiumTheme.primarySoft 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: PremiumTheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mood['emoji']!,
                    style: TextStyle(
                      fontSize: isSelected ? 32 : 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood['label']!,
                    style: PremiumTheme.labelSmall.copyWith(
                      color: isSelected 
                          ? PremiumTheme.primary 
                          : PremiumTheme.textTertiary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
