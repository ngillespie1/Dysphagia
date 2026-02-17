import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/data_sync_service.dart';
import '../../core/services/service_locator.dart';
import '../../core/theme/premium_theme.dart';
import '../../data/models/care_team_member.dart';

/// Editable list of care team members for the Me/Settings screen.
class CareTeamList extends StatefulWidget {
  const CareTeamList({super.key});

  @override
  State<CareTeamList> createState() => _CareTeamListState();
}

class _CareTeamListState extends State<CareTeamList> {
  final _dataService = getIt<DataSyncService>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final members = _dataService.careTeamMembers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'My Care Team',
              style: PremiumTheme.headlineSmall.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showAddMemberSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: PremiumTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded,
                        size: 16, color: PremiumTheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: PremiumTheme.labelSmall.copyWith(
                        color: PremiumTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (members.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? PremiumTheme.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : PremiumTheme.surfaceVariant,
              ),
            ),
            child: Column(
              children: [
                const Text('👥', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  'Add your care team members',
                  style: PremiumTheme.bodySmall.copyWith(
                    color: PremiumTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep your doctors, therapists & caregivers in one place',
                  style: PremiumTheme.labelSmall.copyWith(
                    color: PremiumTheme.textTertiary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...members.map((member) => _buildMemberTile(member, isDark)),
      ],
    );
  }

  Widget _buildMemberTile(CareTeamMember member, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : PremiumTheme.surfaceVariant,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PremiumTheme.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(member.role.icon,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : PremiumTheme.textPrimary,
                  ),
                ),
                Text(
                  member.role.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: PremiumTheme.textTertiary,
                  ),
                ),
                if (member.clinic != null)
                  Text(
                    member.clinic!,
                    style: TextStyle(
                      fontSize: 11,
                      color: PremiumTheme.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: () async {
              await _dataService.removeCareTeamMember(member.id);
              setState(() {});
            },
            child: Icon(Icons.close_rounded,
                size: 18, color: PremiumTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddCareTeamMemberSheet(
        onSave: (member) async {
          await _dataService.addCareTeamMember(member);
          setState(() {});
        },
      ),
    );
  }
}

class _AddCareTeamMemberSheet extends StatefulWidget {
  final Future<void> Function(CareTeamMember member) onSave;

  const _AddCareTeamMemberSheet({required this.onSave});

  @override
  State<_AddCareTeamMemberSheet> createState() =>
      _AddCareTeamMemberSheetState();
}

class _AddCareTeamMemberSheetState extends State<_AddCareTeamMemberSheet> {
  CareRole _role = CareRole.speechPathologist;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _clinicController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _clinicController.dispose();
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
              'Add Care Team Member',
              style: PremiumTheme.headlineSmall.copyWith(
                color: isDark ? Colors.white : PremiumTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Role selector
            Text('Role',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : PremiumTheme.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: CareRole.values.map((role) {
                final selected = role == _role;
                return ChoiceChip(
                  label: Text('${role.icon} ${role.label}'),
                  selected: selected,
                  selectedColor: PremiumTheme.primarySoft,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? PremiumTheme.primary
                        : PremiumTheme.textSecondary,
                  ),
                  onSelected: (_) => setState(() => _role = role),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Name
            _buildTextField('Name', _nameController, 'Dr. Jane Smith', isDark),
            const SizedBox(height: 12),
            _buildTextField('Phone (optional)', _phoneController, '+1 555-0100', isDark),
            const SizedBox(height: 12),
            _buildTextField('Clinic (optional)', _clinicController, 'City Hospital', isDark),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nameController.text.trim().isEmpty
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        final member = CareTeamMember(
                          id: 'ct_${DateTime.now().millisecondsSinceEpoch}',
                          name: _nameController.text.trim(),
                          role: _role,
                          phone: _phoneController.text.trim().isNotEmpty
                              ? _phoneController.text.trim()
                              : null,
                          clinic: _clinicController.text.trim().isNotEmpty
                              ? _clinicController.text.trim()
                              : null,
                        );
                        await widget.onSave(member);
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
                child: const Text('Add Member',
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

  Widget _buildTextField(
      String label, TextEditingController controller, String hint, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : PremiumTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
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
          ),
          style: TextStyle(
              color: isDark ? Colors.white : PremiumTheme.textPrimary),
        ),
      ],
    );
  }
}
