import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo.dart';
import '../../services/database_service.dart';
import '../../services/streak_service.dart';
import 'auth_provider.dart';

// Todo list provider
final todoListProvider = StateNotifierProvider<TodoListNotifier, List<Todo>>((ref) {
  return TodoListNotifier(ref);
});

// Search query provider
final searchQueryProvider = StateNotifierProvider<SearchQueryNotifier, String>((ref) {
  return SearchQueryNotifier();
});

// Filtered todo list provider
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final sortBy = ref.watch(sortByProvider);
  final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);
  final selectedPriority = ref.watch(selectedPriorityFilterProvider);

  List<Todo> filteredTodos = todos;

  // Apply search filter
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filteredTodos = filteredTodos.where((todo) =>
        todo.title.toLowerCase().contains(query) ||
        todo.description.toLowerCase().contains(query) ||
        todo.tags.any((tag) => tag.toLowerCase().contains(query))).toList();
  }

  // Apply category filter
  if (selectedCategoryId != null && selectedCategoryId.isNotEmpty && selectedCategoryId != 'all') {
    filteredTodos = filteredTodos.where((todo) => todo.category == selectedCategoryId).toList();
  }

  // Apply explicit priority filter
  if (selectedPriority != null) {
    filteredTodos = filteredTodos.where((todo) => todo.priority == selectedPriority).toList();
  }

  // Apply status/time filter
  if (filter != TodoFilter.all) {
    switch (filter) {
      case TodoFilter.pending:
        filteredTodos = filteredTodos.where((todo) => !todo.isCompleted).toList();
        break;
      case TodoFilter.completed:
        filteredTodos = filteredTodos.where((todo) => todo.isCompleted).toList();
        break;
      case TodoFilter.overdue:
        filteredTodos = filteredTodos.where((todo) => todo.isOverdue).toList();
        break;
      case TodoFilter.today:
        final today = DateTime.now();
        filteredTodos = filteredTodos.where((todo) =>
            todo.dueDate != null &&
            todo.dueDate!.year == today.year &&
            todo.dueDate!.month == today.month &&
            todo.dueDate!.day == today.day).toList();
        break;
      case TodoFilter.all:
        break;
    }
  }

  // Apply sorting
  switch (sortBy) {
    case TodoSortBy.dueDate:
      filteredTodos.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      break;
    case TodoSortBy.priority:
      filteredTodos.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      break;
    case TodoSortBy.createdDate:
      filteredTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case TodoSortBy.title:
      filteredTodos.sort((a, b) => a.title.compareTo(b.title));
      break;
  }

  return filteredTodos;
});

// Todo filter provider
final todoFilterProvider = StateProvider<TodoFilter>((ref) => TodoFilter.all);

// Category filter provider (null/'all' means no category filter)
final selectedCategoryFilterProvider = StateProvider<String?>((ref) => 'all');

// Priority filter provider (null means no priority filter)
final selectedPriorityFilterProvider = StateProvider<Priority?>((ref) => null);


// Sort by provider
final sortByProvider = StateProvider<TodoSortBy>((ref) => TodoSortBy.dueDate);

// Selected todo provider
final selectedTodoProvider = StateProvider<Todo?>((ref) => null);

// Statistics providers
final todoStatsProvider = Provider<TodoStats>((ref) {
  final todos = ref.watch(todoListProvider);
  return TodoStats.fromTodos(todos);
});

class TodoListNotifier extends StateNotifier<List<Todo>> {
  final Ref _ref;
  
  TodoListNotifier(this._ref) : super([]) {
    _loadTodos();
    // Listen to auth changes and reload todos when user changes
    _ref.listen(currentUserProvider, (previous, next) {
      _loadTodos();
    });
  }

  String? get _currentUserId {
    final userAsync = _ref.read(currentUserProvider);
    return userAsync.value?.id;
  }

  void _loadTodos() {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      state = [];
      return;
    }
    state = DatabaseService.getAllTodos(userId: userId);
  }

  Future<void> addTodo(Todo todo) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    
    // Ensure todo has userId set
    final todoWithUser = todo.userId.isEmpty 
        ? todo.copyWith(userId: userId) 
        : todo;
    
    await DatabaseService.saveTodo(todoWithUser);
    _loadTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    await DatabaseService.saveTodo(todo);
    _loadTodos();
  }

  Future<void> deleteTodo(String todoId) async {
    await DatabaseService.deleteTodo(todoId);
    _loadTodos();
  }

  Future<void> toggleTodo(String todoId) async {
    final todo = DatabaseService.getTodo(todoId);
    if (todo != null) {
      final wasCompleted = todo.isCompleted;
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );
      await DatabaseService.saveTodo(updatedTodo);
      // Update streak if task was just completed (not uncompleted)
      if (!wasCompleted && updatedTodo.isCompleted) {
        try {
          final userId = _currentUserId;
          if (userId != null && userId.isNotEmpty) {
            await StreakService.updateUserStreak(userId);
          }
        } catch (e) {
          print('Error updating streak: $e');
        }
      }
      
      _loadTodos();
    }
  }

  Future<void> addSubtask(String parentId, Todo subtask) async {
    final parent = DatabaseService.getTodo(parentId);
    if (parent != null) {
      final updatedParent = parent.copyWith(
        subtasks: [...parent.subtasks, subtask],
      );
      await DatabaseService.saveTodo(updatedParent);
      _loadTodos();
    }
  }

  Future<void> updateSubtask(String parentId, Todo subtask) async {
    final parent = DatabaseService.getTodo(parentId);
    if (parent != null) {
      final updatedSubtasks = parent.subtasks.map((s) {
        return s.id == subtask.id ? subtask : s;
      }).toList();
      
      final updatedParent = parent.copyWith(subtasks: updatedSubtasks);
      await DatabaseService.saveTodo(updatedParent);
      _loadTodos();
    }
  }

  Future<void> deleteSubtask(String parentId, String subtaskId) async {
    final parent = DatabaseService.getTodo(parentId);
    if (parent != null) {
      final updatedSubtasks = parent.subtasks
          .where((s) => s.id != subtaskId)
          .toList();
      
      final updatedParent = parent.copyWith(subtasks: updatedSubtasks);
      await DatabaseService.saveTodo(updatedParent);
      _loadTodos();
    }
  }

  Future<void> refresh() async {
    _loadTodos();
  }
}

enum TodoFilter {
  all,
  pending,
  completed,
  overdue,
  today,
}

enum TodoSortBy {
  dueDate,
  priority,
  createdDate,
  title,
}

class TodoStats {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final double completionRate;

  TodoStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.completionRate,
  });

  factory TodoStats.fromTodos(List<Todo> todos) {
    final total = todos.length;
    final completed = todos.where((todo) => todo.isCompleted).length;
    final pending = todos.where((todo) => !todo.isCompleted).length;
    final overdue = todos.where((todo) => todo.isOverdue).length;
    final completionRate = total > 0 ? completed / total : 0.0;

    return TodoStats(
      total: total,
      completed: completed,
      pending: pending,
      overdue: overdue,
      completionRate: completionRate,
    );
  }
}

// Search query notifier
class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');

  void updateQuery(String query) {
    state = query;
  }

  void clearQuery() {
    state = '';
  }
}
