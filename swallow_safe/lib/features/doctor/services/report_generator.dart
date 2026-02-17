import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/services/data_sync_service.dart';
import '../../../data/models/food_entry.dart';

// ============ Data Models ============

/// Complete progress report data gathered from all data sources
class ProgressReport {
  final String patientName;
  final String email;
  final String programName;
  final String programType;
  final int programDurationWeeks;
  final DateTime programStartDate;
  final int currentWeek;
  final int weeksCompleted;
  final int totalWeeks;
  final double completionRate;
  final int currentStreak;
  final int longestStreak;
  final int totalSessions;
  final DateTime reportStartDate;
  final DateTime reportEndDate;
  final DateTime generatedAt;
  final List<SymptomTrend> symptomTrends;
  final List<CheckInSummary> recentCheckIns;
  final List<WeeklySessionData> weeklyData;
  final double averagePainLevel;
  final double averageSwallowingEase;
  final double averageDryMouth;

  // ─── Phase 6 additions ───
  final int totalFoodEntries;
  final Map<String, int> textureLevelBreakdown; // IDDSI level label → count
  final int achievementsUnlocked;
  final String? userLevelTitle;

  ProgressReport({
    required this.patientName,
    required this.email,
    required this.programName,
    required this.programType,
    required this.programDurationWeeks,
    required this.programStartDate,
    required this.currentWeek,
    required this.weeksCompleted,
    required this.totalWeeks,
    required this.completionRate,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSessions,
    required this.reportStartDate,
    required this.reportEndDate,
    required this.generatedAt,
    required this.symptomTrends,
    required this.recentCheckIns,
    required this.weeklyData,
    required this.averagePainLevel,
    required this.averageSwallowingEase,
    required this.averageDryMouth,
    this.totalFoodEntries = 0,
    this.textureLevelBreakdown = const {},
    this.achievementsUnlocked = 0,
    this.userLevelTitle,
  });

  /// Generate a text summary for clipboard/sharing
  String toTextSummary() {
    final df = DateFormat('MMMM d, yyyy');
    final buffer = StringBuffer();
    
    buffer.writeln('╔════════════════════════════════════════╗');
    buffer.writeln('║   SwallowSafe Progress Report          ║');
    buffer.writeln('╚════════════════════════════════════════╝');
    buffer.writeln();
    buffer.writeln('Patient: $patientName');
    buffer.writeln('Report Period: ${df.format(reportStartDate)} – ${df.format(reportEndDate)}');
    buffer.writeln('Generated: ${df.format(generatedAt)}');
    buffer.writeln();
    buffer.writeln('═══ PROGRAM ═══');
    buffer.writeln('Program: $programName');
    buffer.writeln('Duration: $programDurationWeeks weeks');
    buffer.writeln('Current Week: $currentWeek of $totalWeeks');
    buffer.writeln('Start Date: ${df.format(programStartDate)}');
    buffer.writeln();
    buffer.writeln('═══ EXERCISE ADHERENCE ═══');
    buffer.writeln('Overall Completion: ${completionRate.toStringAsFixed(1)}%');
    buffer.writeln('Total Sessions: $totalSessions');
    buffer.writeln('Current Streak: $currentStreak days');
    buffer.writeln('Longest Streak: $longestStreak days');
    buffer.writeln('Weeks Completed: $weeksCompleted of $totalWeeks');
    buffer.writeln();

    if (symptomTrends.isNotEmpty) {
      buffer.writeln('═══ SYMPTOM TRENDS ═══');
      for (final trend in symptomTrends) {
        final arrow = trend.trend == 'improving'
            ? '↓ Improving'
            : trend.trend == 'worsening'
                ? '↑ Worsening'
                : '→ Stable';
        buffer.writeln('${trend.symptomName}: $arrow');
        if (trend.currentAverage != null) {
          buffer.writeln(
              '  Current avg: ${trend.currentAverage!.toStringAsFixed(1)}/5');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('═══ AVERAGES (1-5 Scale, lower = better) ═══');
    buffer.writeln(
        'Pain Level: ${averagePainLevel.toStringAsFixed(1)}');
    buffer.writeln(
        'Swallowing Ease: ${averageSwallowingEase.toStringAsFixed(1)}');
    buffer.writeln(
        'Dry Mouth: ${averageDryMouth.toStringAsFixed(1)}');
    buffer.writeln();

    if (recentCheckIns.isNotEmpty) {
      buffer.writeln('═══ RECENT CHECK-INS ═══');
      for (final ci in recentCheckIns.take(7)) {
        buffer.writeln(
            '${ci.date}: Pain ${ci.painLevel}/5, Swallow ${ci.swallowingEase}/5, Dry Mouth ${ci.dryMouth}/5');
        if (ci.notes != null && ci.notes!.isNotEmpty) {
          buffer.writeln('  Notes: ${ci.notes}');
        }
      }
    buffer.writeln();
    }

    if (totalFoodEntries > 0) {
      buffer.writeln('═══ FOOD DIARY ═══');
      buffer.writeln('Total Meals Logged: $totalFoodEntries');
      if (textureLevelBreakdown.isNotEmpty) {
        buffer.writeln('IDDSI Texture Breakdown:');
        for (final entry in textureLevelBreakdown.entries) {
          buffer.writeln('  ${entry.key}: ${entry.value} meals');
        }
      }
      buffer.writeln();
    }

    if (achievementsUnlocked > 0 || userLevelTitle != null) {
      buffer.writeln('═══ ENGAGEMENT ═══');
      if (userLevelTitle != null) {
        buffer.writeln('Current Level: $userLevelTitle');
      }
      buffer.writeln('Achievements Unlocked: $achievementsUnlocked');
      buffer.writeln();
    }

    buffer.writeln('────────────────────────────────────────');
    buffer.writeln(
        '⚠️ This report is generated from patient self-reported data');
    buffer.writeln(
        'and is intended to supplement clinical evaluation, not replace it.');
    buffer.writeln('Generated by SwallowSafe v1.0.0');
    
    return buffer.toString();
  }
}

/// Symptom trend data
class SymptomTrend {
  final String symptomName;
  final String trend; // "improving", "stable", "worsening"
  final double? changePercent;
  final double? currentAverage;
  final double? previousAverage;

  SymptomTrend({
    required this.symptomName,
    required this.trend,
    this.changePercent,
    this.currentAverage,
    this.previousAverage,
  });
}

/// Summary of a single check-in for the report
class CheckInSummary {
  final String date;
  final int painLevel;
  final int swallowingEase;
  final int dryMouth;
  final String? overallFeeling;
  final String? notes;

  CheckInSummary({
    required this.date,
    required this.painLevel,
    required this.swallowingEase,
    required this.dryMouth,
    this.overallFeeling,
    this.notes,
  });
}

/// Weekly session data for adherence chart
class WeeklySessionData {
  final int weekNumber;
  final int sessionsCompleted;
  final int sessionsTotal;
  final double completionPercent;

  WeeklySessionData({
    required this.weekNumber,
    required this.sessionsCompleted,
    required this.sessionsTotal,
    required this.completionPercent,
  });
}

// ============ Report Generator Service ============

/// Service for generating comprehensive progress reports and PDF exports
class ReportGenerator {
  static final _headerColor = PdfColor.fromHex('#0A6B6E');
  static final _accentColor = PdfColor.fromHex('#D4A574');
  static final _successColor = PdfColor.fromHex('#2D9F6F');
  static final _warningColor = PdfColor.fromHex('#E09F3E');
  static final _errorColor = PdfColor.fromHex('#D64045');
  static final _textPrimary = PdfColor.fromHex('#1C2426');
  static final _textSecondary = PdfColor.fromHex('#5A6668');
  static final _bgLight = PdfColor.fromHex('#F7F4F0');

  /// Generate a progress report by gathering data from all sources
  Future<ProgressReport> generateReport({
    required DataSyncService dataService,
    required String patientName,
    required String email,
    required String programName,
    required String programType,
    required int programDurationWeeks,
    required DateTime programStartDate,
    required int currentWeek,
    required int totalWeeks,
    required double overallProgress,
    int reportDays = 30,
  }) async {
    final now = DateTime.now();
    final reportStart = now.subtract(Duration(days: reportDays));

    // Gather streak data (typed StreakInfo)
    final streakData = await dataService.getStreakData();
    final currentStreak = streakData.currentStreak;
    final longestStreak = streakData.longestStreak;
    final totalSessions = streakData.totalSessions;

    // Gather progress data (typed List<DailyProgress>)
    final progressRecords =
        await dataService.getProgressInRange(reportStart, now);

    // Build weekly session data
    final weeklyData = <WeeklySessionData>[];
    final weeksInRange =
        (reportDays / 7).ceil().clamp(1, totalWeeks);
    for (int w = 0; w < weeksInRange; w++) {
      final weekStart = reportStart.add(Duration(days: w * 7));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final weekSessions = progressRecords.where((r) {
        final date = DateTime.tryParse(r.date);
        return date != null &&
            date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
            date.isBefore(weekEnd) &&
            r.sessionCompleted;
      }).length;

      weeklyData.add(WeeklySessionData(
        weekNumber: w + 1,
        sessionsCompleted: weekSessions,
        sessionsTotal: 7,
        completionPercent:
            weekSessions > 0 ? (weekSessions / 7 * 100).clamp(0, 100) : 0,
      ));
    }

    // Completed weeks
    final weeksCompleted = weeklyData
        .where((w) => w.completionPercent >= 70)
        .length;

    // Gather check-in data (typed List<CheckIn>)
    final recentCheckIns =
        await dataService.getRecentCheckIns(limit: 30);
    final checkInSummaries = recentCheckIns.map((ci) {
      return CheckInSummary(
        date: ci.date,
        painLevel: ci.painLevel,
        swallowingEase: ci.swallowingEase,
        dryMouth: ci.dryMouth,
        overallFeeling: ci.overallFeeling,
        notes: ci.notes,
      );
    }).toList();

    // Calculate averages
    double avgPain = 0, avgSwallow = 0, avgDry = 0;
    if (checkInSummaries.isNotEmpty) {
      avgPain = checkInSummaries
              .map((c) => c.painLevel)
              .reduce((a, b) => a + b) /
          checkInSummaries.length;
      avgSwallow = checkInSummaries
              .map((c) => c.swallowingEase)
              .reduce((a, b) => a + b) /
          checkInSummaries.length;
      avgDry = checkInSummaries
              .map((c) => c.dryMouth)
              .reduce((a, b) => a + b) /
          checkInSummaries.length;
    }

    // Calculate symptom trends (compare first half vs second half)
    final symptomTrends = _calculateTrends(checkInSummaries);

    // ─── Phase 6: Food diary data ───
    final foodEntries = dataService.getFoodEntriesInRange(reportStart, now);
    final textureLevelBreakdown = <String, int>{};
    for (final entry in foodEntries) {
      final label = 'IDDSI ${entry.textureLevel.number} (${entry.textureLevel.label})';
      textureLevelBreakdown[label] = (textureLevelBreakdown[label] ?? 0) + 1;
    }

    // ─── Phase 6: Achievement & level data ───
    final allAchievements = dataService.getAllAchievements();
    final unlockedCount = allAchievements.where((a) => a.isUnlocked).length;
    final userLevel = dataService.getUserLevel();

    return ProgressReport(
      patientName: patientName,
      email: email,
      programName: programName,
      programType: programType,
      programDurationWeeks: programDurationWeeks,
      programStartDate: programStartDate,
      currentWeek: currentWeek,
      weeksCompleted: weeksCompleted,
      totalWeeks: totalWeeks,
      completionRate: overallProgress * 100,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalSessions: totalSessions,
      reportStartDate: reportStart,
      reportEndDate: now,
      generatedAt: now,
      symptomTrends: symptomTrends,
      recentCheckIns: checkInSummaries,
      weeklyData: weeklyData,
      averagePainLevel: avgPain,
      averageSwallowingEase: avgSwallow,
      averageDryMouth: avgDry,
      totalFoodEntries: foodEntries.length,
      textureLevelBreakdown: textureLevelBreakdown,
      achievementsUnlocked: unlockedCount,
      userLevelTitle: userLevel.title,
    );
  }

  List<SymptomTrend> _calculateTrends(List<CheckInSummary> checkIns) {
    if (checkIns.length < 4) {
      // Not enough data for trends
      return [
        SymptomTrend(
          symptomName: 'Pain Level',
          trend: 'stable',
          currentAverage: checkIns.isNotEmpty
              ? checkIns.map((c) => c.painLevel).reduce((a, b) => a + b) /
                  checkIns.length
              : null,
        ),
        SymptomTrend(
          symptomName: 'Swallowing Ease',
          trend: 'stable',
          currentAverage: checkIns.isNotEmpty
              ? checkIns.map((c) => c.swallowingEase).reduce((a, b) => a + b) /
                  checkIns.length
              : null,
        ),
        SymptomTrend(
          symptomName: 'Dry Mouth',
          trend: 'stable',
          currentAverage: checkIns.isNotEmpty
              ? checkIns.map((c) => c.dryMouth).reduce((a, b) => a + b) /
                  checkIns.length
              : null,
        ),
      ];
    }

    final midpoint = checkIns.length ~/ 2;
    final recent = checkIns.sublist(0, midpoint);
    final older = checkIns.sublist(midpoint);

    String determineTrend(double recentAvg, double olderAvg) {
      final diff = recentAvg - olderAvg;
      if (diff < -0.3) return 'improving'; // Lower = better for symptoms
      if (diff > 0.3) return 'worsening';
      return 'stable';
    }

    final recentPain =
        recent.map((c) => c.painLevel).reduce((a, b) => a + b) /
            recent.length;
    final olderPain =
        older.map((c) => c.painLevel).reduce((a, b) => a + b) / older.length;

    final recentSwallow =
        recent.map((c) => c.swallowingEase).reduce((a, b) => a + b) /
            recent.length;
    final olderSwallow =
        older.map((c) => c.swallowingEase).reduce((a, b) => a + b) /
            older.length;

    final recentDry =
        recent.map((c) => c.dryMouth).reduce((a, b) => a + b) /
            recent.length;
    final olderDry =
        older.map((c) => c.dryMouth).reduce((a, b) => a + b) / older.length;

    return [
      SymptomTrend(
        symptomName: 'Pain Level',
        trend: determineTrend(recentPain, olderPain),
        currentAverage: recentPain,
        previousAverage: olderPain,
        changePercent: olderPain > 0
            ? ((recentPain - olderPain) / olderPain * 100)
            : null,
      ),
      SymptomTrend(
        symptomName: 'Swallowing Ease',
        trend: determineTrend(recentSwallow, olderSwallow),
        currentAverage: recentSwallow,
        previousAverage: olderSwallow,
        changePercent: olderSwallow > 0
            ? ((recentSwallow - olderSwallow) / olderSwallow * 100)
            : null,
      ),
      SymptomTrend(
        symptomName: 'Dry Mouth',
        trend: determineTrend(recentDry, olderDry),
        currentAverage: recentDry,
        previousAverage: olderDry,
        changePercent: olderDry > 0
            ? ((recentDry - olderDry) / olderDry * 100)
            : null,
      ),
    ];
  }

  /// Generate a PDF document from the report
  Future<Uint8List> generatePdf(ProgressReport report) async {
    final pdf = pw.Document(
      title: 'SwallowSafe Progress Report - ${report.patientName}',
      author: 'SwallowSafe',
      creator: 'SwallowSafe v1.0.0',
    );

    final df = DateFormat('MMM d, yyyy');
    final dfShort = DateFormat('MM/dd');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPdfHeader(report, df),
        footer: (context) => _buildPdfFooter(context, report),
        build: (context) => [
          // Patient info bar
          _buildPatientInfoBar(report, df),
          pw.SizedBox(height: 20),

          // Adherence summary
          _buildSectionTitle('Exercise Adherence'),
          pw.SizedBox(height: 8),
          _buildAdherenceGrid(report),
          pw.SizedBox(height: 20),

          // Weekly adherence chart
          _buildSectionTitle('Weekly Session Completion'),
          pw.SizedBox(height: 8),
          _buildWeeklyBarChart(report),
          pw.SizedBox(height: 20),

          // Symptom trends
          _buildSectionTitle('Symptom Trends'),
          pw.SizedBox(height: 8),
          _buildSymptomTrendsTable(report),
          pw.SizedBox(height: 20),

          // Check-in history
          if (report.recentCheckIns.isNotEmpty) ...[
            _buildSectionTitle('Recent Check-In Log'),
            pw.SizedBox(height: 8),
            _buildCheckInTable(report, dfShort),
            pw.SizedBox(height: 20),
          ],

          // Clinical notes section (blank for doctor to fill in)
          _buildSectionTitle('Clinical Notes'),
          pw.SizedBox(height: 8),
          _buildNotesSection(),
          pw.SizedBox(height: 20),

          // Disclaimer
          _buildDisclaimer(),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfHeader(ProgressReport report, DateFormat df) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'SwallowSafe',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _headerColor,
                ),
              ),
              pw.Text(
                'Patient Progress Report',
                style: pw.TextStyle(
                  fontSize: 13,
                  color: _textSecondary,
                ),
              ),
            ],
          ),
          pw.Spacer(),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Report Generated',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: _textSecondary,
                ),
              ),
              pw.Text(
                df.format(report.generatedAt),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Context context, ProgressReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SwallowSafe Progress Report – ${report.patientName}',
            style: pw.TextStyle(fontSize: 8, color: _textSecondary),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPatientInfoBar(ProgressReport report, DateFormat df) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _bgLight,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Patient',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: _textSecondary,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  report.patientName,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                if (report.email.isNotEmpty)
                  pw.Text(
                    report.email,
                    style: pw.TextStyle(fontSize: 9, color: _textSecondary),
                  ),
              ],
            ),
          ),
          pw.Container(
            width: 1,
            height: 40,
            color: PdfColors.grey300,
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Program',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: _textSecondary,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  report.programName,
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                pw.Text(
                  'Started: ${df.format(report.programStartDate)}',
                  style: pw.TextStyle(fontSize: 9, color: _textSecondary),
                ),
              ],
            ),
          ),
          pw.Container(
            width: 1,
            height: 40,
            color: PdfColors.grey300,
          ),
          pw.SizedBox(width: 14),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Report Period',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: _textSecondary,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '${df.format(report.reportStartDate)} –',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                pw.Text(
                  df.format(report.reportEndDate),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: _headerColor, width: 2),
        ),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: _headerColor,
        ),
      ),
    );
  }

  pw.Widget _buildAdherenceGrid(ProgressReport report) {
    return pw.Row(
      children: [
        _buildStatBox(
          'Overall Completion',
          '${report.completionRate.toStringAsFixed(1)}%',
          report.completionRate >= 70 ? _successColor : _warningColor,
        ),
        pw.SizedBox(width: 10),
        _buildStatBox(
          'Total Sessions',
          '${report.totalSessions}',
          _headerColor,
        ),
        pw.SizedBox(width: 10),
        _buildStatBox(
          'Current Streak',
          '${report.currentStreak} days',
          _accentColor,
        ),
        pw.SizedBox(width: 10),
        _buildStatBox(
          'Longest Streak',
          '${report.longestStreak} days',
          _accentColor,
        ),
      ],
    );
  }

  pw.Widget _buildStatBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8, color: _textSecondary),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildWeeklyBarChart(ProgressReport report) {
    if (report.weeklyData.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(20),
        alignment: pw.Alignment.center,
        child: pw.Text(
          'No weekly data available',
          style: pw.TextStyle(color: _textSecondary, fontSize: 10),
        ),
      );
    }

    final maxBars = report.weeklyData.length.clamp(1, 12);
    final data = report.weeklyData.take(maxBars).toList();

    return pw.Container(
      height: 100,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: data.map((week) {
          final height = (week.completionPercent / 100 * 70).clamp(2.0, 70.0);
          final barColor = week.completionPercent >= 70
              ? _successColor
              : week.completionPercent >= 40
                  ? _warningColor
                  : _errorColor;

          return pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 2),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    '${week.sessionsCompleted}/${week.sessionsTotal}',
                    style: pw.TextStyle(fontSize: 7, color: _textSecondary),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Container(
                    height: height,
                    decoration: pw.BoxDecoration(
                      color: barColor,
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'W${week.weekNumber}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  pw.Widget _buildSymptomTrendsTable(ProgressReport report) {
    if (report.symptomTrends.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        child: pw.Text(
          'No symptom data available. Patient should complete daily check-ins.',
          style: pw.TextStyle(color: _textSecondary, fontSize: 10),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _headerColor),
          children: [
            _buildTableHeaderCell('Symptom'),
            _buildTableHeaderCell('Trend'),
            _buildTableHeaderCell('Current Avg'),
            _buildTableHeaderCell('Previous Avg'),
            _buildTableHeaderCell('Change'),
          ],
        ),
        // Data rows
        ...report.symptomTrends.map((trend) {
          final trendLabel = trend.trend == 'improving'
              ? '▼ Improving'
              : trend.trend == 'worsening'
                  ? '▲ Worsening'
                  : '► Stable';
          final trendColor = trend.trend == 'improving'
              ? _successColor
              : trend.trend == 'worsening'
                  ? _errorColor
                  : _textSecondary;

          return pw.TableRow(
            children: [
              _buildTableCell(trend.symptomName),
              _buildTableCell(trendLabel, color: trendColor),
              _buildTableCell(
                trend.currentAverage?.toStringAsFixed(1) ?? 'N/A',
              ),
              _buildTableCell(
                trend.previousAverage?.toStringAsFixed(1) ?? 'N/A',
              ),
              _buildTableCell(
                trend.changePercent != null
                    ? '${trend.changePercent! > 0 ? '+' : ''}${trend.changePercent!.toStringAsFixed(1)}%'
                    : 'N/A',
                color: trend.changePercent != null
                    ? (trend.changePercent! < 0 ? _successColor : _errorColor)
                    : _textSecondary,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: color ?? _textPrimary,
        ),
      ),
    );
  }

  pw.Widget _buildCheckInTable(ProgressReport report, DateFormat df) {
    final entries = report.recentCheckIns.take(14).toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(3),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _headerColor),
          children: [
            _buildTableHeaderCell('Date'),
            _buildTableHeaderCell('Pain'),
            _buildTableHeaderCell('Swallow'),
            _buildTableHeaderCell('Dry Mouth'),
            _buildTableHeaderCell('Notes'),
          ],
        ),
        // Data
        ...entries.map((ci) {
          return pw.TableRow(
            children: [
              _buildTableCell(ci.date),
              _buildTableCell(
                '${ci.painLevel}/5',
                color: _levelColor(ci.painLevel),
              ),
              _buildTableCell(
                '${ci.swallowingEase}/5',
                color: _levelColor(ci.swallowingEase),
              ),
              _buildTableCell(
                '${ci.dryMouth}/5',
                color: _levelColor(ci.dryMouth),
              ),
              _buildTableCell(ci.notes ?? '—'),
            ],
          );
        }),
      ],
    );
  }

  PdfColor _levelColor(int level) {
    if (level <= 2) return _successColor;
    if (level <= 3) return _warningColor;
    return _errorColor;
  }

  pw.Widget _buildNotesSection() {
    return pw.Container(
      height: 100,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Provider notes:',
            style: pw.TextStyle(
              fontSize: 9,
              color: _textSecondary,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 8),
          // Ruled lines
          ...List.generate(
            4,
            (_) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.grey200,
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF6E8'),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: _warningColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Disclaimer',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _warningColor,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'This report is generated from patient self-reported data collected '
            'through the SwallowSafe mobile application. It is intended to '
            'supplement clinical evaluation and should not be used as the sole '
            'basis for clinical decisions. All symptom ratings are on a 1–5 '
            'scale where 1 = best and 5 = most severe.',
            style: pw.TextStyle(fontSize: 8, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  /// Export report as shareable text
  String exportAsText(ProgressReport report) {
    return report.toTextSummary();
  }

  /// Copy report to clipboard
  Future<void> copyToClipboard(ProgressReport report) async {
    final text = exportAsText(report);
    await Clipboard.setData(ClipboardData(text: text));
  }
}
