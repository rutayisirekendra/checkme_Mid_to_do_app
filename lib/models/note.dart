import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note.g.dart';

@HiveType(typeId: 4)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime updatedAt;

  @HiveField(5)
  String? todoId; // If linked to a todo

  @HiveField(6)
  List<String> attachments;

  @HiveField(7)
  List<String> tags;

  @HiveField(8)
  bool isPinned;

  @HiveField(9)
  bool isLocked;

  @HiveField(10)
  NoteType type;

  @HiveField(11)
  String? category;

  Note({
    String? id,
    required this.title,
    this.content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.todoId,
    List<String>? attachments,
    List<String>? tags,
    this.isPinned = false,
    this.isLocked = false,
    this.type = NoteType.text,
    this.category,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        attachments = attachments ?? [],
        tags = tags ?? [];

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? todoId,
    List<String>? attachments,
    List<String>? tags,
    bool? isPinned,
    bool? isLocked,
    NoteType? type,
    String? category,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      todoId: todoId ?? this.todoId,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'todoId': todoId,
      'attachments': attachments,
      'tags': tags,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'type': type.name,
      'category': category,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      todoId: json['todoId'],
      attachments: List<String>.from(json['attachments'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] ?? false,
      isLocked: json['isLocked'] ?? false,
      type: NoteType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NoteType.text,
      ),
      category: json['category'],
    );
  }
}

@HiveType(typeId: 5)
enum NoteType {
  @HiveField(0)
  text,
  @HiveField(1)
  voice,
  @HiveField(2)
  image,
  @HiveField(3)
  mixed,
}


