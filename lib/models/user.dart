import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String? avatarPath;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime lastLoginAt;

  @HiveField(6)
  bool isDarkMode;

  @HiveField(7)
  int currentStreak;

  @HiveField(8)
  int longestStreak;

  @HiveField(9)
  int totalTasksCompleted;

  @HiveField(10)
  List<String> customCategories;

  @HiveField(11)
  Map<String, String> categoryColors;

  @HiveField(12)
  bool notificationsEnabled;

  @HiveField(13)
  int notificationTime; // minutes before due date

  @HiveField(14)
  String? pinHash;

  @HiveField(15)
  bool biometricEnabled;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarPath,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    this.isDarkMode = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalTasksCompleted = 0,
    List<String>? customCategories,
    Map<String, String>? categoryColors,
    this.notificationsEnabled = true,
    this.notificationTime = 15,
    this.pinHash,
    this.biometricEnabled = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now(),
        customCategories = customCategories ?? [],
        categoryColors = categoryColors ?? {};

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isDarkMode,
    int? currentStreak,
    int? longestStreak,
    int? totalTasksCompleted,
    List<String>? customCategories,
    Map<String, String>? categoryColors,
    bool? notificationsEnabled,
    int? notificationTime,
    String? pinHash,
    bool? biometricEnabled,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      customCategories: customCategories ?? this.customCategories,
      categoryColors: categoryColors ?? this.categoryColors,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      pinHash: pinHash ?? this.pinHash,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isDarkMode': isDarkMode,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalTasksCompleted': totalTasksCompleted,
      'customCategories': customCategories,
      'categoryColors': categoryColors,
      'notificationsEnabled': notificationsEnabled,
      'notificationTime': notificationTime,
      'pinHash': pinHash,
      'biometricEnabled': biometricEnabled,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatarPath: json['avatarPath'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
      isDarkMode: json['isDarkMode'] ?? false,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalTasksCompleted: json['totalTasksCompleted'] ?? 0,
      customCategories: List<String>.from(json['customCategories'] ?? []),
      categoryColors: Map<String, String>.from(json['categoryColors'] ?? {}),
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      notificationTime: json['notificationTime'] ?? 15,
      pinHash: json['pinHash'],
      biometricEnabled: json['biometricEnabled'] ?? false,
    );
  }
}


