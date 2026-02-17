import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/premium_theme.dart';

/// Premium styled notification time picker
class NotificationTimePicker extends StatefulWidget {
  final List<TimeOfDay> times;
  final Future<void> Function(List<TimeOfDay>) onSave;

  const NotificationTimePicker({
    super.key,
    required this.times,
    required this.onSave,
  });

  @override
  State<NotificationTimePicker> createState() => _NotificationTimePickerState();
}

class _NotificationTimePickerState extends State<NotificationTimePicker> {
  late List<TimeOfDay> _times;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _times = List.from(widget.times);
    
    // Ensure we have exactly 3 times
    while (_times.length < 3) {
      _times.add(const TimeOfDay(hour: 12, minute: 0));
    }
    if (_times.length > 3) {
      _times = _times.sublist(0, 3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: PremiumTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PremiumTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Reminder Times',
              style: PremiumTheme.headlineLarge,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Choose when you\'d like to be reminded to practice',
              style: PremiumTheme.bodyMedium,
            ),
            
            const SizedBox(height: 24),
            
            // Time slots
            _TimeSlot(
              label: 'Morning',
              icon: Icons.wb_sunny_rounded,
              iconColor: const Color(0xFFFFB347),
              time: _times[0],
              onTap: () => _pickTime(0),
            ),
            
            const SizedBox(height: 12),
            
            _TimeSlot(
              label: 'Afternoon',
              icon: Icons.wb_twilight_rounded,
              iconColor: const Color(0xFFFF8C42),
              time: _times[1],
              onTap: () => _pickTime(1),
            ),
            
            const SizedBox(height: 12),
            
            _TimeSlot(
              label: 'Evening',
              icon: Icons.nightlight_round,
              iconColor: const Color(0xFF7B68EE),
              time: _times[2],
              onTap: () => _pickTime(2),
            ),
            
            const SizedBox(height: 24),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: PremiumTheme.primaryButton.copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
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
                    : Text('Save Times', style: PremiumTheme.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(int index) async {
    HapticFeedback.selectionClick();
    
    final picked = await showTimePicker(
      context: context,
      initialTime: _times[index],
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: PremiumTheme.primary,
              onPrimary: Colors.white,
              surface: PremiumTheme.cardWhite,
              onSurface: PremiumTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _times[index] = picked;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await widget.onSave(_times);
    setState(() => _isSaving = false);
  }
}

class _TimeSlot extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final TimeOfDay time;
  final VoidCallback onTap;

  const _TimeSlot({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.time,
    required this.onTap,
  });

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PremiumTheme.bgWarm,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: PremiumTheme.headlineSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: PremiumTheme.softShadow,
                ),
                child: Text(
                  _formatTime(time),
                  style: PremiumTheme.labelLarge.copyWith(
                    color: PremiumTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
