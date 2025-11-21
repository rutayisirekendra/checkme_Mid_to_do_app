import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/note.dart';
import '../../../models/category.dart';
import '../../../shared/providers/category_provider.dart';

class ModernNoteCard extends ConsumerWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTogglePin;

  const ModernNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onTogglePin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categoryNotifier = ref.watch(categoryProvider.notifier);
    
    // Try to find category by ID first, then by name as fallback
    Category category;
    if (note.category != null && note.category!.isNotEmpty) {
      final categoryById = categoryNotifier.getCategoryById(note.category!);
      if (categoryById != null) {
        category = categoryById;
      } else {
        // Fallback: find by name for backwards compatibility
        final categories = ref.watch(categoryProvider);
        final categoryByName = categories.firstWhere(
          (cat) => cat.name == note.category,
          orElse: () => categoryNotifier.getCategoryByIdWithFallback(''),
        );
        category = categoryByName;
      }
    } else {
      category = categoryNotifier.getCategoryByIdWithFallback('');
    }

    final categoryColor = Color(category.color);
    final categoryIcon = IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons');

    // Date status for styling
    Map<String, dynamic> _dateStatus(DateTime date) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final d = DateTime(date.year, date.month, date.day);
      final diff = d.difference(today).inDays;

      if (diff == 0) {
        return {'label': 'Today', 'color': const Color(0xFF2563EB)};
      } else if (diff == 1) {
        return {'label': 'Tomorrow', 'color': const Color(0xFFFB923C)};
      } else if (diff == -1) {
        return {'label': 'Yesterday', 'color': const Color(0xFF6B7280)};
      } else if (diff < -1) {
        return {'label': 'Overdue', 'color': const Color(0xFFEF4444)};
      } else if (diff > 1) {
        return {'label': 'In $diff days', 'color': const Color(0xFF10B981)};
      } else {
        return {'label': '${date.day}/${date.month}/${date.year}', 'color': const Color(0xFF374151)};
      }
    }

    final dateStatus = _dateStatus(note.createdAt);
    final badgeColor = dateStatus['color'] as Color;
    final badgeLabel = dateStatus['label'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (isDark ? AppColors.darkCard : AppColors.white),
            (isDark ? AppColors.darkCard : AppColors.white).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: note.isPinned
              ? categoryColor.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.08)),
          width: note.isPinned ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightMainText).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: categoryColor.withValues(alpha: 0.1),
          highlightColor: categoryColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Category Icon, Title, Pin
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Category Icon
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            categoryColor.withValues(alpha: 0.15),
                            categoryColor.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: categoryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Title and metadata
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                              fontSize: 18,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          // Metadata badges
                          Row(
                            children: [
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: categoryColor.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  category?.name ?? 'Personal',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Date Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: badgeColor.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: badgeColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      badgeLabel,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: badgeColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (note.isLocked) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.flowerYellow.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.flowerYellow.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.lock_rounded,
                                    size: 14,
                                    color: AppColors.flowerYellow,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Pin Button
                    GestureDetector(
                      onTap: onTogglePin,
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: note.isPinned
                              ? categoryColor.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: note.isPinned
                                ? categoryColor.withValues(alpha: 0.3)
                                : Colors.transparent,
                          ),
                        ),
                        child: Icon(
                          note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          size: 20,
                          color: note.isPinned
                              ? categoryColor
                              : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Content in styled container (matching todo description)
                if (note.content.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDark
                              ? AppColors.darkBackground.withValues(alpha: 0.6)
                              : AppColors.lightBackground.withValues(alpha: 0.8),
                          isDark
                              ? AppColors.darkBackground.withValues(alpha: 0.4)
                              : AppColors.lightBackground.withValues(alpha: 0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.6)
                            : AppColors.lightMainText.withValues(alpha: 0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : AppColors.lightMainText).withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      note.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightMainText.withValues(alpha: 0.8),
                        height: 1.6,
                        fontSize: 14,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    const Spacer(),
                    _buildIconButton(
                      icon: Icons.edit_rounded,
                      color: AppColors.primaryAccent,
                      onTap: onEdit,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildIconButton(
                      icon: Icons.delete_rounded,
                      color: AppColors.lightOverdue,
                      onTap: onDelete,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
