import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';
import '../models/user.dart';
import '../models/note.dart';
import '../models/category.dart';

class DatabaseService {
  static const String _todosBoxName = 'todos';
  static const String _usersBoxName = 'users';
  static const String _notesBoxName = 'notes';
  static const String _categoriesBoxName = 'categories';
  static const String _settingsBoxName = 'settings';

  static late Box<Todo> _todosBox;
  static late Box<User> _usersBox;
  static late Box<Note> _notesBox;
  static late Box<Category> _categoriesBox;
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

    // Open boxes
    _todosBox = await Hive.openBox<Todo>(_todosBoxName);
    _usersBox = await Hive.openBox<User>(_usersBoxName);
    _notesBox = await Hive.openBox<Note>(_notesBoxName);
    _categoriesBox = await Hive.openBox<Category>(_categoriesBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
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

  static List<Todo> getAllTodos() {
    return _todosBox.values.toList();
  }

  static List<Todo> getTodosByCategory(String category) {
    return _todosBox.values
        .where((todo) => todo.category == category)
        .toList();
  }

  static List<Todo> getCompletedTodos() {
    return _todosBox.values
        .where((todo) => todo.isCompleted)
        .toList();
  }

  static List<Todo> getPendingTodos() {
    return _todosBox.values
        .where((todo) => !todo.isCompleted)
        .toList();
  }

  static List<Todo> getOverdueTodos() {
    return _todosBox.values
        .where((todo) => todo.isOverdue)
        .toList();
  }

  static List<Todo> getTodosByDate(DateTime date) {
    return _todosBox.values
        .where((todo) => 
            todo.dueDate != null && 
            todo.dueDate!.year == date.year &&
            todo.dueDate!.month == date.month &&
            todo.dueDate!.day == date.day)
        .toList();
  }

  static List<Todo> searchTodos(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _todosBox.values
        .where((todo) => 
            todo.title.toLowerCase().contains(lowercaseQuery) ||
            todo.description.toLowerCase().contains(lowercaseQuery) ||
            todo.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
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

  static List<Category> getAllCategories() {
    return _categoriesBox.values.toList();
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

  static List<Note> getAllNotes() {
    return _notesBox.values.toList();
  }

  static List<Note> getNotesByTodo(String todoId) {
    return _notesBox.values
        .where((note) => note.todoId == todoId)
        .toList();
  }

  static List<Note> getPinnedNotes() {
    return _notesBox.values
        .where((note) => note.isPinned)
        .toList();
  }

  static List<Note> searchNotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _notesBox.values
        .where((note) => 
            note.title.toLowerCase().contains(lowercaseQuery) ||
            note.content.toLowerCase().contains(lowercaseQuery) ||
            note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
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
  static int getTotalTodosCount() {
    return _todosBox.length;
  }

  static int getCompletedTodosCount() {
    return _todosBox.values
        .where((todo) => todo.isCompleted)
        .length;
  }

  static int getPendingTodosCount() {
    return _todosBox.values
        .where((todo) => !todo.isCompleted)
        .length;
  }

  static int getOverdueTodosCount() {
    return _todosBox.values
        .where((todo) => todo.isOverdue)
        .length;
  }

  static double getCompletionRate() {
    final total = getTotalTodosCount();
    if (total == 0) return 0.0;
    return getCompletedTodosCount() / total;
  }

  // Cleanup
  static Future<void> clearAllData() async {
    await _todosBox.clear();
    await _usersBox.clear();
    await _notesBox.clear();
    await _categoriesBox.clear();
    await _settingsBox.clear();
  }

  static Future<void> close() async {
    await _todosBox.close();
    await _usersBox.close();
    await _notesBox.close();
    await _categoriesBox.close();
    await _settingsBox.close();
  }
}
