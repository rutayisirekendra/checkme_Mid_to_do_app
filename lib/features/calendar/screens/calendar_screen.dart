import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/todo_provider.dart';
import '../../../models/todo.dart';
import '../widgets/calendar_todo_list.dart';
import '../../todo/screens/edit_todo_screen.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late final ValueNotifier<List<Todo>> _selectedDayTodos;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedDayTodos = ValueNotifier(_getTodosForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedDayTodos.dispose();
    super.dispose();
  }

  List<Todo> _getTodosForDay(DateTime day) {
    final todos = ref.read(todoListProvider);
    return todos.where((todo) {
      if (todo.dueDate == null) return false;
      return isSameDay(todo.dueDate!, day);
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedDayTodos.value = _getTodosForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
                _selectedDayTodos.value = _getTodosForDay(DateTime.now());
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar with compact height to give more space to todo list
          Container(
            height: 280, // Reduced height for better space allocation
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: TableCalendar<Todo>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  weekendTextStyle: TextStyle(
                    color: AppColors.secondaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                  defaultTextStyle: TextStyle(
                    color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  ),
                  selectedTextStyle: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  todayTextStyle: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.secondaryAccent,
                    shape: BoxShape.circle,
                  ),
                  defaultDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  weekendDecoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 3,
                  markerDecoration: BoxDecoration(
                    color: AppColors.grassGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  titleTextStyle: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: AppColors.primaryAccent,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: AppColors.primaryAccent,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                    color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                  weekendStyle: TextStyle(
                    color: AppColors.secondaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                eventLoader: _getTodosForDay,
              ),
            ),
          ),

          // Selected Day Todos - This will take the remaining space efficiently
          Expanded(
            child: ValueListenableBuilder<List<Todo>>(
              valueListenable: _selectedDayTodos,
              builder: (context, todos, _) {
                return CalendarTodoList(
                  todos: todos,
                  selectedDate: _selectedDay!,
                  onTodoTap: (todo) {
                    // Optional: Navigate to todo details if needed
                  },
                  onTodoToggle: (todo) {
                    ref.read(todoListProvider.notifier).toggleTodo(todo.id);
                    // Update the selected day todos immediately
                    _selectedDayTodos.value = _getTodosForDay(_selectedDay!);
                  },
                  onTodoDelete: (todo) {
                    ref.read(todoListProvider.notifier).deleteTodo(todo.id);
                    // Update the selected day todos immediately
                    _selectedDayTodos.value = _getTodosForDay(_selectedDay!);
                  },
                  onTodoEdit: (todo) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditTodoScreen(todo: todo),
                      ),
                    ).then((result) {
                      // Refresh the selected day todos after editing
                      _selectedDayTodos.value = _getTodosForDay(_selectedDay!);
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
