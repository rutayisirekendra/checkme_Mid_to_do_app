import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/todo_provider.dart';
// import '../../../shared/providers/auth_provider.dart';
import '../../../models/todo.dart';
import '../../todo/screens/add_todo_screen.dart';
import '../../home/widgets/enhanced_task_card.dart';

class EnhancedCalendarScreen extends ConsumerStatefulWidget {
  const EnhancedCalendarScreen({super.key});

  @override
  ConsumerState<EnhancedCalendarScreen> createState() => _EnhancedCalendarScreenState();
}

class _EnhancedCalendarScreenState extends ConsumerState<EnhancedCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final currentUser = ref.watch(currentUserProvider); // unused
    final allTodos = ref.watch(todoListProvider);
    
    // Filter todos for selected date
    final dayTodos = allTodos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == _selectedDate.year &&
             todo.dueDate!.month == _selectedDate.month &&
             todo.dueDate!.day == _selectedDate.day;
    }).toList();

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark 
          ? AppColors.darkBackground 
          : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.brightness == Brightness.dark 
                      ? [
                          AppColors.darkCard,
                          AppColors.darkSurface,
                        ]
                      : [
                          AppColors.white,
                          AppColors.lightBackground.withValues(alpha: 0.8),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (theme.brightness == Brightness.dark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryAccent.withValues(alpha: 0.2),
                          AppColors.secondaryAccent.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primaryAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calendar',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark 
                                ? AppColors.darkMainText 
                                : AppColors.lightMainText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatSelectedDate(_selectedDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.brightness == Brightness.dark 
                                ? AppColors.darkSecondaryText 
                                : AppColors.lightMainText.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Today button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Today',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Calendar Widget
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? AppColors.darkCard : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.brightness == Brightness.dark 
                      ? AppColors.darkBorder
                      : AppColors.lightMainText.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (theme.brightness == Brightness.dark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Calendar Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chevron_left,
                              color: AppColors.primaryAccent,
                              size: 20,
                            ),
                          ),
                        ),
                        Text(
                          _formatMonthYear(_selectedDate),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark 
                                ? AppColors.darkMainText 
                                : AppColors.lightMainText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: AppColors.primaryAccent,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calendar Grid
                  _buildCalendarGrid(theme, allTodos),
                ],
              ),
            ),

            // Tasks for selected date
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tasks Header
                    Row(
                      children: [
                        Text(
                          'Tasks for ${_formatSelectedDate(_selectedDate)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.brightness == Brightness.dark 
                                ? AppColors.darkMainText 
                                : AppColors.lightMainText,
                          ),
                        ),
                        const Spacer(),
                        if (dayTodos.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${dayTodos.length} tasks',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Tasks List
                    Expanded(
                      child: dayTodos.isEmpty
                          ? _buildEmptyState(theme)
                          : ListView.builder(
                              itemCount: dayTodos.length,
                              itemBuilder: (context, index) {
                                final todo = dayTodos[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: EnhancedTaskCard(
                                    todo: todo,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AddTodoScreen(todoToEdit: todo),
                                        ),
                                      );
                                    },
                                    onToggle: () {
                                      ref.read(todoListProvider.notifier).toggleTodo(todo.id);
                                    },
                                    onEdit: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AddTodoScreen(todoToEdit: todo),
                                        ),
                                      );
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(ThemeData theme, List<Todo> allTodos) {
    final isDark = theme.brightness == Brightness.dark;
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Calendar days
          ...List.generate(6, (week) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: List.generate(7, (day) {
                  final dayNumber = (week * 7 + day) - firstWeekday + 2;
                  final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
                  final date = isCurrentMonth ? DateTime(_selectedDate.year, _selectedDate.month, dayNumber) : null;
                  final isSelected = date != null && 
                      date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;
                  final isToday = date != null && 
                      date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final hasTasks = date != null && allTodos.any((todo) => 
                      todo.dueDate != null &&
                      todo.dueDate!.year == date.year &&
                      todo.dueDate!.month == date.month &&
                      todo.dueDate!.day == date.day);

                  return Expanded(
                    child: GestureDetector(
                      onTap: isCurrentMonth ? () {
                        setState(() {
                          _selectedDate = date!;
                        });
                      } : null,
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : isToday
                                  ? AppColors.primaryAccent.withValues(alpha: 0.2)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                isCurrentMonth ? '$dayNumber' : '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? AppColors.white
                                      : isDark ? AppColors.darkMainText : AppColors.lightMainText,
                                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (hasTasks)
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppColors.white 
                                        : AppColors.secondaryAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No tasks for this date',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a date to view tasks or create a new one',
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

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return 'Tomorrow';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _formatMonthYear(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
