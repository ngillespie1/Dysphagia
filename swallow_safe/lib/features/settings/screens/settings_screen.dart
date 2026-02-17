import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/audio_feedback_service.dart';
import '../../../core/services/data_sync_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/service_locator.dart';
import '../../../core/services/subscription_service.dart';
import '../../../core/theme/premium_theme.dart';
import '../../../data/repositories/video_cache_repository.dart';
import '../../../shared/widgets/care_team_list.dart';
import '../../../shared/widgets/xp_progress_bar.dart';
import '../../exercise/bloc/video_cache_bloc.dart';
import '../../gamification/bloc/gamification_bloc.dart';
import '../../program/bloc/program_bloc.dart';
import '../../program/bloc/program_event.dart';
import '../../program/bloc/program_state.dart';
import '../../user/bloc/user_bloc.dart';
import '../cubit/theme_cubit.dart';
import '../widgets/notification_time_picker.dart';

/// Me tab — profile, care team, preferences, subscription, and about.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  List<TimeOfDay> _notificationTimes = [
    const TimeOfDay(hour: 9, minute: 0),
    const TimeOfDay(hour: 14, minute: 0),
    const TimeOfDay(hour: 19, minute: 0),
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final dataService = getIt<DataSyncService>();
    final times = await dataService.getNotificationTimes();

    if (!mounted) return;
    setState(() {
      _notificationTimes = times.map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subscriptionService = getIt<SubscriptionService>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor:
            isDark ? PremiumTheme.darkBackground : PremiumTheme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Me',
                  style: PremiumTheme.displayMedium.copyWith(
                    color: isDark ? Colors.white : PremiumTheme.textPrimary,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 20),
                _buildProfileSection(context, isDark),
                const SizedBox(height: 20),
                _buildCareTeamSection(context, isDark),
                const SizedBox(height: 20),
                _buildPreferencesSection(context, isDark),
                const SizedBox(height: 20),
                _buildVideoDownloadsSection(context, isDark),
                const SizedBox(height: 20),
                _buildSubscriptionSection(context, isDark, subscriptionService),
                const SizedBox(height: 20),
                _buildAboutSection(context, isDark),
                const SizedBox(height: 20),
                _buildSignOutSection(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Section Label ───

  Widget _sectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: PremiumTheme.labelMedium.copyWith(
          letterSpacing: 1.2,
          color: isDark ? Colors.white.withOpacity(0.4) : PremiumTheme.textTertiary,
        ),
      ),
    );
  }

  Widget _card(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : PremiumTheme.surfaceVariant,
          width: 1,
        ),
      ),
      child: child,
    );
  }

  // ─── Profile ───

  Widget _buildProfileSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Profile', isDark),
        _card(
          isDark,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              String name = 'User';
              String email = '';

              if (state is UserLoaded) {
                name = state.user.name;
                email = state.user.email;
              }

              return Column(
                children: [
                  _SettingsTile(
                    icon: Icons.person_rounded,
                    iconColor: PremiumTheme.primary,
                    title: name,
                    subtitle:
                        email.isNotEmpty ? email : 'Tap to update your name',
                    isDark: isDark,
                    onTap: () => _showEditProfileSheet(context, name),
                  ),
                  _divider(isDark),
                  // User level display
                  BlocBuilder<GamificationBloc, GamificationState>(
                    builder: (context, gamState) {
                      if (gamState is! GamificationLoaded) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: XPProgressBar(
                          userLevel: gamState.userLevel,
                          compact: true,
                        ),
                      );
                    },
                  ),
                  _divider(isDark),
                  _SettingsTile(
                    icon: Icons.medical_information_rounded,
                    iconColor: PremiumTheme.accent,
                    title: 'Your Plan',
                    subtitle: 'Post-Stroke Recovery',
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.push(AppRoutes.programSelector);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Care Team ───

  Widget _buildCareTeamSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Care Team', isDark),
        // Editable care team list
        const CareTeamList(),
        const SizedBox(height: 12),
        // Doctor report link
        _card(
          isDark,
          child: _SettingsTile(
            icon: Icons.medical_services_rounded,
            iconColor: PremiumTheme.primary,
            title: 'Share with your care team',
            subtitle: 'Generate a report they can review',
            isDark: isDark,
            onTap: () {
              HapticFeedback.selectionClick();
              context.push(AppRoutes.doctorReport);
            },
          ),
        ),
      ],
    );
  }

  // ─── Preferences ───

  Widget _buildPreferencesSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Preferences', isDark),
        _card(
          isDark,
          child: Column(
            children: [
              // Theme
              BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return _SettingsTile(
                    icon: Icons.brightness_6_rounded,
                    iconColor: const Color(0xFF6C5CE7),
                    title: 'Theme',
                    subtitle: _themeModeName(themeState.themeMode),
                    isDark: isDark,
                    onTap: () => _showThemePicker(context),
                  );
                },
              ),
              _divider(isDark),
              // Sound effects toggle
              _SettingsTile(
                icon: Icons.music_note_rounded,
                iconColor: PremiumTheme.primary,
                title: 'Exercise Sounds',
                subtitle: getIt<AudioFeedbackService>().enabled
                    ? 'Gentle ticks, bells & cheers'
                    : 'Off for now',
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: getIt<AudioFeedbackService>().enabled,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      getIt<AudioFeedbackService>().enabled = value;
                    });
                  },
                  activeColor: PremiumTheme.primary,
                ),
              ),
              _divider(isDark),
              // Notifications toggle
              _SettingsTile(
                icon: Icons.notifications_rounded,
                iconColor: PremiumTheme.warning,
                title: 'Gentle Reminders',
                subtitle: _notificationsEnabled ? 'We\'ll nudge you' : 'Off for now',
                isDark: isDark,
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    HapticFeedback.selectionClick();
                    setState(() => _notificationsEnabled = value);
                    await _saveNotificationSettings();
                  },
                  activeColor: PremiumTheme.primary,
                ),
              ),
              if (_notificationsEnabled) ...[
                _divider(isDark),
                _SettingsTile(
                  icon: Icons.access_time_rounded,
                  iconColor: PremiumTheme.primaryLight,
                  title: 'Reminder Times',
                  subtitle: _formatTimes(_notificationTimes),
                  isDark: isDark,
                  onTap: () => _showTimePickerSheet(context),
                ),
              ],
              _divider(isDark),
              // Rest days
              BlocBuilder<ProgramBloc, ProgramState>(
                builder: (context, programState) {
                  final restDays = programState is ProgramLoaded
                      ? programState.program.effectiveRestDays
                      : <int>[];
                  return _SettingsTile(
                    icon: Icons.self_improvement_rounded,
                    iconColor: PremiumTheme.info,
                    title: 'Rest Days',
                    subtitle: restDays.isEmpty
                        ? 'None set'
                        : restDays.map(_weekdayAbbr).join(', '),
                    isDark: isDark,
                    onTap: () => _showRestDaysPicker(context, restDays),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Video Downloads ───

  Widget _buildVideoDownloadsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Video Downloads', isDark),
        _card(
          isDark,
          child: BlocBuilder<VideoCacheBloc, VideoCacheState>(
            builder: (context, cacheState) {
              final isDownloading = cacheState is VideoCacheDownloading;
              final isReady = cacheState is VideoCacheReady;

              String subtitle = 'Save exercises so you can practise anywhere';
              String sizeText = '';

              if (isReady) {
                sizeText = cacheState.formattedSize;
                subtitle = cacheState.isFullyCached
                    ? 'All videos cached ($sizeText)'
                    : '${cacheState.cachedCount} of ${cacheState.totalCount} cached ($sizeText)';
              }
              if (isDownloading) {
                subtitle =
                    'Downloading… ${cacheState.completed}/${cacheState.total}';
              }

              return Column(
                children: [
                  // Download for offline
                  _SettingsTile(
                    icon: Icons.download_rounded,
                    iconColor: PremiumTheme.primary,
                    title: 'Save for Offline',
                    subtitle: subtitle,
                    isDark: isDark,
                    trailing: isDownloading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: (cacheState as VideoCacheDownloading).progress,
                              valueColor: AlwaysStoppedAnimation(
                                  PremiumTheme.primary),
                            ),
                          )
                        : null,
                    onTap: isDownloading
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            _downloadVideosForOffline(context);
                          },
                  ),
                  _divider(isDark),
                  // Clear cache
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: PremiumTheme.error,
                    title: 'Clear Saved Videos',
                    subtitle: isReady && sizeText.isNotEmpty
                        ? 'Free up $sizeText of space'
                        : 'Nothing saved yet',
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context
                          .read<VideoCacheBloc>()
                          .add(const ClearVideoCache());
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _downloadVideosForOffline(BuildContext context) {
    // Refresh cache stats — exercises are resolved by the cache bloc itself
    context.read<VideoCacheBloc>().add(const RefreshCacheStats());
  }

  // ─── Subscription ───

  Widget _buildSubscriptionSection(
      BuildContext context, bool isDark, SubscriptionService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Subscription', isDark),
        _card(
          isDark,
          child: _SettingsTile(
            icon: Icons.workspace_premium_rounded,
            iconColor:
                service.isPro ? PremiumTheme.success : PremiumTheme.accent,
            title: service.isPro ? 'Pro Plan' : 'Free Plan',
            subtitle: service.isPro
                ? 'You have full access — enjoy!'
                : 'Unlock personalised coaching & more',
            isDark: isDark,
            trailing: service.isPro
                ? null
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: PremiumTheme.warmGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Upgrade',
                      style: PremiumTheme.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ─── About ───

  Widget _buildAboutSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('About', isDark),
        _card(
          isDark,
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                iconColor: PremiumTheme.textTertiary,
                title: 'Medical Disclaimer',
                subtitle: 'Important safety information',
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push(AppRoutes.onboardingDisclaimer);
                },
              ),
              _divider(isDark),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: PremiumTheme.textTertiary,
                title: 'Privacy Policy',
                isDark: isDark,
                onTap: () => HapticFeedback.selectionClick(),
              ),
              _divider(isDark),
              _SettingsTile(
                icon: Icons.description_outlined,
                iconColor: PremiumTheme.textTertiary,
                title: 'Terms of Service',
                isDark: isDark,
                onTap: () => HapticFeedback.selectionClick(),
              ),
              _divider(isDark),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconColor: PremiumTheme.textTertiary,
                title: 'Version',
                isDark: isDark,
                showChevron: false,
                trailing: Text(
                  '1.0.0',
                  style: PremiumTheme.bodyMedium.copyWith(
                    color: PremiumTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Sign Out ───

  Widget _buildSignOutSection(BuildContext context, bool isDark) {
    return _card(
      isDark,
      child: _SettingsTile(
        icon: Icons.logout_rounded,
        iconColor: PremiumTheme.error,
        title: 'Sign Out',
        titleColor: PremiumTheme.error,
        showChevron: false,
        isDark: isDark,
        onTap: () => _showSignOutDialog(context, isDark),
      ),
    );
  }

  // ─── Helpers ───

  Widget _divider(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: isDark ? Colors.white.withOpacity(0.06) : PremiumTheme.bgWarm,
    );
  }

  String _themeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _formatTimes(List<TimeOfDay> times) {
    return times.map((t) {
      final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final period = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:${t.minute.toString().padLeft(2, '0')} $period';
    }).join(', ');
  }

  /// Abbreviation for a weekday number (1=Mon … 7=Sun).
  String _weekdayAbbr(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  /// Full weekday name for a weekday number.
  String _weekdayFull(int weekday) {
    const names = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  /// Shows a bottom sheet where the user can toggle rest days.
  void _showRestDaysPicker(BuildContext context, List<int> currentRestDays) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = Set<int>.from(currentRestDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? PremiumTheme.darkBackground : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PremiumTheme.textMuted.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose Your Rest Days',
                    style: PremiumTheme.headlineSmall.copyWith(
                      color:
                          isDark ? Colors.white : PremiumTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rest days won\'t break your streak — they help your muscles recover.',
                    style: PremiumTheme.bodySmall.copyWith(
                      color: PremiumTheme.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Day chips
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(7, (i) {
                      final day = i + 1; // 1=Mon
                      final isSelected = selected.contains(day);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() {
                            if (isSelected) {
                              selected.remove(day);
                            } else {
                              selected.add(day);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 82,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PremiumTheme.info.withOpacity(0.12)
                                : (isDark
                                    ? Colors.white.withOpacity(0.04)
                                    : PremiumTheme.surfaceVariant
                                        .withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? PremiumTheme.info.withOpacity(0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.self_improvement_rounded
                                    : Icons.fitness_center_rounded,
                                size: 18,
                                color: isSelected
                                    ? PremiumTheme.info
                                    : PremiumTheme.textTertiary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _weekdayFull(day).substring(0, 3),
                                style: PremiumTheme.labelSmall.copyWith(
                                  color: isSelected
                                      ? PremiumTheme.info
                                      : (isDark
                                          ? Colors.white70
                                          : PremiumTheme.textSecondary),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _saveRestDays(selected.toList()..sort());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save rest days',
                        style: PremiumTheme.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Persist new rest days via ProgramBloc.
  void _saveRestDays(List<int> restDays) {
    final programState = context.read<ProgramBloc>().state;
    if (programState is ProgramLoaded) {
      context.read<ProgramBloc>().add(
            UpdateRestDays(restDays),
          );
    }
    setState(() {}); // refresh settings UI
  }

  Future<void> _saveNotificationSettings() async {
    final dataService = getIt<DataSyncService>();
    final notificationService = getIt<NotificationService>();

    final timeStrings = _notificationTimes.map((t) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }).toList();

    await dataService.updateNotificationSettings(
      enabled: _notificationsEnabled,
      times: timeStrings,
    );

    if (_notificationsEnabled) {
      await notificationService.scheduleDailyReminders(_notificationTimes);
    } else {
      await notificationService.cancelAll();
    }
  }

  void _showThemePicker(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider.value(
          value: themeCubit,
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? PremiumTheme.darkSurface
                      : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: PremiumTheme.textMuted,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Pick a look',
                          style: PremiumTheme.headlineLarge),
                      const SizedBox(height: 20),
                      _ThemeOption(
                        icon: Icons.phone_android_rounded,
                        label: 'System default',
                        subtitle: 'Follows your device',
                        isSelected: state.isSystemMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<ThemeCubit>()
                              .setThemeMode(ThemeMode.system);
                          Navigator.pop(ctx);
                        },
                      ),
                      const SizedBox(height: 8),
                      _ThemeOption(
                        icon: Icons.light_mode_rounded,
                        label: 'Light',
                        subtitle: 'Warm and bright',
                        isSelected: state.isLightMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<ThemeCubit>()
                              .setThemeMode(ThemeMode.light);
                          Navigator.pop(ctx);
                        },
                      ),
                      const SizedBox(height: 8),
                      _ThemeOption(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark',
                        subtitle: 'Easier on the eyes at night',
                        isSelected: state.isDarkMode,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context
                              .read<ThemeCubit>()
                              .setThemeMode(ThemeMode.dark);
                          Navigator.pop(ctx);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showTimePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => NotificationTimePicker(
        times: _notificationTimes,
        onSave: (times) async {
          setState(() => _notificationTimes = times);
          await _saveNotificationSettings();
          if (mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: isDark ? PremiumTheme.darkSurface : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text('Update your name', style: PremiumTheme.headlineMedium),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: PremiumTheme.bodyLarge,
              decoration:
                  PremiumTheme.inputDecoration(hintText: 'Your name'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = controller.text.trim();
                  if (name.isNotEmpty) {
                    context.read<UserBloc>().add(UpdateUserName(name));
                  }
                  Navigator.pop(ctx);
                },
                style: PremiumTheme.primaryButton,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ConfirmationSheet(
        title: 'Heading out?',
        message: 'Don\'t worry — your progress is saved safely on this device.',
        confirmLabel: 'Sign Out',
        confirmColor: PremiumTheme.error,
        isDark: isDark,
        onConfirm: () async {
          Navigator.pop(ctx);
          final dataService = getIt<DataSyncService>();
          await dataService.logout();
          if (mounted) {
            context.go(AppRoutes.onboardingWelcome);
          }
        },
      ),
    );
  }
}

// ─── Settings Tile ───

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? titleColor;
  final bool showChevron;
  final bool isDark;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.titleColor,
    this.showChevron = true,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$title${subtitle != null ? ', $subtitle' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: PremiumTheme.headlineSmall.copyWith(
                          color: titleColor ??
                              (isDark
                                  ? Colors.white
                                  : PremiumTheme.textPrimary),
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: PremiumTheme.bodySmall.copyWith(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : PremiumTheme.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (showChevron && onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: PremiumTheme.textTertiary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Theme Option ───

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label theme option',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? PremiumTheme.darkPrimarySoft
                      : PremiumTheme.primarySoft)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? (isDark
                            ? PremiumTheme.darkPrimary
                            : PremiumTheme.primary)
                        .withOpacity(0.3)
                    : (isDark
                        ? PremiumTheme.darkSurfaceVariant
                        : PremiumTheme.surfaceVariant),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? (isDark
                          ? PremiumTheme.darkPrimary
                          : PremiumTheme.primary)
                      : (isDark
                          ? PremiumTheme.darkTextSecondary
                          : PremiumTheme.textSecondary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: PremiumTheme.headlineSmall.copyWith(
                          color: isSelected
                              ? (isDark
                                  ? PremiumTheme.darkPrimary
                                  : PremiumTheme.primary)
                              : (isDark
                                  ? PremiumTheme.darkTextPrimary
                                  : PremiumTheme.textPrimary),
                          fontSize: 15,
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
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark
                          ? PremiumTheme.darkPrimary
                          : PremiumTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: isDark
                          ? PremiumTheme.darkBackground
                          : Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Confirmation Sheet ───

class _ConfirmationSheet extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;
  final bool isDark;

  const _ConfirmationSheet({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.onConfirm,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? PremiumTheme.darkSurface : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PremiumTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(title, style: PremiumTheme.headlineLarge),
            const SizedBox(height: 12),
            Text(
              message,
              style: PremiumTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: PremiumTheme.textMuted),
                    ),
                    child: Text(
                      'Cancel',
                      style: PremiumTheme.button.copyWith(
                        color: PremiumTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style:
                          PremiumTheme.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
