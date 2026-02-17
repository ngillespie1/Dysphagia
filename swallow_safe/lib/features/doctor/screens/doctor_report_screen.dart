import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/services/data_sync_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../core/models/program.dart';
import '../../program/bloc/program_bloc.dart';
import '../../program/bloc/program_state.dart';
import '../../progress/bloc/streak_bloc.dart';
import '../../user/bloc/user_bloc.dart';
import '../services/report_generator.dart';

/// Full-screen doctor report builder with PDF preview and export
class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;

  final ReportGenerator _reportGenerator = ReportGenerator();

  // Report configuration
  int _reportDays = 30;
  bool _includeCheckIns = true;
  bool _includeSymptomTrends = true;

  // State
  ProgressReport? _report;
  Uint8List? _pdfBytes;
  bool _isGenerating = false;
  bool _isGenerated = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final dataService = getIt<DataSyncService>();

      // Get user info
      final userState = context.read<UserBloc>().state;
      String patientName = 'Patient';
      String email = '';
      if (userState is UserLoaded) {
        patientName = userState.user.name;
        email = userState.user.email;
      }

      // Get program info
      final programState = context.read<ProgramBloc>().state;
      String programName = 'Recovery Program';
      String programType = '';
      int currentWeek = 1;
      int totalWeeks = 8;
      double overallProgress = 0;
      int programDurationWeeks = 8;
      DateTime programStartDate = DateTime.now();

      if (programState is ProgramLoaded) {
        programName = programState.program.type.displayName;
        programType = programState.program.type.name;
        currentWeek = programState.program.currentWeek;
        totalWeeks = programState.program.totalWeeks;
        overallProgress = programState.program.overallProgress;
        programDurationWeeks = programState.program.totalWeeks;
        programStartDate = programState.program.startDate;
      }

      // Generate report
      final report = await _reportGenerator.generateReport(
        dataService: dataService,
        patientName: patientName,
        email: email,
        programName: programName,
        programType: programType,
        programDurationWeeks: programDurationWeeks,
        programStartDate: programStartDate,
        currentWeek: currentWeek,
        totalWeeks: totalWeeks,
        overallProgress: overallProgress,
        reportDays: _reportDays,
      );

      // Generate PDF
      final pdfBytes = await _reportGenerator.generatePdf(report);

      if (mounted) {
        setState(() {
          _report = report;
          _pdfBytes = pdfBytes;
          _isGenerating = false;
          _isGenerated = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _errorMessage = 'Something went wrong — please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? PremiumTheme.darkBackground : PremiumTheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeController,
          child: Column(
            children: [
              // App bar
              _buildAppBar(context, isDark),

              // Content
              Expanded(
                child: _isGenerated && _pdfBytes != null
                    ? _buildPdfPreview(context)
                    : _buildConfigForm(context, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark
                  ? PremiumTheme.darkTextPrimary
                  : PremiumTheme.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share with Your Team',
                  style: PremiumTheme.headlineLarge.copyWith(
                    color: isDark
                        ? PremiumTheme.darkTextPrimary
                        : PremiumTheme.textPrimary,
                  ),
                ),
                Text(
                  _isGenerated
                      ? 'Preview and share when you\'re ready'
                      : 'Choose what to include',
                  style: PremiumTheme.bodySmall.copyWith(
                    color: isDark
                        ? PremiumTheme.darkTextSecondary
                        : PremiumTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (_isGenerated) ...[
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: isDark
                    ? PremiumTheme.darkTextSecondary
                    : PremiumTheme.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _isGenerated = false;
                  _pdfBytes = null;
                  _report = null;
                });
              },
              tooltip: 'Reconfigure',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfigForm(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          _buildInfoBanner(isDark),
          const SizedBox(height: 24),

          // Report period selector
          Text(
            'REPORT PERIOD',
            style: PremiumTheme.labelMedium.copyWith(
              letterSpacing: 1.2,
              color: isDark
                  ? PremiumTheme.darkTextTertiary
                  : PremiumTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                _buildPeriodOption(7, 'Last 7 days', isDark),
                _buildDivider(isDark),
                _buildPeriodOption(14, 'Last 14 days', isDark),
                _buildDivider(isDark),
                _buildPeriodOption(30, 'Last 30 days', isDark),
                _buildDivider(isDark),
                _buildPeriodOption(60, 'Last 60 days', isDark),
                _buildDivider(isDark),
                _buildPeriodOption(90, 'Last 90 days', isDark),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Include options
          Text(
            'INCLUDE IN REPORT',
            style: PremiumTheme.labelMedium.copyWith(
              letterSpacing: 1.2,
              color: isDark
                  ? PremiumTheme.darkTextTertiary
                  : PremiumTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          GlassCard(
            child: Column(
              children: [
                _buildToggleOption(
                  'Exercise Consistency',
                  'Session completion and streak data',
                  true, // Always included
                  null,
                  isDark,
                  locked: true,
                ),
                _buildDivider(isDark),
                _buildToggleOption(
                  'Symptom Trends',
                  'Pain, swallowing ease, dry mouth trends',
                  _includeSymptomTrends,
                  (v) => setState(() => _includeSymptomTrends = v),
                  isDark,
                ),
                _buildDivider(isDark),
                _buildToggleOption(
                  'Check-in History',
                  'Your daily check-in entries',
                  _includeCheckIns,
                  (v) => setState(() => _includeCheckIns = v),
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Report preview info
          _buildReportPreviewInfo(isDark),

          const SizedBox(height: 32),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isGenerating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Create PDF Report',
                          style: PremiumTheme.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PremiumTheme.errorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: PremiumTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: PremiumTheme.bodySmall.copyWith(
                        color: PremiumTheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? PremiumTheme.darkHeroGradient
            : PremiumTheme.heroGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share with your care team',
                  style: PremiumTheme.headlineSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create a PDF summary of your exercises, symptom trends, and check-in history — perfect for your next appointment.',
                  style: PremiumTheme.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodOption(int days, String label, bool isDark) {
    final isSelected = _reportDays == days;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label report period',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _reportDays = days);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: isSelected
                      ? PremiumTheme.primary
                      : (isDark
                          ? PremiumTheme.darkTextTertiary
                          : PremiumTheme.textTertiary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: PremiumTheme.headlineSmall.copyWith(
                      fontSize: 15,
                      color: isSelected
                          ? (isDark
                              ? PremiumTheme.darkPrimary
                              : PremiumTheme.primary)
                          : (isDark
                              ? PremiumTheme.darkTextPrimary
                              : PremiumTheme.textPrimary),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isDark
                          ? PremiumTheme.darkPrimary
                          : PremiumTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: isDark
                          ? PremiumTheme.darkBackground
                          : Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
    bool isDark, {
    bool locked = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PremiumTheme.headlineSmall.copyWith(
                    fontSize: 15,
                    color: isDark
                        ? PremiumTheme.darkTextPrimary
                        : PremiumTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: PremiumTheme.bodySmall.copyWith(
                    color: isDark
                        ? PremiumTheme.darkTextTertiary
                        : PremiumTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PremiumTheme.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Always',
                style: PremiumTheme.labelSmall.copyWith(
                  color: PremiumTheme.primary,
                ),
              ),
            )
          else
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: PremiumTheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 34),
      height: 1,
      color: isDark ? PremiumTheme.darkSurfaceVariant : PremiumTheme.bgWarm,
    );
  }

  Widget _buildReportPreviewInfo(bool isDark) {
    final startDate =
        DateTime.now().subtract(Duration(days: _reportDays));
    final df = DateFormat('MMM d, yyyy');

    final sections = <String>[
      'Exercise consistency & streaks',
      if (_includeSymptomTrends) 'Symptom trends & analysis',
      if (_includeCheckIns) 'Daily check-in history',
      'Clinical notes section (blank)',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkSurfaceVariant : PremiumTheme.bgWarm,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview_rounded,
                size: 18,
                color: isDark
                    ? PremiumTheme.darkTextSecondary
                    : PremiumTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Your report will include',
                style: PremiumTheme.labelLarge.copyWith(
                  color: isDark
                      ? PremiumTheme.darkTextPrimary
                      : PremiumTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${df.format(startDate)} – ${df.format(DateTime.now())}',
            style: PremiumTheme.bodySmall.copyWith(
              color: isDark
                  ? PremiumTheme.darkTextTertiary
                  : PremiumTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          ...sections.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: PremiumTheme.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      s,
                      style: PremiumTheme.bodySmall.copyWith(
                        color: isDark
                            ? PremiumTheme.darkTextSecondary
                            : PremiumTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPdfPreview(BuildContext context) {
    return Column(
      children: [
        // Action bar
        _buildActionBar(context),

        // PDF preview
        Expanded(
          child: PdfPreview(
            build: (format) async => _pdfBytes!,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            pdfFileName:
                'SwallowSafe_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
            actions: const [],
            loadingWidget: const Center(
              child: CircularProgressIndicator(color: PremiumTheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          // Share PDF button
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _sharePdf(context),
                icon: const Icon(Icons.share_rounded, size: 20),
                label: const Text('Share PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Print button
          SizedBox(
            height: 48,
            width: 48,
            child: IconButton(
              onPressed: () => _printPdf(context),
              icon: Icon(
                Icons.print_rounded,
                color: isDark
                    ? PremiumTheme.darkTextPrimary
                    : PremiumTheme.textPrimary,
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                    isDark ? PremiumTheme.darkSurfaceVariant : PremiumTheme.bgWarm,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              tooltip: 'Print',
            ),
          ),
          const SizedBox(width: 10),

          // Copy text button
          SizedBox(
            height: 48,
            width: 48,
            child: IconButton(
              onPressed: () => _copyText(context),
              icon: Icon(
                Icons.copy_rounded,
                color: isDark
                    ? PremiumTheme.darkTextPrimary
                    : PremiumTheme.textPrimary,
              ),
              style: IconButton.styleFrom(
                backgroundColor:
                    isDark ? PremiumTheme.darkSurfaceVariant : PremiumTheme.bgWarm,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              tooltip: 'Copy as text',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    if (_pdfBytes == null) return;
    HapticFeedback.mediumImpact();

    try {
      await Printing.sharePdf(
        bytes: _pdfBytes!,
        filename:
            'SwallowSafe_Report_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString()}'),
            backgroundColor: PremiumTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _printPdf(BuildContext context) async {
    if (_pdfBytes == null) return;
    HapticFeedback.mediumImpact();

    try {
      await Printing.layoutPdf(
        onLayout: (format) async => _pdfBytes!,
        name:
            'SwallowSafe Report ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printing failed: ${e.toString()}'),
            backgroundColor: PremiumTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _copyText(BuildContext context) async {
    if (_report == null) return;
    HapticFeedback.mediumImpact();

    await _reportGenerator.copyToClipboard(_report!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Copied — ready to share with your team'),
          backgroundColor: PremiumTheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
