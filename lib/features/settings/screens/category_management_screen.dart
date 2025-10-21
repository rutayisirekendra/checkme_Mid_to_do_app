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
  final _emojiController = TextEditingController();
  Color _selectedColor = AppColors.primaryAccent;
  bool _isLoading = false;

  final List<Color> _availableColors = [
    AppColors.primaryAccent,
    AppColors.secondaryAccent,
    AppColors.grassGreen,
    AppColors.flowerPink,
    AppColors.flowerYellow,
    AppColors.flowerPurple,
    AppColors.skyBlue,
    AppColors.lightOverdue,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final id = _nameController.text.trim().toLowerCase().replaceAll(' ', '_');
      final name = _nameController.text.trim();
      final emoji = _emojiController.text.trim();
      final color = _selectedColor.value;

      final category = Category(
        id: id,
        name: name,
        icon: emoji,
        color: color,
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
        _nameController.clear();
        _emojiController.clear();
        _selectedColor = AppColors.primaryAccent;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating category: $e'),
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
                    Text(
                      'Create New Category',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
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

                    const SizedBox(height: 16),

                    // Emoji Selection
                    CustomTextField(
                      controller: _emojiController,
                      label: 'Emoji',
                      hint: 'Choose an emoji (e.g., 🏠)',
                      prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an emoji';
                        }
                        return null;
                      },
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

                    // Create Button
                    CustomButton(
                      text: 'Create Category',
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(category.color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color(category.color),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                          ),
                        ),
                        Text(
                          'Color: ${Color(category.color).toString()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Implement category deletion
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Category deletion coming soon!'),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.lightOverdue,
                    ),
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
