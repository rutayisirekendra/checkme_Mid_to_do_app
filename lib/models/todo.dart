import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  String category;

  @HiveField(7)
  Priority priority;

  @HiveField(8)
  List<String> attachments;

  @HiveField(9)
  List<Todo> subtasks;

  @HiveField(10)
  String? parentId;

  @HiveField(11)
  RecurrenceType? recurrenceType;

  @HiveField(12)
  List<String> tags;

  @HiveField(13)
  String? note;

  @HiveField(14)
  DateTime? completedAt;

  Todo({
    String? id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
    this.category = 'General',
    this.priority = Priority.medium,
    List<String>? attachments,
    List<Todo>? subtasks,
    this.parentId,
    this.recurrenceType,
    List<String>? tags,
    this.note,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        attachments = attachments ?? [],
        subtasks = subtasks ?? [],
        tags = tags ?? [];

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get hasSubtasks => subtasks.isNotEmpty;

  bool get allSubtasksCompleted {
    if (subtasks.isEmpty) return true;
    return subtasks.every((subtask) => subtask.isCompleted);
  }

  int get completedSubtasksCount {
    return subtasks.where((subtask) => subtask.isCompleted).length;
  }

  double get progress {
    if (subtasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    return completedSubtasksCount / subtasks.length;
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    String? category,
    Priority? priority,
    List<String>? attachments,
    List<Todo>? subtasks,
    String? parentId,
    RecurrenceType? recurrenceType,
    List<String>? tags,
    String? note,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      attachments: attachments ?? this.attachments,
      subtasks: subtasks ?? this.subtasks,
      parentId: parentId ?? this.parentId,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      tags: tags ?? this.tags,
      note: note ?? this.note,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'priority': priority.name,
      'attachments': attachments,
      'subtasks': subtasks.map((e) => e.toJson()).toList(),
      'parentId': parentId,
      'recurrenceType': recurrenceType?.name,
      'tags': tags,
      'note': note,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      category: json['category'] ?? 'General',
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.medium,
      ),
      attachments: List<String>.from(json['attachments'] ?? []),
      subtasks: (json['subtasks'] as List?)
          ?.map((e) => Todo.fromJson(e))
          .toList() ?? [],
      parentId: json['parentId'],
      recurrenceType: json['recurrenceType'] != null
          ? RecurrenceType.values.firstWhere(
              (e) => e.name == json['recurrenceType'],
            )
          : null,
      tags: List<String>.from(json['tags'] ?? []),
      note: json['note'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

@HiveType(typeId: 1)
enum Priority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 2)
enum RecurrenceType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}


