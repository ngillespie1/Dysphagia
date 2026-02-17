import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/data_sync_service.dart';
import '../../core/services/service_locator.dart';
import '../../core/theme/premium_theme.dart';
import '../../data/models/appointment.dart';
import '../../data/models/care_team_member.dart';

/// Shows today's and upcoming appointments on the Today screen.
/// Includes a quick-add for new appointments.
class AppointmentCard extends StatefulWidget {
  const AppointmentCard({super.key});

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  final _dataService = getIt<DataSyncService>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todayAppts = _dataService.todayAppointments;
    final upcomingAppts = _dataService.upcomingAppointments
        .where((a) => !a.isToday)
        .take(2)
        .toList();

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
              const Text('📅', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Appointments',
                style: PremiumTheme.headlineSmall.copyWith(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddAppointmentSheet(context),
                child: Icon(Icons.add_circle_outline_rounded,
                    size: 22, color: PremiumTheme.primary),
              ),
            ],
          ),

          if (todayAppts.isEmpty && upcomingAppts.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'No upcoming appointments',
              style: PremiumTheme.bodySmall.copyWith(
                color: PremiumTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to schedule your next visit',
              style: PremiumTheme.labelSmall.copyWith(
                color: PremiumTheme.textTertiary,
                fontSize: 11,
              ),
            ),
          ],

          if (todayAppts.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Today',
              style: PremiumTheme.labelSmall.copyWith(
                color: PremiumTheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            ...todayAppts.map((a) => _buildApptTile(a, isDark, isToday: true)),
          ],

          if (upcomingAppts.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Upcoming',
              style: PremiumTheme.labelSmall.copyWith(
                color: PremiumTheme.textTertiary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            ...upcomingAppts.map((a) => _buildApptTile(a, isDark)),
          ],
        ],
      ),
    );
  }

  Widget _buildApptTile(Appointment appt, bool isDark,
      {bool isToday = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? PremiumTheme.primary.withOpacity(isDark ? 0.1 : 0.06)
            : isDark
                ? Colors.white.withOpacity(0.03)
                : PremiumTheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Time / date badge
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isToday
                  ? PremiumTheme.primary.withOpacity(0.15)
                  : PremiumTheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                isToday ? appt.timeDisplay : appt.dateDisplay,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isToday
                      ? PremiumTheme.primary
                      : PremiumTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : PremiumTheme.textPrimary,
                  ),
                ),
                if (appt.withRole != null)
                  Text(
                    '${appt.withRole!.icon} ${appt.withRole!.label}',
                    style: TextStyle(
                      fontSize: 11,
                      color: PremiumTheme.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          if (appt.location != null)
            Text(
              '📍',
              style: TextStyle(
                fontSize: 12,
                color: PremiumTheme.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  void _showAddAppointmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddAppointmentSheet(
        onSave: (appt) async {
          await _dataService.addAppointment(appt);
          setState(() {});
        },
      ),
    );
  }
}

class _AddAppointmentSheet extends StatefulWidget {
  final Future<void> Function(Appointment appt) onSave;

  const _AddAppointmentSheet({required this.onSave});

  @override
  State<_AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<_AddAppointmentSheet> {
  final _titleController = TextEditingController();
  CareRole? _withRole;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
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
              'Schedule Appointment',
              style: PremiumTheme.headlineSmall.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            _label('Title', isDark),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration('e.g. Follow-up check', isDark),
              style: TextStyle(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary),
            ),
            const SizedBox(height: 16),

            // Provider role (optional)
            _label('With (optional)', isDark),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _roleChip(null, 'Any'),
                ...CareRole.values
                    .take(5)
                    .map((r) => _roleChip(r, '${r.icon} ${r.label}')),
              ],
            ),
            const SizedBox(height: 16),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: _pickerBox(
                      '📅 ${_date.day}/${_date.month}/${_date.year}',
                      isDark,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _time,
                      );
                      if (picked != null) setState(() => _time = picked);
                    },
                    child: _pickerBox(
                      '🕐 ${_time.format(context)}',
                      isDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Location (optional)
            _label('Location (optional)', isDark),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration('Hospital, clinic...', isDark),
              style: TextStyle(
                  color: isDark ? Colors.white : PremiumTheme.textPrimary),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _titleController.text.trim().isEmpty
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        final dateTime = DateTime(
                          _date.year,
                          _date.month,
                          _date.day,
                          _time.hour,
                          _time.minute,
                        );
                        final appt = Appointment(
                          id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
                          title: _titleController.text.trim(),
                          dateTime: dateTime,
                          withRole: _withRole,
                          location:
                              _locationController.text.trim().isNotEmpty
                                  ? _locationController.text.trim()
                                  : null,
                        );
                        await widget.onSave(appt);
                        if (context.mounted) Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  disabledBackgroundColor:
                      PremiumTheme.textTertiary.withOpacity(0.2),
                ),
                child: const Text('Save Appointment',
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

  Widget _label(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : PremiumTheme.textSecondary,
        ),
      );

  InputDecoration _inputDecoration(String hint, bool isDark) => InputDecoration(
        hintText: hint,
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
      );

  Widget _roleChip(CareRole? role, String label) {
    final selected = _withRole == role;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: PremiumTheme.primarySoft,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? PremiumTheme.primary : PremiumTheme.textSecondary,
      ),
      onSelected: (_) => setState(() => _withRole = role),
    );
  }

  Widget _pickerBox(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: PremiumTheme.surfaceVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : PremiumTheme.textPrimary,
        ),
      ),
    );
  }
}
