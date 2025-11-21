import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../services/database_service.dart';
import 'auth_provider.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier(ref);
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  final Ref _ref;
  
  CategoryNotifier(this._ref) : super([]) {
    // Initial load with delay to ensure user is authenticated
    Future.delayed(const Duration(milliseconds: 100), () {
      _loadCategories();
    });
    
    // Listen to auth changes and reload categories when user changes
    _ref.listen(currentUserProvider, (previous, next) {
      final previousUserId = previous?.value?.id;
      final currentUserId = next.value?.id;
      
      // Only reload if user actually changed
      if (previousUserId != currentUserId) {
        _loadCategories();
        
        // Run migration for existing users after categories are loaded
        if (currentUserId != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (state.isNotEmpty) {
              migrateCategoryReferences();
            }
          });
        }
      }
    });
  }

  String? get _currentUserId {
    final userAsync = _ref.read(currentUserProvider);
    return userAsync.value?.id;
  }

  Future<void> _loadCategories() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      state = [];
      return;
    }
    
    try {
      var userCategories = DatabaseService.getAllCategories(userId: userId);
      
      // If user has no categories, seed with predefined ones
      if (userCategories.isEmpty) {
        await _seedPredefinedCategories(userId);
        // Reload after seeding
        userCategories = DatabaseService.getAllCategories(userId: userId);
      }
      
      state = userCategories;
    } catch (e) {
      print('Error loading categories: $e');
      // If loading fails, at least provide default categories
      try {
        await _seedPredefinedCategories(userId);
        state = DatabaseService.getAllCategories(userId: userId);
      } catch (seedError) {
        print('Error seeding categories: $seedError');
        state = [];
      }
    }
  }

  Future<void> _seedPredefinedCategories(String userId) async {
    try {
      for (final cat in predefinedCategories) {
        // Create a new category with user-specific ID and userId
        final categoryWithUser = cat.copyWith(
          id: '${userId}_${cat.id}', // Make ID user-specific
          userId: userId,
          createdAt: DateTime.now(),
        );
        await DatabaseService.saveCategory(categoryWithUser);
      }
    } catch (e) {
      print('Error seeding categories: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    
    // Ensure category has userId set and unique ID
    final categoryWithUser = category.userId.isEmpty 
        ? category.copyWith(
            id: category.id.startsWith(userId) ? category.id : '${userId}_${category.id}',
            userId: userId,
          ) 
        : category;
    
    try {
      await DatabaseService.saveCategory(categoryWithUser);
      _loadCategories(); // Reload from database
    } catch (e) {
      throw Exception('Failed to save category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    
    try {
      await DatabaseService.saveCategory(category);
      _loadCategories(); // Reload from database
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await DatabaseService.deleteCategory(categoryId);
      _loadCategories(); // Reload from database
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<void> refresh() async {
    await _loadCategories();
  }

  // Method to force reload categories - useful for debugging
  Future<void> forceReload() async {
    print('Force reloading categories...');
    final userId = _currentUserId;
    print('Current user ID: $userId');
    
    if (userId == null || userId.isEmpty) {
      print('No user ID, setting empty state');
      state = [];
      return;
    }
    
    // First check what's in the database
    final dbCategories = DatabaseService.getAllCategories(userId: userId);
    print('Categories in database: ${dbCategories.length}');
    
    if (dbCategories.isEmpty) {
      print('No categories found, seeding...');
      await _seedPredefinedCategories(userId);
      final newCategories = DatabaseService.getAllCategories(userId: userId);
      print('After seeding: ${newCategories.length} categories');
      state = newCategories;
    } else {
      print('Categories found in DB, setting state');
      state = dbCategories;
    }
    
    print('Final state has ${state.length} categories');
  }

  // Debug method to check category state
  void debugCategories() {
    final userId = _currentUserId;
    print('=== CATEGORY DEBUG ===');
    print('Current User ID: $userId');
    print('Categories in state: ${state.length}');
    for (final cat in state) {
      print('  - ID: ${cat.id}, Name: ${cat.name}, UserID: ${cat.userId}');
    }
    print('Categories in DB: ${DatabaseService.getAllCategories(userId: userId).length}');
    print('====================');
  }

  // Method to fix category references in todos and notes
  Future<void> migrateCategoryReferences() async {
    final userId = _currentUserId;
    if (userId == null) return;

    // Get all todos and notes for this user
    final todos = DatabaseService.getAllTodos(userId: userId);
    final notes = DatabaseService.getAllNotes(userId: userId);
    
    // Create a mapping from old category names/IDs to new user-specific IDs
    final categoryMapping = <String, String>{};
    for (final category in state) {
      // Map both the base name and potential old IDs to the new user-specific ID
      final baseName = category.name.toLowerCase().replaceAll(' ', '_');
      categoryMapping[baseName] = category.id;
      categoryMapping[category.name] = category.id;
      
      // Also map from potential old generic IDs
      final baseId = category.id.contains('_') ? category.id.split('_').skip(1).join('_') : category.id;
      if (baseId != category.id) {
        categoryMapping[baseId] = category.id;
      }
    }
    
    // Update todos with incorrect category references
    bool hasUpdates = false;
    for (final todo in todos) {
      if (todo.category.isNotEmpty && !todo.category.startsWith(userId)) {
        final newCategoryId = categoryMapping[todo.category] ?? categoryMapping[todo.category.toLowerCase()];
        if (newCategoryId != null) {
          final updatedTodo = todo.copyWith(category: newCategoryId);
          await DatabaseService.saveTodo(updatedTodo);
          hasUpdates = true;
        }
      }
    }
    
    // Update notes with incorrect category references  
    for (final note in notes) {
      if (note.category != null && note.category!.isNotEmpty && !note.category!.startsWith(userId)) {
        final newCategoryId = categoryMapping[note.category!] ?? categoryMapping[note.category!.toLowerCase()];
        if (newCategoryId != null) {
          final updatedNote = note.copyWith(category: newCategoryId);
          await DatabaseService.saveNote(updatedNote);
          hasUpdates = true;
        }
      }
    }
    
    if (hasUpdates) {
      print('Category references migrated successfully');
    }
  }

  Category? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      // If not found, return the first category or null
      return state.isNotEmpty ? state.first : null;
    }
  }

  // Helper method to get category by ID with fallback
  Category getCategoryByIdWithFallback(String id) {
    final category = getCategoryById(id);
    if (category != null) {
      return category;
    }
    
    // If no category found and we have categories, return first one
    if (state.isNotEmpty) {
      return state.first;
    }
    
    // If no categories at all, return a default category
    return Category(
      id: 'default',
      name: 'Default',
      icon: '📝',
      iconCodePoint: 0xe8d1, // Icons.note
      color: 0xFF2196F3,
      userId: _currentUserId ?? '',
      createdAt: DateTime.now(),
    );
  }
}

// Predefined categories with emojis
final predefinedCategories = [
  Category(
    id: 'work',
    name: 'Work',
    icon: '💼',
    iconCodePoint: 0xe8f9, // Icons.work
    color: 0xFF2196F3, // Blue
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'personal',
    name: 'Personal',
    icon: '🏠',
    iconCodePoint: 0xe88a, // Icons.home
    color: 0xFF4CAF50, // Green
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'health',
    name: 'Health',
    icon: '💚',
    iconCodePoint: 0xe548, // Icons.local_hospital
    color: 0xFFF44336, // Red
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'shopping',
    name: 'Shopping',
    icon: '🛒',
    iconCodePoint: 0xe8cc, // Icons.shopping_cart
    color: 0xFFFF9800, // Orange
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'finance',
    name: 'Finance',
    icon: '💰',
    iconCodePoint: 0xe263, // Icons.attach_money
    color: 0xFF9C27B0, // Purple
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'education',
    name: 'Education',
    icon: '📚',
    iconCodePoint: 0xe0af, // Icons.school
    color: 0xFF607D8B, // Blue Grey
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'fitness',
    name: 'Fitness',
    icon: '💪',
    iconCodePoint: 0xe566, // Icons.fitness_center
    color: 0xFFE91E63, // Pink
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'travel',
    name: 'Travel',
    icon: '✈️',
    iconCodePoint: 0xe539, // Icons.flight
    color: 0xFF00BCD4, // Cyan
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'entertainment',
    name: 'Entertainment',
    icon: '🎬',
    iconCodePoint: 0xe02c, // Icons.movie
    color: 0xFFFF5722, // Deep Orange
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'family',
    name: 'Family',
    icon: '👨‍👩‍👧‍👦',
    iconCodePoint: 0xe7ef, // Icons.people
    color: 0xFF795548, // Brown
    createdAt: DateTime.now(),
  ),
];


