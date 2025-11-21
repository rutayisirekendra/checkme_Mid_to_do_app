import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/providers/category_provider.dart';
import '../../../models/category.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends ConsumerState<CategoryManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = AppColors.primaryAccent;
  IconData _selectedIcon = Icons.category;
  bool _isLoading = false;
  String? _editingCategoryId;

  final List<Color> _availableColors = [
    AppColors.primaryAccent,
    AppColors.secondaryAccent,
    AppColors.grassGreen,
    AppColors.flowerPink,
    AppColors.flowerYellow,
    AppColors.flowerPurple,
    AppColors.skyBlue,
    AppColors.lightOverdue,
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFF44336), // Red
    const Color(0xFFFF9800), // Orange
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFFE91E63), // Pink
    const Color(0xFF00BCD4), // Cyan
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF795548), // Brown
    const Color(0xFF009688), // Teal
    const Color(0xFFCDDC39), // Lime
    const Color(0xFFFFEB3B), // Yellow
    const Color(0xFF3F51B5), // Indigo
  ];

  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.work,
    Icons.home,
    Icons.school,
    Icons.fitness_center,
    Icons.shopping_cart,
    Icons.restaurant,
    Icons.flight,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.book,
    Icons.local_hospital,
    Icons.computer,
    Icons.brush,
    Icons.camera_alt,
    Icons.pets,
    Icons.nature,
    Icons.beach_access,
    Icons.nightlife,
    Icons.movie,
    Icons.attach_money,
    Icons.favorite,
    Icons.star,
    Icons.lightbulb,
    Icons.phone,
    Icons.email,
    Icons.calendar_today,
    Icons.games,
    Icons.headphones,
    Icons.restaurant_menu,
    Icons.local_cafe,
    Icons.directions_car,
    Icons.train,
    Icons.spa,
    Icons.child_care,
    Icons.people,
    Icons.person,
    Icons.business,
    Icons.apartment,
    Icons.celebration,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();
      final iconCodePoint = _selectedIcon.codePoint;

      if (_editingCategoryId != null) {
        // Update existing category
        final existingCategory = ref.read(categoryProvider).firstWhere((c) => c.id == _editingCategoryId);
        final updatedCategory = existingCategory.copyWith(
          name: name,
          iconCodePoint: iconCodePoint,
          color: _selectedColor.value,
        );
        ref.read(categoryProvider.notifier).updateCategory(updatedCategory);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category updated successfully!'),
              backgroundColor: AppColors.grassGreen,
            ),
          );
        }
      } else {
        // Create new category
        final id = name.toLowerCase().replaceAll(' ', '_');
        final category = Category(
          id: id,
          name: name,
          icon: '', // Empty icon string since we're using iconCodePoint
          iconCodePoint: iconCodePoint,
          color: _selectedColor.value,
          createdAt: DateTime.now(),
        );

        ref.read(categoryProvider.notifier).addCategory(category);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category created successfully!'),
              backgroundColor: AppColors.grassGreen,
            ),
          );
        }
      }

      // Reset form
      _nameController.clear();
      _selectedColor = AppColors.primaryAccent;
      _selectedIcon = Icons.category;
      _editingCategoryId = null;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.lightOverdue,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editCategory(Category category) {
    setState(() {
      _editingCategoryId = category.id;
      _nameController.text = category.name;
      _selectedColor = Color(category.color);
      _selectedIcon = IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons');
    });

    // Scroll to top to show the form
    Future.delayed(const Duration(milliseconds: 100), () {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCategoryId = null;
      _nameController.clear();
      _selectedColor = AppColors.primaryAccent;
      _selectedIcon = Icons.category;
    });
  }

  void _showDeleteConfirmation(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCategory(category);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightOverdue,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(Category category) {
    try {
      ref.read(categoryProvider.notifier).deleteCategory(category.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category "${category.name}" deleted successfully'),
            backgroundColor: AppColors.grassGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting category: $e'),
            backgroundColor: AppColors.lightOverdue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
        foregroundColor: isDark ? AppColors.darkMainText : AppColors.lightMainText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Create New Category Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _editingCategoryId != null ? 'Edit Category' : 'Create New Category',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                          ),
                        ),
                        if (_editingCategoryId != null)
                          TextButton.icon(
                            onPressed: _cancelEdit,
                            icon: const Icon(Icons.close),
                            label: const Text('Cancel'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.lightOverdue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Category Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Category Name',
                      hint: 'Enter category name',
                      prefixIcon: const Icon(Icons.category_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Icon Selection
                    Text(
                      'Choose Icon',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 280,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1),
                        ),
                      ),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemCount: _availableIcons.length,
                        itemBuilder: (context, index) {
                          final icon = _availableIcons[index];
                          final isSelected = _selectedIcon == icon;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIcon = icon;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? _selectedColor.withValues(alpha: 0.2)
                                    : (isDark ? AppColors.darkCard : AppColors.white),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected 
                                      ? _selectedColor
                                      : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1)),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Icon(
                                icon,
                                size: 24,
                                color: isSelected 
                                    ? _selectedColor
                                    : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Color Selection
                    Text(
                      'Choose Color',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _availableColors.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected 
                                    ? (isDark ? AppColors.darkMainText : AppColors.lightMainText)
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Create/Update Button
                    CustomButton(
                      text: _editingCategoryId != null ? 'Update Category' : 'Create Category',
                      onPressed: _isLoading ? null : _createCategory,
                      isLoading: _isLoading,
                      backgroundColor: isDark ? AppColors.darkAccent : AppColors.primaryAccent,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Existing Categories
            Text(
              'Existing Categories',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              ),
            ),
            const SizedBox(height: 16),

            // Categories List
            ...categories.map((category) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(category.color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons'),
                      color: Color(category.color),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _editCategory(category),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryAccent,
                    ),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(category),
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.lightOverdue,
                    ),
                    tooltip: 'Delete',
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
