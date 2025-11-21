import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

// Sample notification data for demonstration
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  taskReminder,
  taskCompleted,
  streakMilestone,
  general,
}

// Sample notifications provider
final notificationsProvider = StateProvider<List<NotificationItem>>((ref) {
  return [
    NotificationItem(
      id: '1',
      title: 'Task Reminder',
      message: 'Don\'t forget to complete your morning workout!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.taskReminder,
    ),
    NotificationItem(
      id: '2',
      title: 'Streak Achievement! 🔥',
      message: 'Congratulations! You\'ve maintained a 7-day streak!',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.streakMilestone,
      isRead: true,
    ),
    NotificationItem(
      id: '3',
      title: 'Task Completed',
      message: 'Great job! You completed "Review project proposal"',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotificationType.taskCompleted,
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Weekly Summary',
      message: 'You completed 12 out of 15 tasks this week. Keep it up!',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.general,
    ),
  ];
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notifications = ref.watch(notificationsProvider);
    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark 
                      ? AppColors.darkSecondaryText 
                      : AppColors.lightMainText.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                // Mark all as read
                final updatedNotifications = notifications.map((n) => 
                    NotificationItem(
                      id: n.id,
                      title: n.title,
                      message: n.message,
                      timestamp: n.timestamp,
                      type: n.type,
                      isRead: true,
                    )).toList();
                ref.read(notificationsProvider.notifier).state = updatedNotifications;
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(theme, isDark)
          : _buildNotificationsList(theme, isDark, notifications),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkMainText : AppColors.lightMainText)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 50,
              color: isDark 
                  ? AppColors.darkSecondaryText 
                  : AppColors.lightMainText.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'When you have notifications, they\'ll appear here',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark 
                  ? AppColors.darkSecondaryText 
                  : AppColors.lightMainText.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(ThemeData theme, bool isDark, List<NotificationItem> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(theme, isDark, notification, index);
      },
    );
  }

  Widget _buildNotificationCard(ThemeData theme, bool isDark, NotificationItem notification, int index) {
    final timeAgo = _getTimeAgo(notification.timestamp);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notification.isRead 
              ? (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1))
              : AppColors.primaryAccent.withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon based on notification type
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                          fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  notification.message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark 
                        ? AppColors.darkSecondaryText 
                        : AppColors.lightMainText.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? AppColors.darkSecondaryText 
                        : AppColors.lightMainText.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.taskReminder:
        return AppColors.primaryAccent;
      case NotificationType.taskCompleted:
        return const Color(0xFF10B981); // Green
      case NotificationType.streakMilestone:
        return const Color(0xFFFF844B); // Orange
      case NotificationType.general:
        return const Color(0xFF6366F1); // Purple
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.taskReminder:
        return Icons.schedule;
      case NotificationType.taskCompleted:
        return Icons.check_circle;
      case NotificationType.streakMilestone:
        return Icons.local_fire_department;
      case NotificationType.general:
        return Icons.info;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}


