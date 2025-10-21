// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 3;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      avatarPath: fields[3] as String?,
      createdAt: fields[4] as DateTime?,
      lastLoginAt: fields[5] as DateTime?,
      isDarkMode: fields[6] as bool,
      currentStreak: fields[7] as int,
      longestStreak: fields[8] as int,
      totalTasksCompleted: fields[9] as int,
      customCategories: (fields[10] as List?)?.cast<String>(),
      categoryColors: (fields[11] as Map?)?.cast<String, String>(),
      notificationsEnabled: fields[12] as bool,
      notificationTime: fields[13] as int,
      pinHash: fields[14] as String?,
      biometricEnabled: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.avatarPath)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastLoginAt)
      ..writeByte(6)
      ..write(obj.isDarkMode)
      ..writeByte(7)
      ..write(obj.currentStreak)
      ..writeByte(8)
      ..write(obj.longestStreak)
      ..writeByte(9)
      ..write(obj.totalTasksCompleted)
      ..writeByte(10)
      ..write(obj.customCategories)
      ..writeByte(11)
      ..write(obj.categoryColors)
      ..writeByte(12)
      ..write(obj.notificationsEnabled)
      ..writeByte(13)
      ..write(obj.notificationTime)
      ..writeByte(14)
      ..write(obj.pinHash)
      ..writeByte(15)
      ..write(obj.biometricEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
