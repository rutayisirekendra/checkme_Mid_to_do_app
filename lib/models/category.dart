import 'package:hive/hive.dart';
// import 'package:json_annotation/json_annotation.dart'; // not used

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

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
