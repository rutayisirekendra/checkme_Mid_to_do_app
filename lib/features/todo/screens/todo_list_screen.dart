import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/todo_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import 'add_todo_screen.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'My Todos',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AddTodoScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.add_rounded,
              color: AppColors.secondaryAccent,
            ),
          ),
        ],
      ),
      body: todos.isEmpty
          ? _buildEmptyState(theme, isDark, context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return _buildTodoCard(todo, theme, isDark, ref, context);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTodoScreen(),
            ),
          );
        },
        backgroundColor: AppColors.secondaryAccent,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Todo'),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryAccent.withValues(alpha: 0.1),
                    AppColors.primaryAccent.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 64,
                color: AppColors.secondaryAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No todos yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first todo',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Create Todo',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTodoScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(todo, ThemeData theme, bool isDark, WidgetRef ref, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [
                  AppColors.darkCard,
                  AppColors.darkSurface,
                ]
              : [
                  AppColors.white,
                  AppColors.lightBackground.withValues(alpha: 0.3),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  todo.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              Checkbox(
                value: todo.isCompleted,
                onChanged: (value) {
                  ref.read(todoListProvider.notifier).toggleTodo(todo.id);
                },
                activeColor: AppColors.grassGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          if (todo.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              todo.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(todo.priority).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPriorityColor(todo.priority).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getPriorityText(todo.priority),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getPriorityColor(todo.priority),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTodoScreen(todoToEdit: todo),
                    ),
                  );
                },
                icon: Icon(
                  Icons.edit_rounded,
                  color: AppColors.secondaryAccent,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(todoListProvider.notifier).deleteTodo(todo.id);
                },
                icon: Icon(
                  Icons.delete_rounded,
                  color: AppColors.lightOverdue,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(priority) {
    switch (priority.toString()) {
      case 'Priority.low':
        return AppColors.grassGreen;
      case 'Priority.medium':
        return AppColors.primaryAccent;
      case 'Priority.high':
        return AppColors.secondaryAccent;
      case 'Priority.urgent':
        return AppColors.lightOverdue;
      default:
        return AppColors.primaryAccent;
    }
  }

  String _getPriorityText(priority) {
    switch (priority.toString()) {
      case 'Priority.low':
        return 'Low';
      case 'Priority.medium':
        return 'Medium';
      case 'Priority.high':
        return 'High';
      case 'Priority.urgent':
        return 'Urgent';
      default:
        return 'Medium';
    }
  }
}
