// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 7;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      message: fields[3] as String,
      type: fields[4] as NotificationType,
      createdAt: fields[5] as DateTime,
      isRead: fields[6] as bool,
      actionId: fields[7] as String?,
      metadata: (fields[8] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isRead)
      ..writeByte(7)
      ..write(obj.actionId)
      ..writeByte(8)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 8;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.general;
      case 1:
        return NotificationType.taskReminder;
      case 2:
        return NotificationType.taskOverdue;
      case 3:
        return NotificationType.streakAchievement;
      case 4:
        return NotificationType.badgeEarned;
      case 5:
        return NotificationType.dailyMotivation;
      case 6:
        return NotificationType.weeklyReport;
      case 7:
        return NotificationType.taskCompleted;
      case 8:
        return NotificationType.noteReminder;
      default:
        return NotificationType.general;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.general:
        writer.writeByte(0);
        break;
      case NotificationType.taskReminder:
        writer.writeByte(1);
        break;
      case NotificationType.taskOverdue:
        writer.writeByte(2);
        break;
      case NotificationType.streakAchievement:
        writer.writeByte(3);
        break;
      case NotificationType.badgeEarned:
        writer.writeByte(4);
        break;
      case NotificationType.dailyMotivation:
        writer.writeByte(5);
        break;
      case NotificationType.weeklyReport:
        writer.writeByte(6);
        break;
      case NotificationType.taskCompleted:
        writer.writeByte(7);
        break;
      case NotificationType.noteReminder:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
