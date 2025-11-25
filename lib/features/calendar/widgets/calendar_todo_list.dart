import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/todo.dart';

class CalendarTodoList extends StatelessWidget {
  final List<Todo> todos;
  final DateTime selectedDate;
  final Function(Todo) onTodoTap;
  final Function(Todo) onTodoToggle;
  final Function(Todo) onTodoDelete;
  final Function(Todo)? onTodoEdit;

  const CalendarTodoList({
    super.key,
    required this.todos,
    required this.selectedDate,
    required this.onTodoTap,
    required this.onTodoToggle,
    required this.onTodoDelete,
    this.onTodoEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final dayTodos = todos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == selectedDate.year &&
             todo.dueDate!.month == selectedDate.month &&
             todo.dueDate!.day == selectedDate.day;
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      child: Column(
        children: [
          // Header for selected day - made more compact
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryAccent.withValues(alpha: 0.1),
                  AppColors.secondaryAccent.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryAccent.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.today_rounded,
                  color: AppColors.primaryAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${dayTodos.length} task${dayTodos.length != 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Todo list - using Expanded to take remaining space properly
          Expanded(
            child: dayTodos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: isDark 
                              ? AppColors.darkMainText.withValues(alpha: 0.3)
                              : AppColors.lightMainText.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No tasks for this day',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark 
                                ? AppColors.darkMainText.withValues(alpha: 0.6)
                                : AppColors.lightMainText.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tasks with due dates will appear here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark 
                                ? AppColors.darkMainText.withValues(alpha: 0.4)
                                : AppColors.lightMainText.withValues(alpha: 0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                    itemCount: dayTodos.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final todo = dayTodos[index];
                      return _buildTodoCard(todo, theme, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(Todo todo, ThemeData theme, bool isDark) {
    Color priorityColor = _getPriorityColor(todo.priority);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: priorityColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Priority indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            
            // Checkbox
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isCompleted ? AppColors.grassGreen : priorityColor.withValues(alpha: 0.5),
                  width: 2,
                ),
                color: todo.isCompleted ? AppColors.grassGreen : Colors.transparent,
              ),
              child: Checkbox(
                value: todo.isCompleted,
                onChanged: (value) => onTodoToggle(todo),
                activeColor: Colors.transparent,
                checkColor: AppColors.white,
                side: BorderSide.none,
                shape: const CircleBorder(),
              ),
            ),
            const SizedBox(width: 12),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (todo.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      todo.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? AppColors.darkSecondaryText 
                            : AppColors.lightMainText.withValues(alpha: 0.7),
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getPriorityText(todo.priority),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (todo.subtasks.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.list_alt_rounded,
                                size: 12,
                                color: AppColors.primaryAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${todo.subtasks.where((s) => s.isCompleted).length}/${todo.subtasks.length}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                if (onTodoEdit != null)
                  IconButton(
                    onPressed: () => onTodoEdit?.call(todo),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.primaryAccent,
                    ),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                IconButton(
                  onPressed: () => onTodoDelete(todo),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.lightOverdue,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}

