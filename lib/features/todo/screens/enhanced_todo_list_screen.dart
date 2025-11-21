import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/todo_provider.dart';
import 'add_todo_screen.dart';
import 'edit_todo_screen.dart';
import '../../../shared/widgets/enhanced_screen_header.dart';
import '../../home/widgets/enhanced_task_card.dart';

class EnhancedTodoListScreen extends ConsumerStatefulWidget {
  const EnhancedTodoListScreen({super.key});

  @override
  ConsumerState<EnhancedTodoListScreen> createState() => _EnhancedTodoListScreenState();
}

class _EnhancedTodoListScreenState extends ConsumerState<EnhancedTodoListScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final todos = ref.watch(filteredTodoListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header + Search
            EnhancedScreenHeader(
              title: 'My Tasks',
              subtitle: '${todos.length} tasks • ${todos.where((t) => t.isCompleted).length} completed',
              icon: Icons.task_alt_rounded,
              onActionTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTodoScreen(),
                  ),
                );
                // Refresh after returning
                if (mounted) {
                  await ref.read(todoListProvider.notifier).refresh();
                }
              },
              actionText: 'Add Task',
              actionIcon: Icons.add_rounded,
            ),

            const SizedBox(height: 20),

            // Search for tasks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).updateQuery(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search your todos...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightMainText.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkCard
                      : const Color(0xFFF2F2F5),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkAccent.withValues(alpha: 0.2)
                          : const Color(0xFFFFE5D6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.primaryAccent,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.primaryAccent,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tasks List
            Expanded(
              child: todos.isEmpty
                  ? _buildEmptyState(theme, isDark)
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: EnhancedTaskCard(
                      todo: todo,
                      onTap: () async {
                        // Open edit screen for this todo and refresh when returning
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditTodoScreen(todo: todo),
                          ),
                        );
                        if (mounted) {
                          await ref.read(todoListProvider.notifier).refresh();
                        }
                      },
                      onToggle: () {
                        ref.read(todoListProvider.notifier).toggleTodo(todo.id);
                      },
                      onEdit: () async {
                        // Explicit edit action opens the dedicated Edit screen
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditTodoScreen(todo: todo),
                          ),
                        );
                        if (mounted) {
                          await ref.read(todoListProvider.notifier).refresh();
                        }
                      },
                      onDelete: () {
                        ref.read(todoListProvider.notifier).deleteTodo(todo.id);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
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
              'No tasks yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first task',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTodoScreen(),
                  ),
                );
                if (mounted) {
                  await ref.read(todoListProvider.notifier).refresh();
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryAccent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}