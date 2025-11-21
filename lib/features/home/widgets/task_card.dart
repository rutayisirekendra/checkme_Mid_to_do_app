// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../models/todo.dart';
// import '../../../shared/providers/category_provider.dart';
//
// class TaskCard extends ConsumerWidget {
//   final Todo todo;
//   final VoidCallback onTap;
//   final VoidCallback onToggle;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//
//   const TaskCard({
//     super.key,
//     required this.todo,
//     required this.onTap,
//     required this.onToggle,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final category = ref.watch(categoryProvider).firstWhere(
//       (cat) => cat.id == todo.category,
//       orElse: () => ref.watch(categoryProvider).first,
//     );
//
//     final categoryIcon = IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons');
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surface,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Checkbox
//                 GestureDetector(
//                   onTap: onToggle,
//                   child: Container(
//                     width: 24,
//                     height: 24,
//                     decoration: BoxDecoration(
//                       color: todo.isCompleted
//                           ? AppColors.primaryAccent
//                           : Colors.transparent,
//                       borderRadius: BorderRadius.circular(6),
//                       border: Border.all(
//                         color: todo.isCompleted
//                             ? AppColors.primaryAccent
//                             : theme.colorScheme.outline,
//                         width: 2,
//                       ),
//                     ),
//                     child: todo.isCompleted
//                         ? const Icon(
//                             Icons.check,
//                             color: Colors.white,
//                             size: 16,
//                           )
//                         : null,
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 // Category Icon
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: Color(category.color).withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     categoryIcon,
//                     color: Color(category.color),
//                     size: 18,
//                   ),
//                 ),
//
//                 const SizedBox(width: 12),
//
//                 // Content
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title and Priority
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               todo.title,
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 decoration: todo.isCompleted
//                                     ? TextDecoration.lineThrough
//                                     : null,
//                                 color: todo.isCompleted
//                                     ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
//                                     : theme.colorScheme.onSurface,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           if (todo.priority != Priority.medium)
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: _getPriorityColor(todo.priority),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 todo.priority.name.toUpperCase(),
//                                 style: theme.textTheme.bodySmall?.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//
//                       if (todo.description.isNotEmpty) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           todo.description,
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//
//                       const SizedBox(height: 8),
//
//                       // Details Row
//                       Row(
//                         children: [
//                           // Category
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Color(category.color).withValues(alpha: 0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   categoryIcon,
//                                   color: Color(category.color),
//                                   size: 12,
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   category.name,
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     color: Color(category.color),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           const SizedBox(width: 8),
//
//                           // Due Date
//                           if (todo.dueDate != null) ...[
//                             Icon(
//                               Icons.schedule,
//                               size: 12,
//                               color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               _formatDate(todo.dueDate!),
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                           ],
//
//                           // Subtasks
//                           if (todo.subtasks.isNotEmpty) ...[
//                             Icon(
//                               Icons.checklist,
//                               size: 12,
//                               color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${todo.subtasks.where((s) => s.isCompleted).length}/${todo.subtasks.length}',
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                           ],
//
//                           // Attachments
//                           if (todo.attachments.isNotEmpty) ...[
//                             Icon(
//                               Icons.attach_file,
//                               size: 12,
//                               color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '${todo.attachments.length}',
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(width: 8),
//
//                 // Actions
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       onPressed: onEdit,
//                       icon: Icon(
//                         Icons.edit,
//                         size: 18,
//                         color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: onDelete,
//                       icon: Icon(
//                         Icons.delete,
//                         size: 18,
//                         color: AppColors.lightOverdue,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Color _getPriorityColor(Priority priority) {
//     switch (priority) {
//       case Priority.high:
//         return AppColors.lightOverdue;
//       case Priority.medium:
//         return Colors.orange;
//       case Priority.low:
//         return Colors.green;
//       case Priority.urgent:
//         return AppColors.darkOverdue;
//     }
//   }
//
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = date.difference(now).inDays;
//
//     if (difference == 0) {
//       return 'Today';
//     } else if (difference == 1) {
//       return 'Tomorrow';
//     } else if (difference == -1) {
//       return 'Yesterday';
//     } else if (difference < 0) {
//       return 'Overdue';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/todo.dart';
import '../../../shared/providers/category_provider.dart';

class TaskCard extends ConsumerWidget {
  final Todo todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final category = ref.watch(categoryProvider).firstWhere(
          (cat) => cat.id == todo.category,
      orElse: () => ref.watch(categoryProvider).first,
    );

    final categoryIcon = IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
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
            child: Row(
              children: [
                // LEFT SECTION - Checkbox and Category Icon
                _buildLeftSection(theme, category, categoryIcon),

                const SizedBox(width: 12),

                // CENTER SECTION - Content and Details
                Expanded(
                  child: _buildCenterSection(theme, category, categoryIcon),
                ),

                const SizedBox(width: 8),

                // RIGHT SECTION - Action Buttons
                _buildRightSection(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // LEFT SECTION - Checkbox and Category Icon
  Widget _buildLeftSection(ThemeData theme, dynamic category, IconData categoryIcon) {
    return Column(
      children: [
        // Checkbox
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: todo.isCompleted
                  ? AppColors.primaryAccent
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: todo.isCompleted
                    ? AppColors.primaryAccent
                    : theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: todo.isCompleted
                ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            )
                : null,
          ),
        ),

        const SizedBox(height: 12),

        // Category Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color(category.color).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            categoryIcon,
            color: Color(category.color),
            size: 18,
          ),
        ),
      ],
    );
  }

  // CENTER SECTION - Content and Details
  Widget _buildCenterSection(ThemeData theme, dynamic category, IconData categoryIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER ROW - Title and Priority
        _buildHeaderRow(theme),

        // DESCRIPTION
        if (todo.description.isNotEmpty)
          _buildDescription(theme),

        const SizedBox(height: 8),

        // METADATA ROW - Category, Due Date, Subtasks, Attachments
        _buildMetadataRow(theme, category, categoryIcon),
      ],
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            todo.title,
            style: theme.textTheme.titleMedium?.copyWith(
              decoration: todo.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
              color: todo.isCompleted
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (todo.priority != Priority.medium)
          _buildPriorityBadge(theme),
      ],
    );
  }

  Widget _buildPriorityBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getPriorityColor(todo.priority),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        todo.priority.name.toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          todo.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMetadataRow(ThemeData theme, dynamic category, IconData categoryIcon) {
    return Row(
      children: [
        // Category Chip
        _buildCategoryChip(theme, category, categoryIcon),

        const SizedBox(width: 8),

        // Due Date
        if (todo.dueDate != null)
          _buildDueDateChip(theme),

        // Subtasks
        if (todo.subtasks.isNotEmpty)
          _buildSubtasksChip(theme),

        // Attachments
        if (todo.attachments.isNotEmpty)
          _buildAttachmentsChip(theme),
      ],
    );
  }

  Widget _buildCategoryChip(ThemeData theme, dynamic category, IconData categoryIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(category.color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            categoryIcon,
            color: Color(category.color),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Color(category.color),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateChip(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule,
          size: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(todo.dueDate!),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSubtasksChip(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.checklist,
          size: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          '${todo.subtasks.where((s) => s.isCompleted).length}/${todo.subtasks.length}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAttachmentsChip(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.attach_file,
          size: 12,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          '${todo.attachments.length}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  // RIGHT SECTION - Action Buttons
  Widget _buildRightSection(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: Icon(
            Icons.edit,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        IconButton(
          onPressed: onDelete,
          icon: Icon(
            Icons.delete,
            size: 18,
            color: AppColors.lightOverdue,
          ),
        ),
      ],
    );
  }

  // HELPER METHODS
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return AppColors.lightOverdue;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
      case Priority.urgent:
        return AppColors.darkOverdue;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference < 0) {
      return 'Overdue';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}