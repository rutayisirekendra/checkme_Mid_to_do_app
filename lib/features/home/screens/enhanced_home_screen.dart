import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/todo_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/category_provider.dart';
import '../../../models/todo.dart';
import '../../../models/user.dart' as models;
import '../../todo/screens/add_todo_screen.dart';
import '../../todo/screens/edit_todo_screen.dart';
import '../widgets/enhanced_home_app_bar.dart';
import '../widgets/enhanced_growing_garden.dart';
import '../widgets/enhanced_daily_inspiration.dart';
import '../widgets/enhanced_task_card.dart';
import '../../notifications/screens/notifications_screen.dart';

class EnhancedHomeScreen extends ConsumerStatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  ConsumerState<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends ConsumerState<EnhancedHomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Refresh todos when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoListProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserAsync = ref.watch(currentUserProvider);
    final todoStats = ref.watch(todoStatsProvider);
    final filteredTodos = ref.watch(filteredTodoListProvider);

    return currentUserAsync.when(
      data: (currentUser) => _buildHomeContent(
        context,
        theme,
        currentUser,
        todoStats,
        filteredTodos,
      ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildHomeContent(
      BuildContext context,
      ThemeData theme,
      models.User? currentUser,
      TodoStats todoStats,
      List<Todo> filteredTodos,
      ) {
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced App Bar
              EnhancedHomeAppBar(
                userName: currentUser?.name ?? 'User',
                currentStreak: currentUser?.currentStreak ?? 0,
                onProfileTap: () {},
                onNotificationTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),

              // Enhanced Growing Garden
              EnhancedGrowingGarden(
                completedTasks: todoStats.completed,
                totalTasks: todoStats.total,
              ),

              const SizedBox(height: 24),

              // Enhanced Daily Inspiration
              const EnhancedDailyInspiration(),

              const SizedBox(height: 24),

              // Filter Section
              _buildFilterSection(theme),

              const SizedBox(height: 20),

              // Todo List Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Row(
                      children: [
                        Text(
                          'Your Tasks',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark
                                ? AppColors.darkMainText
                                : AppColors.lightMainText,
                          ),
                        ),
                        const Spacer(),
                        if (filteredTodos.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${filteredTodos.length} tasks',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Todo List
                    if (filteredTodos.isEmpty)
                      _buildEmptyState(theme)
                    else
                      ...filteredTodos.map((todo) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EnhancedTaskCard(
                          todo: todo,
                          onTap: () async {
                            // Await the edit screen and refresh when returning so id and edits persist in the list
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddTodoScreen(todoToEdit: todo),
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
                      )).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      // No FAB on home per request
    );
  }

  Widget _buildFilterSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final currentSort = ref.watch(sortByProvider);
    final categories = ref.watch(categoryProvider);
    final selectedCategoryId = ref.watch(selectedCategoryFilterProvider);
    final selectedPriority = ref.watch(selectedPriorityFilterProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            AppColors.lightBackground.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightMainText.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: AppColors.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Category Filter
          Text(
            'Categories',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  theme: theme,
                  label: 'All',
                  selected: selectedCategoryId == 'all' || selectedCategoryId == null,
                  onTap: () => ref.read(selectedCategoryFilterProvider.notifier).state = 'all',
                ),
                ...categories.map((cat) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildCategoryFilterChip(
                    theme: theme,
                    category: cat,
                    selected: selectedCategoryId == cat.id,
                    onTap: () => ref.read(selectedCategoryFilterProvider.notifier).state = cat.id,
                  ),
                )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Priority Filter
          Text(
            'Priority',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: Priority.values.map((priority) {
              final isSelected = selectedPriority == priority;
              return _buildPriorityChip(
                theme: theme,
                priority: priority,
                selected: isSelected,
                onTap: () {
                  final notifier = ref.read(selectedPriorityFilterProvider.notifier);
                  notifier.state = isSelected ? null : priority;
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Sort By
          Text(
            'Sort by',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TodoSortBy.values.map((sortBy) {
                final isSelected = currentSort == sortBy;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildFilterChip(
                    theme: theme,
                    label: _getSortLabel(sortBy),
                    selected: isSelected,
                    onTap: () => ref.read(sortByProvider.notifier).state = sortBy,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeData theme,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondaryAccent.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.secondaryAccent
                : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.2)),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: selected
                ? AppColors.secondaryAccent
                : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip({
    required ThemeData theme,
    required category,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final categoryIcon = IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons');
    final categoryColor = Color(category.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? categoryColor.withValues(alpha: 0.15)
              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? categoryColor
                : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.2)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryIcon,
              size: 16,
              color: selected
                  ? categoryColor
                  : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 6),
            Text(
              category.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? categoryColor
                    : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip({
    required ThemeData theme,
    required Priority priority,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final priorityData = _getPriorityData(priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? priorityData.color.withValues(alpha: 0.2)
              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? priorityData.color
                : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              priorityData.icon,
              size: 14,
              color: selected
                  ? priorityData.color
                  : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
            ),
            const SizedBox(width: 4),
            Text(
              priorityData.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected
                    ? priorityData.color
                    : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first task to get started!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.darkSecondaryText
                  : AppColors.lightMainText.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSortLabel(TodoSortBy sortBy) {
    switch (sortBy) {
      case TodoSortBy.dueDate:
        return 'Due Date';
      case TodoSortBy.priority:
        return 'Priority';
      case TodoSortBy.createdDate:
        return 'Created';
      case TodoSortBy.title:
        return 'Title';
    }
  }

  ({String label, Color color, IconData icon}) _getPriorityData(Priority priority) {
    switch (priority) {
      case Priority.low:
        return (label: 'Low', color: AppColors.grassGreen, icon: Icons.keyboard_arrow_down);
      case Priority.medium:
        return (label: 'Medium', color: AppColors.primaryAccent, icon: Icons.remove);
      case Priority.high:
        return (label: 'High', color: AppColors.secondaryAccent, icon: Icons.keyboard_arrow_up);
      case Priority.urgent:
        return (label: 'Urgent', color: AppColors.lightOverdue, icon: Icons.priority_high);
    }
  }
}



