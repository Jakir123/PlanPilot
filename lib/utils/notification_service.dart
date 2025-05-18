import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../screens/permission_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static const channelId = 'todo_reminders';
  static const channelName = 'Todo Reminders';
  static const channelDescription = 'Notifications for upcoming todos';

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Create notification channel
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
        showBadge: true,
      ),
    );

    // Request notification permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          throw Exception('Notification permission is required');
        }
      }
    }
  }

  static Future<bool> checkAndScheduleReminder(
    BuildContext context,
    String title,
    String description,
    DateTime dueDateTime,
    String id,
  ) async {
    try {
      // First check exact alarms permission
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 31) { // Android 12 and above
          final hasPermission = await Permission.scheduleExactAlarm.isGranted;
          if (!hasPermission) {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => const PermissionScreen(),
            );
            return false;
          }
        }
      }

      // Then check notification permission
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        if (!result.isGranted) {
          throw Exception('Notification permission is required');
        }
      }

      // Get the local time zone
      final localTimeZone = tz.local;
      final scheduledTime = tz.TZDateTime.from(dueDateTime, localTimeZone);

      // Create notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        visibility: NotificationVisibility.public,
        enableLights: true,
        color: const Color(0xFF2196F3),
        ticker: 'Todo Reminder',
        groupKey: channelId,
      );

      final iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notifications.zonedSchedule(
        id.hashCode,
        title,
        description,
        scheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      return true;
    } catch (e) {
      print('Error scheduling notification: $e');
      return false;
    }
  }

  static Future<bool> checkAndCancelReminder(
    BuildContext context,
    String id,
  ) async {
    try {
      // Check if we need to request exact alarms permission
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 31) { // Android 12 and above
          // For Android 12+, we need to check if the app has the exact alarms permission
          final hasPermission = await Permission.scheduleExactAlarm.isGranted;
          if (!hasPermission) {
            // Show permission screen
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => const PermissionScreen(),
            );
            return false;
          }
        }
      }

      // Cancel the notification if permission is granted
      await _notifications.cancel(id.hashCode);
      return true;
    } catch (e) {
      print('Error cancelling notification: $e');
      return false;
    }
    await _notifications.cancel(id.hashCode);
  }

  static Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }
}
