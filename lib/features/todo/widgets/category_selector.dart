import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/category_provider.dart';
import '../../../core/theme/app_colors.dart';

class CategorySelector extends ConsumerWidget {
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category_rounded,
              color: AppColors.secondaryAccent,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showCreateCategoryDialog(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppColors.secondaryAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Custom',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            itemBuilder: (context, index) {
              if (index == categories.length) {
                // Add custom category option
                return GestureDetector(
                  onTap: () => _showCreateCategoryDialog(context, ref),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondaryAccent.withValues(alpha: 0.1),
                          AppColors.primaryAccent.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.secondaryAccent,
                                AppColors.primaryAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryAccent,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              final category = categories[index];
              final isSelected = selectedCategoryId == category.id;
              
              return GestureDetector(
                onTap: () => onCategorySelected(category.id),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(category.color).withValues(alpha: 0.2),
                              Color(category.color).withValues(alpha: 0.1),
                            ],
                          )
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              isDark ? AppColors.darkCard : AppColors.white,
                              isDark ? AppColors.darkSurface : AppColors.lightBackground.withValues(alpha: 0.5),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Color(category.color)
                          : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.2)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Color(category.color).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(category.color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(category.color).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected 
                              ? Color(category.color)
                              : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCreateCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Category'),
        content: const Text('Custom category creation coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

}
