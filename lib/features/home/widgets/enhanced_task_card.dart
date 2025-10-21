import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/todo.dart';
import '../../../shared/providers/category_provider.dart';
import '../../../shared/providers/todo_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnhancedTaskCard extends ConsumerWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isExpanded;

  const EnhancedTaskCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);
    final category = categories.firstWhere(
      (cat) => cat.id == todo.category,
      orElse: () => categories.first,
    );

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
                // Top row with checkbox, category icon, title, priority, and actions
                Row(
                  children: [
                    // Checkbox
                    GestureDetector(
                      onTap: onToggle,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: todo.isCompleted 
                              ? AppColors.grassGreen 
                              : Colors.transparent,
                          border: Border.all(
                            color: todo.isCompleted 
                                ? AppColors.grassGreen 
                                : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.3)),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: todo.isCompleted
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
                      child: Text(
                        todo.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: todo.isCompleted 
                              ? (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6))
                              : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                          decoration: todo.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Action Icons (enhanced edit button style from notes)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark 
                                  ? AppColors.darkSurface.withValues(alpha: 0.8)
                                  : AppColors.lightBackground.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark 
                                    ? AppColors.darkBorder
                                    : AppColors.lightMainText.withValues(alpha: 0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.lightOverdue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.lightOverdue.withValues(alpha: 0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.lightOverdue.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: AppColors.lightOverdue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Description (if available)
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    todo.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.7),
                      decoration: todo.isCompleted 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
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
                    
                    // Due Date
                    if (todo.dueDate != null)
                      _buildMetadataItem(
                        Icons.schedule_outlined,
                        _formatDate(todo.dueDate!),
                        AppColors.primaryAccent,
                        theme,
                        isDark,
                      ),
                    
                    const SizedBox(width: 16),
                    
                    // Subtasks Progress
                    if (todo.hasSubtasks)
                      _buildMetadataItem(
                        Icons.checklist_outlined,
                        '${todo.completedSubtasksCount}/${todo.subtasks.length}',
                        AppColors.secondaryAccent,
                        theme,
                        isDark,
                      ),
                    
                    const SizedBox(width: 16),
                    
                    // Attachments
                    if (todo.attachments.isNotEmpty)
                      _buildMetadataItem(
                        Icons.attach_file,
                        '${todo.attachments.length}',
                        AppColors.grassGreen,
                        theme,
                        isDark,
                      ),
                  ],
                ),

                // Priority Tag (moved to bottom right)
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(todo.priority).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _getPriorityColor(todo.priority).withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _getPriorityText(todo.priority).toLowerCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPriorityColor(todo.priority),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                // Subtasks Section (if has subtasks)
                if (todo.hasSubtasks) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Subtasks',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...todo.subtasks.map((subtask) => _buildSubtaskItem(ref, todo.id, subtask, theme, isDark)),
                ],

                // Attachments Section (if has attachments)
                if (todo.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Attachments',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...todo.attachments.map((attachment) => _buildAttachmentItem(attachment, theme, isDark)),
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

  Widget _buildSubtaskItem(WidgetRef ref, String parentId, Todo subtask, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Tap to toggle subtask completion
          GestureDetector(
            onTap: () async {
              final updated = subtask.copyWith(isCompleted: !subtask.isCompleted);
              await ref.read(todoListProvider.notifier).updateSubtask(parentId, updated);
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: subtask.isCompleted 
                    ? AppColors.grassGreen 
                    : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted 
                      ? AppColors.grassGreen 
                      : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.3)),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: subtask.isCompleted
                  ? const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 12,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subtask.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: subtask.isCompleted 
                    ? (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6))
                    : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                decoration: subtask.isCompleted 
                    ? TextDecoration.lineThrough 
                    : null,
              ),
            ),
          ),
        ],
      ),
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
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 0) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return 'Overdue';
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

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return const Color(0xFF16A34A); // green
      case Priority.medium:
        return const Color(0xFFF59E0B); // amber
      case Priority.high:
        return const Color(0xFFEF4444); // red
      case Priority.urgent:
        return const Color(0xFF7C3AED); // purple
    }
  }
}
