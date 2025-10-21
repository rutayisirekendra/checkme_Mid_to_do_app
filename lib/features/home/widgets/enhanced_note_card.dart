import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/database_service.dart';
// duplicate import removed
import '../../../models/note.dart';
import '../../../shared/providers/category_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnhancedNoteCard extends ConsumerWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<Note>? onToggleDone;

  const EnhancedNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onToggleDone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);
    final category = categories.firstWhere(
      (cat) => cat.name == (note.category ?? 'Personal'),
      orElse: () => categories.first,
    );

    final isDone = note.tags.contains('done');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with checkbox, category icon, title, and actions
                Row(
                  children: [
                    // Checkbox mimic for note completion (stored as 'done' tag)
                    GestureDetector(
                      onTap: () async {
                        final updatedTags = List<String>.from(note.tags);
                        if (isDone) {
                          updatedTags.remove('done');
                        } else {
                          updatedTags.add('done');
                        }
                        final updated = note.copyWith(tags: updatedTags);
                        await DatabaseService.saveNote(updated);
                        if (onToggleDone != null) {
                          onToggleDone!(updated);
                        }
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.grassGreen : Colors.transparent,
                          border: Border.all(
                            color: isDone
                                ? AppColors.grassGreen
                                : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.3)),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isDone
                            ? const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 12),
                    // Category Icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category.name).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          category.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isDone
                                  ? (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6))
                                  : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                              fontWeight: FontWeight.bold,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (note.category != null)
                            Text(
                              '${category.icon} ${category.name}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Edit Icon
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkSurface : AppColors.lightBackground),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete Icon
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightOverdue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: AppColors.lightOverdue,
                        ),
                      ),
                    ),
                  ],
                ),

                // Description
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    note.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Metadata Row
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Category (emoji icon + name)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Updated Date
                    _buildMetadataItem(
                      Icons.access_time_outlined,
                      _formatDate(note.updatedAt),
                      AppColors.primaryAccent,
                      theme,
                      isDark,
                    ),
                    
                    if (note.isPinned) ...[
                      const SizedBox(width: 16),
                      _buildMetadataItem(
                        Icons.push_pin_outlined,
                        'Pinned',
                        AppColors.secondaryAccent,
                        theme,
                        isDark,
                      ),
                    ],
                    
                    if (note.attachments.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      _buildMetadataItem(
                        Icons.attach_file_outlined,
                        '${note.attachments.length}',
                        AppColors.grassGreen,
                        theme,
                        isDark,
                      ),
                    ],
                  ],
                ),

                // Attachments Section (if has attachments)
                if (note.attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...note.attachments.map((attachment) => _buildAttachmentItem(attachment, theme, isDark)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataItem(
    IconData icon,
    String text,
    Color color,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentItem(String attachment, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            size: 16,
            color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              attachment,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'work':
        return AppColors.primaryAccent;
      case 'personal':
        return AppColors.grassGreen;
      case 'shopping':
        return AppColors.secondaryAccent;
      case 'health':
        return AppColors.flowerPink;
      case 'quick add':
        return AppColors.flowerYellow;
      default:
        return AppColors.primaryAccent;
    }
  }
}
