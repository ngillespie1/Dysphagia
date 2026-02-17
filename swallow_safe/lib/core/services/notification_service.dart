import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../constants/strings.dart';

/// Service for managing push notifications
/// Supports actionable notifications with "Done" and "Remind in 15m" actions
/// Note: Not available on web
class NotificationService {
  FlutterLocalNotificationsPlugin? _notifications;
  
  NotificationService() {
    if (!kIsWeb) {
      _notifications = FlutterLocalNotificationsPlugin();
    }
  }
  
  static const String _channelId = 'swallow_safe_exercises';
  static const String _channelName = 'Exercise Reminders';
  static const String _channelDescription = 
      'Reminders for your daily swallowing exercises';
  
  // Action identifiers
  static const String actionDone = 'done';
  static const String actionRemind = 'remind_15m';
  
  /// Initialize the notification service
  Future<void> initialize() async {
    if (kIsWeb || _notifications == null) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'exerciseReminder',
          actions: [
            DarwinNotificationAction.plain(actionDone, 'Done'),
            DarwinNotificationAction.plain(actionRemind, 'Remind in 15m'),
          ],
        ),
      ],
    );
    
    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications!.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    
    // Create Android notification channel
    await _createAndroidChannel();
  }
  
  Future<void> _createAndroidChannel() async {
    if (_notifications == null) return;
    
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    
    await _notifications!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  /// Handle notification action responses
  void _onNotificationResponse(NotificationResponse response) {
    switch (response.actionId) {
      case actionDone:
        // Mark exercise as done - could trigger a callback
        break;
      case actionRemind:
        // Schedule another notification in 15 minutes
        scheduleReminder(const Duration(minutes: 15));
        break;
    }
  }
  
  /// Request notification permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb || _notifications == null) return true; // Pretend success on web
    
    final android = _notifications!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final ios = _notifications!
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return false;
  }
  
  /// Show an immediate exercise reminder notification
  Future<void> showExerciseReminder() async {
    if (kIsWeb || _notifications == null) return;
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(actionDone, 'Done', showsUserInterface: true),
        AndroidNotificationAction(actionRemind, 'Remind in 15m'),
      ],
    );
    
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'exerciseReminder',
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications!.show(
      0,
      AppStrings.notificationTitle,
      AppStrings.notificationBody,
      details,
    );
  }
  
  /// Schedule a reminder notification
  Future<void> scheduleReminder(Duration delay) async {
    if (kIsWeb || _notifications == null) return;
    
    final scheduledTime = DateTime.now().add(delay);
    
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(actionDone, 'Done', showsUserInterface: true),
        AndroidNotificationAction(actionRemind, 'Remind in 15m'),
      ],
    );
    
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'exerciseReminder',
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications!.zonedSchedule(
      1,
      AppStrings.notificationTitle,
      AppStrings.notificationBody,
      tz.TZDateTime.from(scheduledTime, _local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
  
  /// Schedule daily reminders at specified times
  Future<void> scheduleDailyReminders(List<TimeOfDay> times) async {
    if (kIsWeb || _notifications == null) return;
    
    // Cancel existing scheduled notifications
    await _notifications!.cancelAll();
    
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
      
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        actions: [
          AndroidNotificationAction(actionDone, 'Done', showsUserInterface: true),
          AndroidNotificationAction(actionRemind, 'Remind in 15m'),
        ],
      );
      
      const iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'exerciseReminder',
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications!.zonedSchedule(
        100 + i, // Unique ID for each daily reminder
        AppStrings.notificationTitle,
        AppStrings.notificationBody,
        tz.TZDateTime.from(scheduledDate, _local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      );
    }
  }
  
  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (kIsWeb || _notifications == null) return;
    await _notifications!.cancelAll();
  }
  
  /// Initialize timezone data - call once at app startup
  static void initializeTimezone() {
    tz_data.initializeTimeZones();
  }
  
  /// Get local timezone
  tz.Location get _local => tz.local;
}
