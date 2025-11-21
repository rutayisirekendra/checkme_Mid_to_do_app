import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 6)
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String icon;

  @HiveField(3)
  final int color;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String userId;

  @HiveField(6)
  final int? iconCodePoint;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.userId = '',
    this.iconCodePoint,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String? ?? '',
      iconCodePoint: json['iconCodePoint'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
      'iconCodePoint': iconCodePoint,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    DateTime? createdAt,
    String? userId,
    int? iconCodePoint,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }
  
  // Helper to get icon with fallback to default
  int get effectiveIconCodePoint => iconCodePoint ?? 0xe318; // Icons.category
}
