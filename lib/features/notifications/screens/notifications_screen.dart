import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/notification.dart';
import '../../../shared/providers/notification_provider.dart';
import '../widgets/notification_item.dart';

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
    final notifications = ref.watch(notificationListProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    
    final allNotifications = notifications;
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();
    final readNotifications = notifications.where((n) => n.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green[600],
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green[600],
          tabs: [
            Tab(
              text: 'All (${allNotifications.length})',
            ),
            Tab(
              text: 'Unread ($unreadCount)',
            ),
            Tab(
              text: 'Read (${readNotifications.length})',
            ),
          ],
        ),
        actions: [
          if (unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: () async {
                await ref.read(notificationListProvider.notifier).markAllAsRead();
              },
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: Colors.green[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(allNotifications),
          _buildNotificationsList(unreadNotifications),
          _buildNotificationsList(readNotifications),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationItem(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
          onMarkAsRead: () => _markAsRead(notification),
          onMarkAsUnread: () => _markAsUnread(notification),
          onDelete: () => _deleteNotification(notification),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you have notifications, they\'ll appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      _markAsRead(notification);
    }
    // TODO: Handle specific notification actions based on type
  }

  void _markAsRead(NotificationModel notification) {
    if (!notification.isRead) {
      ref.read(notificationListProvider.notifier).markAsRead(notification.id);
    }
  }

  void _markAsUnread(NotificationModel notification) {
    if (notification.isRead) {
      ref.read(notificationListProvider.notifier).markAsUnread(notification.id);
    }
  }

  void _deleteNotification(NotificationModel notification) {
    ref.read(notificationListProvider.notifier).deleteNotification(notification.id);
  }
}