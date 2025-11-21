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

    if (dayTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: isDark 
                  ? AppColors.darkMainText.withValues(alpha: 0.3)
                  : AppColors.lightMainText.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks for this day',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark 
                    ? AppColors.darkMainText.withValues(alpha: 0.6)
                    : AppColors.lightMainText.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: dayTodos.length,
        itemBuilder: (context, index) {
          final todo = dayTodos[index];
          return _buildTodoCard(todo, theme, isDark);
        },
      ),
    );
  }

  Widget _buildTodoCard(Todo todo, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) => onTodoToggle(todo),
          activeColor: AppColors.primaryAccent,
        ),
        title: Text(
          todo.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: todo.description.isNotEmpty
            ? Text(
                todo.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark 
                      ? AppColors.darkSecondaryText 
                      : AppColors.lightMainText.withValues(alpha: 0.7),
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit' && onTodoEdit != null) {
              onTodoEdit!(todo);
            } else if (value == 'delete') {
              onTodoDelete(todo);
            }
          },
          itemBuilder: (context) => [
            if (onTodoEdit != null)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: AppColors.primaryAccent),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.lightOverdue),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.lightOverdue)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => onTodoTap(todo),
      ),
    );
  }
}

