import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/premium_theme.dart';

/// Card for sharing progress with doctor/care team
/// Navigates to the full Doctor Report screen for PDF generation
class ProgressShareCard extends StatelessWidget {
  final DateTime? lastShared;
  final VoidCallback? onShare;

  const ProgressShareCard({
    super.key,
    this.lastShared,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysSinceShared = lastShared != null
        ? DateTime.now().difference(lastShared!).inDays
        : null;

    return Semantics(
      button: true,
      label: 'Generate a progress report for your doctor',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? PremiumTheme.darkSurfaceVariant : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? PremiumTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isDark ? null : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.medical_services_rounded,
                    color: isDark ? PremiumTheme.darkPrimary : PremiumTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor Report',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? PremiumTheme.darkTextPrimary
                              : const Color(0xFF000000),
                        ),
                      ),
                      if (daysSinceShared != null)
                        Text(
                          daysSinceShared == 0
                              ? 'Shared today'
                              : 'Last shared: $daysSinceShared days ago',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? PremiumTheme.darkTextTertiary
                                : Colors.grey[600],
                          ),
                        )
                      else
                        Text(
                          'Share your progress',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? PremiumTheme.darkTextTertiary
                                : Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              'Generate a professional PDF report with exercise adherence, symptom trends, and check-in history to share with your healthcare provider.',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? PremiumTheme.darkTextSecondary
                    : Colors.grey[600],
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push(AppRoutes.doctorReport);
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                label: const Text('Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? PremiumTheme.darkPrimary
                      : PremiumTheme.primary,
                  foregroundColor: isDark
                      ? PremiumTheme.darkBackground
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
