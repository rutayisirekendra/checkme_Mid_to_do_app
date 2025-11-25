import 'package:hive/hive.dart';

part 'notification.g.dart';

@HiveType(typeId: 7)
class NotificationModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String title;
  
  @HiveField(3)
  final String message;
  
  @HiveField(4)
  final NotificationType type;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  final bool isRead;
  
  @HiveField(7)
  final String? actionId; // For notifications that link to specific todos/notes
  
  @HiveField(8)
  final Map<String, dynamic>? metadata; // Additional data

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionId,
    this.metadata,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? actionId,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionId: actionId ?? this.actionId,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionId': actionId,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      actionId: json['actionId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

@HiveType(typeId: 8)
enum NotificationType {
  @HiveField(0)
  general,
  
  @HiveField(1)
  taskReminder,
  
  @HiveField(2)
  taskOverdue,
  
  @HiveField(3)
  streakAchievement,
  
  @HiveField(4)
  badgeEarned,
  
  @HiveField(5)
  dailyMotivation,
  
  @HiveField(6)
  weeklyReport,
  
  @HiveField(7)
  taskCompleted,
  
  @HiveField(8)
  noteReminder,
}
