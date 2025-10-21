import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/category.dart';
// import '../../services/database_service.dart'; // unused

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    _loadCategories();
  }

  void _loadCategories() {
    final box = Hive.box<Category>('categories');
    final existing = box.values.toList();
    if (existing.isEmpty) {
      // seed predefined categories on first run
      for (final cat in predefinedCategories) {
        box.put(cat.id, cat);
      }
      state = box.values.toList();
    } else {
      state = existing;
    }
  }

  void addCategory(Category category) {
    final box = Hive.box<Category>('categories');
    box.put(category.id, category);
    _loadCategories();
  }

  void updateCategory(Category category) {
    final box = Hive.box<Category>('categories');
    box.put(category.id, category);
    _loadCategories();
  }

  void deleteCategory(String categoryId) {
    final box = Hive.box<Category>('categories');
    box.delete(categoryId);
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
    color: 0xFF2196F3, // Blue
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'personal',
    name: 'Personal',
    icon: '🏠',
    color: 0xFF4CAF50, // Green
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'health',
    name: 'Health',
    icon: '💚',
    color: 0xFFF44336, // Red
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'shopping',
    name: 'Shopping',
    icon: '🛒',
    color: 0xFFFF9800, // Orange
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'finance',
    name: 'Finance',
    icon: '💰',
    color: 0xFF9C27B0, // Purple
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'education',
    name: 'Education',
    icon: '📚',
    color: 0xFF607D8B, // Blue Grey
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'fitness',
    name: 'Fitness',
    icon: '💪',
    color: 0xFFE91E63, // Pink
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'travel',
    name: 'Travel',
    icon: '✈️',
    color: 0xFF00BCD4, // Cyan
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'entertainment',
    name: 'Entertainment',
    icon: '🎬',
    color: 0xFFFF5722, // Deep Orange
    createdAt: DateTime.now(),
  ),
  Category(
    id: 'family',
    name: 'Family',
    icon: '👨‍👩‍👧‍👦',
    color: 0xFF795548, // Brown
    createdAt: DateTime.now(),
  ),
];


