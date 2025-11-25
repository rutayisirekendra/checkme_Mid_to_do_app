import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../models/notification.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allNotifications = ref.watch(notificationListProvider);
    final unreadNotifications = ref.watch(unreadNotificationsProvider);
    final readNotifications = ref.watch(readNotificationsProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                ref.read(notificationListProvider.notifier).markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(
                Icons.done_all,
                color: AppColors.primaryAccent,
                size: 20,
              ),
              label: Text(
                'Mark All Read',
                style: TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            ),
            onSelected: (value) {
              switch (value) {
                case 'delete_all_read':
                  _showDeleteAllReadDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all_read',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Delete All Read'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All'),
                  if (allNotifications.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${allNotifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unread'),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lightOverdue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Read'),
                  if (readNotifications.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.grassGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${readNotifications.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          indicatorColor: AppColors.primaryAccent,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: isDark 
              ? AppColors.darkSecondaryText 
              : AppColors.lightMainText.withValues(alpha: 0.6),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(allNotifications, 'No notifications yet', isDark),
          _buildNotificationsList(unreadNotifications, 'No unread notifications', isDark),
          _buildNotificationsList(readNotifications, 'No read notifications', isDark),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications, String emptyMessage, bool isDark) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: isDark 
                  ? AppColors.darkMainText.withValues(alpha: 0.3)
                  : AppColors.lightMainText.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: isDark 
                    ? AppColors.darkMainText.withValues(alpha: 0.6)
                    : AppColors.lightMainText.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification, isDark);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: notification.isRead 
            ? null 
            : Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.3),
                width: 1.5,
              ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: notification.isRead ? 0.05 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification type icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationTypeColor(notification.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getNotificationTypeIcon(notification.type),
                color: _getNotificationTypeColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
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
                          style: TextStyle(
                            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatNotificationTime(notification.createdAt),
                        style: TextStyle(
                          color: isDark 
                              ? AppColors.darkSecondaryText.withValues(alpha: 0.7) 
                              : AppColors.lightMainText.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      // Action buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (notification.isRead) {
                                ref.read(notificationListProvider.notifier)
                                    .markAsUnread(notification.id);
                              } else {
                                ref.read(notificationListProvider.notifier)
                                    .markAsRead(notification.id);
                              }
                            },
                            icon: Icon(
                              notification.isRead 
                                  ? Icons.mark_email_unread_outlined 
                                  : Icons.mark_email_read_outlined,
                              size: 18,
                              color: AppColors.primaryAccent,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: notification.isRead ? 'Mark as unread' : 'Mark as read',
                          ),
                          IconButton(
                            onPressed: () {
                              _showDeleteConfirmation(context, notification);
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.lightOverdue,
                            ),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.streakAchievement:
        return Icons.local_fire_department_rounded;
      case NotificationType.taskReminder:
        return Icons.schedule_rounded;
      case NotificationType.taskOverdue:
        return Icons.warning_rounded;
      case NotificationType.badgeEarned:
        return Icons.stars_rounded;
      case NotificationType.dailyMotivation:
        return Icons.lightbulb_rounded;
      case NotificationType.weeklyReport:
        return Icons.analytics_rounded;
      case NotificationType.taskCompleted:
        return Icons.check_circle_rounded;
      case NotificationType.noteReminder:
        return Icons.note_rounded;
      case NotificationType.general:
      default:
        return Icons.info_rounded;
    }
  }

  Color _getNotificationTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.streakAchievement:
        return AppColors.secondaryAccent;
      case NotificationType.taskReminder:
        return AppColors.primaryAccent;
      case NotificationType.taskOverdue:
        return AppColors.lightOverdue;
      case NotificationType.badgeEarned:
        return AppColors.grassGreen;
      case NotificationType.dailyMotivation:
        return Colors.amber;
      case NotificationType.weeklyReport:
        return Colors.purple;
      case NotificationType.taskCompleted:
        return AppColors.grassGreen;
      case NotificationType.noteReminder:
        return Colors.teal;
      case NotificationType.general:
      default:
        return AppColors.primaryAccent;
    }
  }

  String _formatNotificationTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  void _showDeleteConfirmation(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: Text('Are you sure you want to delete "${notification.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(notificationListProvider.notifier)
                    .deleteNotification(notification.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.lightOverdue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Read Notifications'),
          content: const Text(
            'Are you sure you want to delete all read notifications? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(notificationListProvider.notifier).deleteAllRead();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All read notifications deleted'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Delete All',
                style: TextStyle(color: AppColors.lightOverdue),
              ),
            ),
          ],
        );
      },
    );
  }
}
