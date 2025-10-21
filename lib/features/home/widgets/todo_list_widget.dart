import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/todo.dart';
import '../../../shared/widgets/glassmorphism_card.dart';
import 'task_card.dart';

class TodoListWidget extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo) onTodoTap;
  final Function(Todo) onTodoToggle;
  final Function(Todo) onTodoDelete;

  const TodoListWidget({
    super.key,
    required this.todos,
    required this.onTodoTap,
    required this.onTodoToggle,
    required this.onTodoDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark; // future use

    if (todos.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Your Todos',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.lightMainText,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Todo List
        AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: TaskCard(
                      todo: todo,
                      onTap: () => onTodoTap(todo),
                      onToggle: () => onTodoToggle(todo),
                      onEdit: () => onTodoTap(todo),
                      onDelete: () => onTodoDelete(todo),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Old method removed - using TaskCard now
  Widget _buildOldTodoItem(BuildContext context, ThemeData theme, Todo todo, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(todo.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.lightOverdue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.delete,
            color: AppColors.white,
            size: 24,
          ),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmation(context, todo);
        },
        onDismissed: (direction) {
          onTodoDelete(todo);
        },
        child: GlassmorphismCard(
          child: InkWell(
            onTap: () => onTodoTap(todo),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () => onTodoToggle(todo),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: todo.isCompleted 
                              ? AppColors.grassGreen 
                              : Colors.transparent,
                        border: Border.all(
                          color: todo.isCompleted 
                              ? AppColors.grassGreen 
                              : AppColors.lightMainText.withValues(alpha: 0.3),
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

                  const SizedBox(width: 16),

                  // Todo Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          todo.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: todo.isCompleted 
                                ? AppColors.lightMainText.withValues(alpha: 0.6)
                                : AppColors.lightMainText,
                            decoration: todo.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (todo.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.lightMainText.withValues(alpha: 0.7),
                              decoration: todo.isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Meta Information
                        Row(
                          children: [
                            // Category
                            if (todo.category.isNotEmpty)
                              _buildMetaChip(
                                context,
                                todo.category,
                                _getCategoryColor(todo.category),
                              ),

                            if (todo.category.isNotEmpty) const SizedBox(width: 8),

                            // Priority
                            _buildMetaChip(
                              context,
                              _getPriorityText(todo.priority),
                              _getPriorityColor(todo.priority),
                            ),

                            const Spacer(),

                            // Due Date
                            if (todo.dueDate != null)
                              _buildDueDateChip(context, todo),
                          ],
                        ),

                        // Subtasks Progress
                        if (todo.hasSubtasks) ...[
                          const SizedBox(height: 8),
                          _buildSubtasksProgress(context, todo),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip(BuildContext context, String text, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context, Todo todo) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dueDate = todo.dueDate!;
    final isOverdue = dueDate.isBefore(now) && !todo.isCompleted;
    final isToday = dueDate.year == now.year && 
                   dueDate.month == now.month && 
                   dueDate.day == now.day;

    String dateText;
    Color chipColor;
    
    if (isToday) {
      dateText = 'Today';
      chipColor = AppColors.primaryAccent;
    } else if (isOverdue) {
      dateText = 'Overdue';
      chipColor = AppColors.lightOverdue;
    } else {
      final difference = dueDate.difference(now).inDays;
      if (difference == 1) {
        dateText = 'Tomorrow';
        chipColor = AppColors.secondaryAccent;
      } else {
        dateText = '${difference}d left';
        chipColor = AppColors.primaryAccent;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            dateText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksProgress(BuildContext context, Todo todo) {
    final theme = Theme.of(context);
    final completedCount = todo.completedSubtasksCount;
    final totalCount = todo.subtasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.lightMainText.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$completedCount/$totalCount',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.lightMainText.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.primaryAccent.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No todos yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.lightMainText.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first todo to get started!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.lightMainText.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Todo todo) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
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
        return AppColors.grassGreen;
      case Priority.medium:
        return AppColors.primaryAccent;
      case Priority.high:
        return AppColors.secondaryAccent;
      case Priority.urgent:
        return AppColors.lightOverdue;
    }
  }
}
