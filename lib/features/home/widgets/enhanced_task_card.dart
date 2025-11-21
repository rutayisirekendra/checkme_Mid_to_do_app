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
    final category = categories.cast<dynamic>().firstWhere(
          (cat) => cat.id == todo.category,
      orElse: () => null,
    );

    final categoryColor = category != null ? Color(category.color) : AppColors.primaryAccent;
    final categoryIcon = category != null
        ? IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons')
        : Icons.category;

    // compute due status (label + color) using date-only comparison
    Map<String, dynamic>? dueStatus;
    if (todo.dueDate != null) {
      dueStatus = _dateStatus(todo.dueDate!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkCard.withValues(alpha: 0.8)]
              : [AppColors.white, AppColors.white.withValues(alpha: 0.95)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: todo.isCompleted
              ? AppColors.grassGreen.withValues(alpha: 0.3)
              : categoryColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightMainText).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: categoryColor.withValues(alpha: 0.08),
          highlightColor: categoryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Checkbox, Icon, Title, Priority and Actions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Modern Checkbox
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: todo.isCompleted
                              ? LinearGradient(
                            colors: [AppColors.grassGreen, AppColors.grassGreen.withValues(alpha: 0.8)],
                          )
                              : null,
                          color: todo.isCompleted ? null : Colors.transparent,
                          border: Border.all(
                            color: todo.isCompleted
                                ? Colors.transparent
                                : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.25)),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(7),
                          boxShadow: todo.isCompleted
                              ? [
                            BoxShadow(
                              color: AppColors.grassGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                              : null,
                        ),
                        child: todo.isCompleted
                            ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 16,
                        )
                            : null,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Category Icon
                    Container(
                      width: 44,
                      height: 44,
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
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: categoryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        categoryIcon,
                        color: categoryColor,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title, Category and Priority
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            todo.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: todo.isCompleted
                                  ? (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.5))
                                  : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                              decorationThickness: 2,
                              fontWeight: FontWeight.w600,
                              fontSize: 15.5,
                              height: 1.3,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 7),
                          // Category and Priority Row (category shown here once)
                          Row(
                            children: [
                              // Category Name (keeps the category displayed under the title)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  category?.name ?? 'General',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Priority Dot and Text
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(todo.priority).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: _getPriorityColor(todo.priority),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _getPriorityText(todo.priority),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: _getPriorityColor(todo.priority),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Action Buttons (placed inline on the same horizontal line)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Icons.edit_rounded,
                          color: categoryColor,
                          onTap: onEdit,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_rounded,
                          color: AppColors.lightOverdue,
                          onTap: onDelete,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),

                // Description
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground.withValues(alpha: 0.5)
                          : AppColors.lightBackground.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.5)
                            : AppColors.lightMainText.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      todo.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightMainText.withValues(alpha: 0.7),
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        height: 1.5,
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // Metadata Row with Icons
                // NOTE: due date moved here (clock icon + status color) so it sits below the title like notes
                if (todo.dueDate != null || todo.hasSubtasks || todo.attachments.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Due Date (clock icon + colored status)
                      if (todo.dueDate != null && dueStatus != null)
                        _buildMetadataChip(
                          icon: Icons.access_time_rounded,
                          label: dueStatus['label'] as String,
                          color: dueStatus['color'] as Color,
                          theme: theme,
                          isDark: isDark,
                        ),

                      // Subtasks Progress
                      if (todo.hasSubtasks)
                        _buildMetadataChip(
                          icon: Icons.checklist_rounded,
                          label: '${todo.completedSubtasksCount}/${todo.subtasks.length}',
                          color: AppColors.secondaryAccent,
                          theme: theme,
                          isDark: isDark,
                        ),

                      // Attachments
                      if (todo.attachments.isNotEmpty)
                        _buildMetadataChip(
                          icon: Icons.attach_file_rounded,
                          label: '${todo.attachments.length}',
                          color: AppColors.grassGreen,
                          theme: theme,
                          isDark: isDark,
                        ),
                    ],
                  ),
                ],

                // Subtasks Section
                if (todo.hasSubtasks) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground.withValues(alpha: 0.4)
                          : categoryColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              size: 18,
                              color: categoryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Subtasks',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            // Progress indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${todo.completedSubtasksCount}/${todo.subtasks.length}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...todo.subtasks.map((subtask) => _buildSubtaskItem(
                          ref,
                          todo.id,
                          subtask,
                          categoryColor,
                          theme,
                          isDark,
                        )),
                      ],
                    ),
                  ),
                ],

                // Attachments Section
                if (todo.attachments.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground.withValues(alpha: 0.4)
                          : AppColors.grassGreen.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grassGreen.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 18,
                              color: AppColors.grassGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Attachments',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.grassGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${todo.attachments.length}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.grassGreen,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...todo.attachments.map((attachment) => _buildAttachmentItem(
                          attachment,
                          theme,
                          isDark,
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withValues(alpha: 0.18),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(
      WidgetRef ref,
      String parentId,
      Todo subtask,
      Color categoryColor,
      ThemeData theme,
      bool isDark,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final updated = subtask.copyWith(isCompleted: !subtask.isCompleted);
              await ref.read(todoListProvider.notifier).updateSubtask(parentId, updated);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                gradient: subtask.isCompleted
                    ? LinearGradient(
                  colors: [categoryColor, categoryColor.withValues(alpha: 0.8)],
                )
                    : null,
                color: subtask.isCompleted ? null : Colors.transparent,
                border: Border.all(
                  color: subtask.isCompleted
                      ? Colors.transparent
                      : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.25)),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: subtask.isCompleted
                    ? [
                  BoxShadow(
                    color: categoryColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              child: subtask.isCompleted
                  ? const Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: 14,
              )
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              subtask.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: subtask.isCompleted
                    ? (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.5))
                    : (isDark ? AppColors.darkMainText : AppColors.lightMainText),
                decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                decorationThickness: 1.5,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(String attachment, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withValues(alpha: 0.5)
            : AppColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withValues(alpha: 0.5)
              : AppColors.lightMainText.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.grassGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.insert_drive_file_rounded,
              size: 16,
              color: AppColors.grassGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              attachment,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

  // Date status helper returns a map with label and a distinct color for each status.
  Map<String, dynamic> _dateStatus(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = d.difference(today).inDays; // positive => future

    // Distinct colors for statuses (feel free to replace with AppColors constants)
    const Color colorToday = Color(0xFF2563EB); // blue
    const Color colorTomorrow = Color(0xFFFB923C); // orange
    const Color colorYesterday = Color(0xFF6B7280); // gray
    const Color colorOverdue = Color(0xFFEF4444); // red
    const Color colorFuture = Color(0xFF10B981); // green
    const Color colorDefault = Color(0xFF374151); // slate

    if (diff == 0) {
      return {'label': 'Today', 'color': colorToday};
    } else if (diff == 1) {
      return {'label': 'Tomorrow', 'color': colorTomorrow};
    } else if (diff == -1) {
      return {'label': 'Yesterday', 'color': colorYesterday};
    } else if (diff < -1) {
      return {'label': 'Overdue', 'color': colorOverdue};
    } else if (diff > 1) {
      return {'label': 'In $diff days', 'color': colorFuture};
    } else {
      return {'label': '${date.day}/${date.month}', 'color': colorDefault};
    }
  }

  // Use date-only comparison to format legacy/other date strings where needed.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) {
      return 'Today';
    } else if (diff == 1) {
      return 'Tomorrow';
    } else if (diff == -1) {
      return 'Yesterday';
    } else if (diff < -1) {
      return 'Overdue';
    } else if (diff > 1) {
      return '${date.day}/${date.month}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'LOW';
      case Priority.medium:
        return 'MEDIUM';
      case Priority.high:
        return 'HIGH';
      case Priority.urgent:
        return 'URGENT';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return const Color(0xFF10B981); // emerald
      case Priority.medium:
        return const Color(0xFFF59E0B); // amber
      case Priority.high:
        return const Color(0xFFEF4444); // red
      case Priority.urgent:
        return const Color(0xFF8B5CF6); // violet
    }
  }
}