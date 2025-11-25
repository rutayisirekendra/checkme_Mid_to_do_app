import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../models/notification.dart';

class DatabaseService {
  static const String _todosBoxName = 'todos';
  static const String _usersBoxName = 'users';
  static const String _notesBoxName = 'notes';
  static const String _categoriesBoxName = 'categories';
  static const String _notificationsBoxName = 'notifications';
  static const String _settingsBoxName = 'settings';

  static late Box<Todo> _todosBox;
  static late Box<User> _usersBox;
  static late Box<Note> _notesBox;
  static late Box<Category> _categoriesBox;
  static late Box<NotificationModel> _notificationsBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters only if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PriorityAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(NoteAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(NoteTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RecurrenceTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(NotificationModelAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(NotificationTypeAdapter());
    }

    try {
      // Open boxes with error handling for TypeId conflicts
      _todosBox = await Hive.openBox<Todo>(_todosBoxName);
      _usersBox = await Hive.openBox<User>(_usersBoxName);
      _notesBox = await Hive.openBox<Note>(_notesBoxName);
      _categoriesBox = await Hive.openBox<Category>(_categoriesBoxName);
      _notificationsBox = await Hive.openBox<NotificationModel>(_notificationsBoxName);
      _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    } catch (e) {
      // If there's a TypeAdapter conflict, clear the boxes and recreate them
      print('TypeAdapter conflict detected, clearing boxes: $e');
      await _clearAllBoxes();
      
      // Retry opening boxes
      _todosBox = await Hive.openBox<Todo>(_todosBoxName);
      _usersBox = await Hive.openBox<User>(_usersBoxName);
      _notesBox = await Hive.openBox<Note>(_notesBoxName);
      _categoriesBox = await Hive.openBox<Category>(_categoriesBoxName);
      _notificationsBox = await Hive.openBox<NotificationModel>(_notificationsBoxName);
      _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    }
  }

  static Future<void> _clearAllBoxes() async {
    try {
      await Hive.deleteBoxFromDisk(_todosBoxName);
      await Hive.deleteBoxFromDisk(_usersBoxName);
      await Hive.deleteBoxFromDisk(_notesBoxName);
      await Hive.deleteBoxFromDisk(_categoriesBoxName);
      await Hive.deleteBoxFromDisk(_notificationsBoxName);
      await Hive.deleteBoxFromDisk(_settingsBoxName);
    } catch (e) {
      print('Error clearing boxes: $e');
    }
  }

  // Todo operations
  static Future<void> saveTodo(Todo todo) async {
    await _todosBox.put(todo.id, todo);
  }

  static Future<void> deleteTodo(String todoId) async {
    await _todosBox.delete(todoId);
  }

  static Todo? getTodo(String todoId) {
    return _todosBox.get(todoId);
  }

  static List<Todo> getAllTodos({String? userId}) {
    if (userId == null || userId.isEmpty) {
      return _todosBox.values.toList();
    }
    return _todosBox.values
        .where((todo) => todo.userId == userId)
        .toList();
  }

  // Alias for getAllTodos for backward compatibility
  static List<Todo> getTodos({String? userId}) {
    return getAllTodos(userId: userId);
  }

  static List<Todo> getTodosByCategory(String category, {String? userId}) {
    return _todosBox.values
        .where((todo) => 
            todo.category == category && 
            (userId == null || userId.isEmpty || todo.userId == userId))
        .toList();
  }

  static List<Todo> getCompletedTodos({String? userId}) {
    return _todosBox.values
        .where((todo) => 
            todo.isCompleted && 
            (userId == null || userId.isEmpty || todo.userId == userId))
        .toList();
  }

  static List<Todo> getPendingTodos({String? userId}) {
    return _todosBox.values
        .where((todo) => 
            !todo.isCompleted && 
            (userId == null || userId.isEmpty || todo.userId == userId))
        .toList();
  }

  static List<Todo> getOverdueTodos({String? userId}) {
    return _todosBox.values
        .where((todo) => 
            todo.isOverdue && 
            (userId == null || userId.isEmpty || todo.userId == userId))
        .toList();
  }

  static List<Todo> getTodosByDate(DateTime date, {String? userId}) {
    return _todosBox.values
        .where((todo) => 
            todo.dueDate != null && 
            todo.dueDate!.year == date.year &&
            todo.dueDate!.month == date.month &&
            todo.dueDate!.day == date.day &&
            (userId == null || userId.isEmpty || todo.userId == userId))
        .toList();
  }

  static List<Todo> searchTodos(String query, {String? userId}) {
    final lowercaseQuery = query.toLowerCase();
    return _todosBox.values
        .where((todo) => 
            (todo.title.toLowerCase().contains(lowercaseQuery) ||
            todo.description.toLowerCase().contains(lowercaseQuery) ||
            todo.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))) &&
            (userId == null || userId.isEmpty || todo.userId == userId))
        .toList();
  }

  // User operations
  static Future<void> saveUser(User user) async {
    await _usersBox.put(user.id, user);
  }

  static User? getCurrentUser() {
    final users = _usersBox.values.toList();
    return users.isNotEmpty ? users.first : null;
  }
  
  static User? getUserById(String userId) {
    return _usersBox.get(userId);
  }

  static Future<void> deleteUser(String userId) async {
    await _usersBox.delete(userId);
  }

  // Category operations
  static Future<void> saveCategory(Category category) async {
    await _categoriesBox.put(category.id, category);
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _categoriesBox.delete(categoryId);
  }

  static Category? getCategory(String categoryId) {
    return _categoriesBox.get(categoryId);
  }

  static List<Category> getAllCategories({String? userId}) {
    if (userId == null || userId.isEmpty) {
      return _categoriesBox.values.toList();
    }
    return _categoriesBox.values
        .where((category) => category.userId == userId)
        .toList();
  }

  // Note operations
  static Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  static Future<void> deleteNote(String noteId) async {
    await _notesBox.delete(noteId);
  }

  static Note? getNote(String noteId) {
    return _notesBox.get(noteId);
  }

  static List<Note> getAllNotes({String? userId}) {
    if (userId == null || userId.isEmpty) {
      return _notesBox.values.toList();
    }
    return _notesBox.values
        .where((note) => note.userId == userId)
        .toList();
  }

  static List<Note> getNotesByTodo(String todoId, {String? userId}) {
    return _notesBox.values
        .where((note) => 
            note.todoId == todoId &&
            (userId == null || userId.isEmpty || note.userId == userId))
        .toList();
  }

  static List<Note> getPinnedNotes({String? userId}) {
    return _notesBox.values
        .where((note) => 
            note.isPinned &&
            (userId == null || userId.isEmpty || note.userId == userId))
        .toList();
  }

  static List<Note> searchNotes(String query, {String? userId}) {
    final lowercaseQuery = query.toLowerCase();
    return _notesBox.values
        .where((note) => 
            (note.title.toLowerCase().contains(lowercaseQuery) ||
            note.content.toLowerCase().contains(lowercaseQuery) ||
            note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery))) &&
            (userId == null || userId.isEmpty || note.userId == userId))
        .toList();
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Statistics
  static int getTotalTodosCount({String? userId}) {
    if (userId == null || userId.isEmpty) {
      return _todosBox.length;
    }
    return _todosBox.values
        .where((todo) => todo.userId == userId)
        .length;
  }

  static int getCompletedTodosCount({String? userId}) {
    return _todosBox.values
        .where((todo) => 
            todo.isCompleted &&
            (userId == null || userId.isEmpty || todo.userId == userId))
        .length;
  }

  static int getPendingTodosCount({String? userId}) {
    return _todosBox.values
        .where((todo) => 
            !todo.isCompleted &&
            (userId == null || userId.isEmpty || todo.userId == userId))
        .length;
  }

  static int getOverdueTodosCount({String? userId}) {
    return _todosBox.values
        .where((todo) => 
            todo.isOverdue &&
            (userId == null || userId.isEmpty || todo.userId == userId))
        .length;
  }

  static double getCompletionRate({String? userId}) {
    final total = getTotalTodosCount(userId: userId);
    if (total == 0) return 0.0;
    return getCompletedTodosCount(userId: userId) / total;
  }

  // Notification CRUD operations
  static Future<void> saveNotification(NotificationModel notification) async {
    await _notificationsBox.put(notification.id, notification);
  }

  static NotificationModel? getNotification(String id) {
    return _notificationsBox.get(id);
  }

  static List<NotificationModel> getAllNotifications({String? userId}) {
    if (userId == null || userId.isEmpty) {
      return _notificationsBox.values.toList();
    }
    return _notificationsBox.values
        .where((notification) => notification.userId == userId)
        .toList();
  }

  static Future<void> deleteNotification(String id) async {
    await _notificationsBox.delete(id);
  }

  static List<NotificationModel> getUnreadNotifications({String? userId}) {
    if (userId == null || userId.isEmpty) {
      return _notificationsBox.values
          .where((notification) => !notification.isRead)
          .toList();
    }
    return _notificationsBox.values
        .where((notification) => notification.userId == userId && !notification.isRead)
        .toList();
  }

  static int getUnreadNotificationsCount({String? userId}) {
    if (userId == null || userId.isEmpty) {
      return _notificationsBox.values
          .where((notification) => !notification.isRead)
          .length;
    }
    return _notificationsBox.values
        .where((notification) => notification.userId == userId && !notification.isRead)
        .length;
  }

  // Cleanup
  static Future<void> clearAllData() async {
    await _todosBox.clear();
    await _usersBox.clear();
    await _notesBox.clear();
    await _categoriesBox.clear();
    await _notificationsBox.clear();
    await _settingsBox.clear();
  }

  static Future<void> close() async {
    await _todosBox.close();
    await _usersBox.close();
    await _notesBox.close();
    await _categoriesBox.close();
    await _notificationsBox.close();
    await _settingsBox.close();
  }
}
