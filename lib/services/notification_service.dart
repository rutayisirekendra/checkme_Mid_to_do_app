import 'package:flutter_local_notifications/flutter_local_notifications.dart' as notifications;
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/todo.dart';

class NotificationService {
  static final notifications.FlutterLocalNotificationsPlugin _notifications =
      notifications.FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const notifications.AndroidInitializationSettings initializationSettingsAndroid =
        notifications.AndroidInitializationSettings('@mipmap/ic_launcher');

    const notifications.DarwinInitializationSettings initializationSettingsIOS =
        notifications.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const notifications.InitializationSettings initializationSettings =
        notifications.InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  static Future<void> _onNotificationTapped(notifications.NotificationResponse response) async {
    // Handle notification tap
    // You can navigate to specific screens based on the payload
  }

  static Future<void> scheduleTodoNotification(Todo todo) async {
    if (todo.dueDate == null || todo.isCompleted) return;

    final now = DateTime.now();
    final dueDate = todo.dueDate!;
    
    // Don't schedule if due date is in the past
    if (dueDate.isBefore(now)) return;

    const notifications.AndroidNotificationDetails androidDetails = notifications.AndroidNotificationDetails(
      'todo_reminders',
      'Todo Reminders',
      channelDescription: 'Notifications for upcoming and overdue todos',
      importance: notifications.Importance.high,
      priority: notifications.Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notifications.DarwinNotificationDetails iosDetails = notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notifications.NotificationDetails details = notifications.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      todo.id.hashCode,
      'Todo Reminder',
      todo.title,
      tz.TZDateTime.from(dueDate, tz.local),
      details,
        androidScheduleMode: notifications.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          notifications.UILocalNotificationDateInterpretation.absoluteTime,
      payload: todo.id,
    );
  }

  static Future<void> scheduleOverdueNotification(Todo todo) async {
    if (todo.dueDate == null || todo.isCompleted) return;

    const notifications.AndroidNotificationDetails androidDetails = notifications.AndroidNotificationDetails(
      'overdue_todos',
      'Overdue Todos',
      channelDescription: 'Notifications for overdue todos',
      importance: notifications.Importance.max,
      priority: notifications.Priority.max,
      icon: '@mipmap/ic_launcher',
    );

    const notifications.DarwinNotificationDetails iosDetails = notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notifications.NotificationDetails details = notifications.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      todo.id.hashCode + 10000, // Different ID for overdue notifications
      'Overdue Todo',
      '${todo.title} is overdue!',
      details,
      payload: todo.id,
    );
  }

  static Future<void> scheduleDailyReminder() async {
    const notifications.AndroidNotificationDetails androidDetails = notifications.AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Daily reminder to check your todos',
      importance: notifications.Importance.defaultImportance,
      priority: notifications.Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const notifications.DarwinNotificationDetails iosDetails = notifications.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notifications.NotificationDetails details = notifications.NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule for 9 AM daily
    final now = DateTime.now();
    final scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);
    
    if (scheduledTime.isBefore(now)) {
      scheduledTime.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      9999, // Fixed ID for daily reminder
      'Daily CheckMe Reminder',
      'Check your todos for today!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
        androidScheduleMode: notifications.AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          notifications.UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: notifications.DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelTodoNotification(String todoId) async {
    await _notifications.cancel(todoId.hashCode);
    await _notifications.cancel(todoId.hashCode + 10000); // Cancel overdue too
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<notifications.PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  static Future<bool> areNotificationsEnabled() async {
    return await Permission.notification.isGranted;
  }

  static Future<void> requestNotificationPermission() async {
    await Permission.notification.request();
  }
}
