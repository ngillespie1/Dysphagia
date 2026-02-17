import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/data_sync_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../data/models/food_entry.dart';
import '../../../shared/widgets/illustrated_empty_state.dart';

/// Full-screen food diary with IDDSI texture level support.
/// Accessible from the Today screen.
class FoodDiaryScreen extends StatefulWidget {
  const FoodDiaryScreen({super.key});

  @override
  State<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  final _dataService = getIt<DataSyncService>();
  late List<FoodEntry> _entries;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = _dataService.getFoodEntriesForDate(_selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? PremiumTheme.darkBackground : PremiumTheme.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : PremiumTheme.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Food Diary',
          style: PremiumTheme.headlineSmall.copyWith(
            color: isDark ? Colors.white : PremiumTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Date selector
          _buildDateBar(isDark),
          const SizedBox(height: 8),

          // IDDSI quick reference
          _buildIDDSIReference(isDark),
          const SizedBox(height: 12),

          // Meal entries
          Expanded(
            child: _entries.isEmpty
                ? _buildEmptyState(isDark)
                : _buildEntryList(isDark),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMealSheet(context),
        backgroundColor: PremiumTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Meal',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildDateBar(bool isDark) {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedDate =
                    _selectedDate.subtract(const Duration(days: 1));
              });
              _loadEntries();
            },
            icon: Icon(Icons.chevron_left_rounded,
                color: PremiumTheme.textSecondary),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                _loadEntries();
              }
            },
            child: Text(
              isToday
                  ? 'Today'
                  : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: PremiumTheme.headlineSmall.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: isToday
                ? null
                : () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                    _loadEntries();
                  },
            icon: Icon(Icons.chevron_right_rounded,
                color: isToday
                    ? PremiumTheme.textTertiary
                    : PremiumTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildIDDSIReference(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? PremiumTheme.primary.withOpacity(0.08)
            : PremiumTheme.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'IDDSI Texture Guide',
                style: PremiumTheme.labelSmall.copyWith(
                  color: PremiumTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: IDDSILevel.values.map((level) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${level.icon} ${level.number}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : PremiumTheme.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IllustratedEmptyState(
            type: EmptyStateType.foodDiary,
            title: 'Your food diary is waiting',
            subtitle:
                'Tracking meals helps you spot patterns and share helpful details with your care team.',
            actionLabel: 'Log your first meal',
            onAction: () => _showAddMealSheet(context),
          ),
          const SizedBox(height: 60), // space for FAB
        ],
      ),
    );
  }

  Widget _buildEntryList(bool isDark) {
    // Group by meal type
    final grouped = <MealType, List<FoodEntry>>{};
    for (final entry in _entries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        for (final mealType in MealType.values)
          if (grouped.containsKey(mealType)) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(
                '${mealType.icon} ${mealType.label}',
                style: PremiumTheme.labelSmall.copyWith(
                  color: PremiumTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...grouped[mealType]!.map((entry) => _buildMealCard(entry, isDark)),
          ],
        const SizedBox(height: 80), // space for FAB
      ],
    );
  }

  Widget _buildMealCard(FoodEntry entry, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : PremiumTheme.surfaceVariant,
        ),
      ),
      child: Row(
        children: [
          // IDDSI level badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PremiumTheme.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(entry.textureLevel.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : PremiumTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'IDDSI ${entry.textureLevel.number} · ${entry.textureLevel.label}',
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Difficulty indicator
          if (entry.difficultyRating != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _difficultyColor(entry.difficultyRating!)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${'⬤' * entry.difficultyRating!}',
                style: TextStyle(
                  fontSize: 8,
                  color: _difficultyColor(entry.difficultyRating!),
                ),
              ),
            ),
          if (entry.coughing)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 18),
            ),
        ],
      ),
    );
  }

  Color _difficultyColor(int rating) {
    if (rating <= 2) return PremiumTheme.success;
    if (rating <= 3) return PremiumTheme.warning;
    return PremiumTheme.error;
  }

  void _showAddMealSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddMealSheet(
        onSave: (entry) async {
          await _dataService.addFoodEntry(entry);
          _loadEntries();
        },
      ),
    );
  }
}

/// Bottom sheet for adding a new meal entry
class _AddMealSheet extends StatefulWidget {
  final Future<void> Function(FoodEntry entry) onSave;

  const _AddMealSheet({required this.onSave});

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  MealType _mealType = MealType.lunch;
  IDDSILevel _textureLevel = IDDSILevel.level7;
  int _difficulty = 1;
  bool _coughing = false;
  final _descController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumTheme.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Log Meal',
              style: PremiumTheme.headlineSmall.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Meal type selector
            Text('Meal Type',
                style: _labelStyle(isDark)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final selected = type == _mealType;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.label}'),
                  selected: selected,
                  selectedColor: PremiumTheme.primarySoft,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? PremiumTheme.primary
                        : PremiumTheme.textSecondary,
                  ),
                  onSelected: (_) => setState(() => _mealType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Food description
            Text('What did you eat?',
                style: _labelStyle(isDark)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                hintText: 'e.g. Soft scrambled eggs, yogurt...',
                hintStyle: TextStyle(color: PremiumTheme.textTertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: PremiumTheme.surfaceVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PremiumTheme.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: TextStyle(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary),
            ),
            const SizedBox(height: 16),

            // IDDSI level selector
            Text('IDDSI Texture Level',
                style: _labelStyle(isDark)),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: IDDSILevel.values.map((level) {
                  final selected = level == _textureLevel;
                  return GestureDetector(
                    onTap: () => setState(() => _textureLevel = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? PremiumTheme.primarySoft
                            : isDark
                                ? Colors.white.withOpacity(0.04)
                                : PremiumTheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? PremiumTheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(level.icon,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 2),
                          Text(
                            'L${level.number}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? PremiumTheme.primary
                                  : PremiumTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_textureLevel.label} (Level ${_textureLevel.number})',
              style: TextStyle(
                  fontSize: 12, color: PremiumTheme.primary,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),

            // Difficulty rating
            Text('Swallowing Difficulty',
                style: _labelStyle(isDark)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final level = i + 1;
                final selected = level <= _difficulty;
                return GestureDetector(
                  onTap: () => setState(() => _difficulty = level),
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? _diffColor(level).withOpacity(0.15)
                          : PremiumTheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? _diffColor(level)
                              : PremiumTheme.textTertiary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Text(
              _diffLabel(_difficulty),
              style: TextStyle(fontSize: 11, color: PremiumTheme.textTertiary),
            ),
            const SizedBox(height: 12),

            // Coughing toggle
            Row(
              children: [
                Switch.adaptive(
                  value: _coughing,
                  onChanged: (v) => setState(() => _coughing = v),
                  activeColor: PremiumTheme.warning,
                ),
                const SizedBox(width: 8),
                Text(
                  'Coughing during meal?',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : PremiumTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _descController.text.trim().isEmpty
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        final entry = FoodEntry(
                          id: 'food_${DateTime.now().millisecondsSinceEpoch}',
                          timestamp: DateTime.now(),
                          mealType: _mealType,
                          description: _descController.text.trim(),
                          textureLevel: _textureLevel,
                          difficultyRating: _difficulty,
                          coughing: _coughing,
                          notes: _notesController.text.trim().isNotEmpty
                              ? _notesController.text.trim()
                              : null,
                        );
                        await widget.onSave(entry);
                        if (context.mounted) Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: PremiumTheme.textTertiary.withOpacity(0.2),
                ),
                child: const Text('Save Entry',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : PremiumTheme.textSecondary,
      );

  Color _diffColor(int r) {
    if (r <= 2) return PremiumTheme.success;
    if (r <= 3) return PremiumTheme.warning;
    return PremiumTheme.error;
  }

  String _diffLabel(int r) {
    switch (r) {
      case 1:
        return 'Easy — no difficulty';
      case 2:
        return 'Mild — slight effort needed';
      case 3:
        return 'Moderate — noticeable effort';
      case 4:
        return 'Hard — significant difficulty';
      case 5:
        return 'Very hard — almost impossible';
      default:
        return '';
    }
  }
}
