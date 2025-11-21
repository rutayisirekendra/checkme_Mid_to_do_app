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
    _loadCategories();
    // Listen to auth changes and reload categories when user changes
    _ref.listen(currentUserProvider, (previous, next) {
      _loadCategories();
    });
  }

  String? get _currentUserId {
    final userAsync = _ref.read(currentUserProvider);
    return userAsync.value?.id;
  }

  void _loadCategories() {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      state = [];
      return;
    }
    
    final userCategories = DatabaseService.getAllCategories(userId: userId);
    
    // If user has no categories, seed with predefined ones
    if (userCategories.isEmpty) {
      for (final cat in predefinedCategories) {
        final categoryWithUser = cat.copyWith(userId: userId);
        DatabaseService.saveCategory(categoryWithUser);
      }
      state = DatabaseService.getAllCategories(userId: userId);
    } else {
      state = userCategories;
    }
  }

  void addCategory(Category category) {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;
    
    // Ensure category has userId set
    final categoryWithUser = category.userId.isEmpty 
        ? category.copyWith(userId: userId) 
        : category;
    
    DatabaseService.saveCategory(categoryWithUser);
    _loadCategories();
  }

  void updateCategory(Category category) {
    DatabaseService.saveCategory(category);
    _loadCategories();
  }

  void deleteCategory(String categoryId) {
    DatabaseService.deleteCategory(categoryId);
    _loadCategories();
  }

  Category? getCategoryById(String id) {
    return state.firstWhere((category) => category.id == id, orElse: () => state.first);
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


