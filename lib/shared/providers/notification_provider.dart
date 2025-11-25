import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/notification.dart';
import '../../services/database_service.dart';
import 'auth_provider.dart';

// Notification list provider
final notificationListProvider = StateNotifierProvider<NotificationListNotifier, List<NotificationModel>>((ref) {
  return NotificationListNotifier(ref);
});

// Unread notifications count provider
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationListProvider);
  return notifications.where((notification) => !notification.isRead).length;
});

// Filtered notifications providers
final readNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationListProvider);
  return notifications.where((notification) => notification.isRead).toList();
});

final unreadNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final notifications = ref.watch(notificationListProvider);
  return notifications.where((notification) => !notification.isRead).toList();
});

// Notifications by type provider
final notificationsByTypeProvider = Provider.family<List<NotificationModel>, NotificationType>((ref, type) {
  final notifications = ref.watch(notificationListProvider);
  return notifications.where((notification) => notification.type == type).toList();
});

class NotificationListNotifier extends StateNotifier<List<NotificationModel>> {
  final Ref _ref;
  
  NotificationListNotifier(this._ref) : super([]) {
    _loadNotifications();
    // Listen to auth changes and reload notifications when user changes
    _ref.listen(currentUserProvider, (previous, next) {
      _loadNotifications();
    });
  }

  String? get _currentUserId {
    final userAsync = _ref.read(currentUserProvider);
    return userAsync.value?.id;
  }

  void _loadNotifications() {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      state = [];
      return;
    }
    
    try {
      final notifications = DatabaseService.getAllNotifications(userId: userId);
      // Sort notifications by creation date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      state = notifications;
    } catch (e) {
      // Handle database errors gracefully
      print('Error loading notifications: $e');
      state = [];
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    
    // Ensure notification has userId set
    final notificationWithUser = notification.userId.isEmpty 
        ? notification.copyWith(userId: userId) 
        : notification;

    try {
      await DatabaseService.saveNotification(notificationWithUser);
      _loadNotifications(); // Reload from database
    } catch (e) {
      throw Exception('Failed to save notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final notification = DatabaseService.getNotification(notificationId);
      if (notification != null && !notification.isRead) {
        final updatedNotification = notification.copyWith(isRead: true);
        await DatabaseService.saveNotification(updatedNotification);
        _loadNotifications(); // Reload from database
      }
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAsUnread(String notificationId) async {
    try {
      final notification = DatabaseService.getNotification(notificationId);
      if (notification != null && notification.isRead) {
        final updatedNotification = notification.copyWith(isRead: false);
        await DatabaseService.saveNotification(updatedNotification);
        _loadNotifications(); // Reload from database
      }
    } catch (e) {
      throw Exception('Failed to mark notification as unread: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    
    try {
      final unreadNotifications = state.where((n) => !n.isRead);
      for (final notification in unreadNotifications) {
        final updatedNotification = notification.copyWith(isRead: true);
        await DatabaseService.saveNotification(updatedNotification);
      }
      _loadNotifications(); // Reload from database
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await DatabaseService.deleteNotification(notificationId);
      _loadNotifications(); // Reload from database
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  Future<void> deleteAllRead() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    
    try {
      final readNotifications = state.where((n) => n.isRead);
      for (final notification in readNotifications) {
        await DatabaseService.deleteNotification(notification.id);
      }
      _loadNotifications(); // Reload from database
    } catch (e) {
      throw Exception('Failed to delete read notifications: $e');
    }
  }

  // Create notification helpers
  Future<void> createStreakNotification(int streakDays) async {
    final title = streakDays == 1 ? "First Day Achievement!" : "${streakDays} Day Streak!";
    final message = streakDays == 1 
        ? "Congratulations on completing your first task! 🎉"
        : "Amazing! You've maintained your streak for $streakDays days! 🔥";
    
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId ?? '',
      title: title,
      message: message,
      type: NotificationType.streakAchievement,
      createdAt: DateTime.now(),
      metadata: {'streakDays': streakDays},
    );
    
    await addNotification(notification);
  }

  Future<void> createTaskReminderNotification(String taskTitle, String taskId) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId ?? '',
      title: "Task Reminder",
      message: "Don't forget: $taskTitle",
      type: NotificationType.taskReminder,
      createdAt: DateTime.now(),
      actionId: taskId,
    );
    
    await addNotification(notification);
  }

  Future<void> createTaskOverdueNotification(String taskTitle, String taskId) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId ?? '',
      title: "Overdue Task",
      message: "⚠️ $taskTitle is now overdue",
      type: NotificationType.taskOverdue,
      createdAt: DateTime.now(),
      actionId: taskId,
    );
    
    await addNotification(notification);
  }

  Future<void> createTestNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUserId ?? '',
      title: "Welcome to CheckMe!",
      message: "Your todo app with notifications is ready to use! 🎉",
      type: NotificationType.general,
      createdAt: DateTime.now(),
    );
    
    await addNotification(notification);
  }

  Future<void> createSampleNotifications() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    // Create various types of sample notifications
    final sampleNotifications = [
      NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_1',
        userId: userId,
        title: "🎉 Welcome to CheckMe!",
        message: "Start your productivity journey with gamified task management!",
        type: NotificationType.general,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_2',
        userId: userId,
        title: "🔥 3 Day Streak!",
        message: "Amazing! You've maintained your streak for 3 days! Keep it up!",
        type: NotificationType.streakAchievement,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {'streakDays': 3},
      ),
      NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_3',
        userId: userId,
        title: "⭐ Badge Earned!",
        message: "Congratulations! You've earned the 'Task Master' badge for completing 10 tasks!",
        type: NotificationType.badgeEarned,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_4',
        userId: userId,
        title: "📝 Task Reminder",
        message: "Don't forget: Complete project presentation due today",
        type: NotificationType.taskReminder,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        actionId: 'sample_task_id',
      ),
      NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_5',
        userId: userId,
        title: "⚠️ Overdue Task",
        message: "Buy groceries is now overdue",
        type: NotificationType.taskOverdue,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        actionId: 'sample_task_id_2',
      ),
      NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_6',
        userId: userId,
        title: "💪 Daily Motivation",
        message: "Every small step counts! You're doing great!",
        type: NotificationType.dailyMotivation,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        id: '${DateTime.now().millisecondsSinceEpoch}_7',
        userId: userId,
        title: "✅ Task Completed",
        message: "Great job! You completed 'Morning workout' 💪",
        type: NotificationType.taskCompleted,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        actionId: 'sample_completed_task',
      ),
    ];

    // Add all sample notifications
    for (final notification in sampleNotifications) {
      await addNotification(notification);
    }
  }
}
