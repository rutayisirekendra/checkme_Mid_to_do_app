import '../models/user.dart';
import '../models/todo.dart';
import 'database_service.dart';

class StreakService {
  /// Calculate the current streak based on consecutive days of task completion
  static int calculateCurrentStreak(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Get all completed todos for the user
    final completedTodos = DatabaseService.getTodos()
        .where((todo) => todo.isCompleted && todo.completedAt != null)
        .toList();
    
    if (completedTodos.isEmpty) return 0;
    
    // Group completed todos by date
    final Map<DateTime, List<Todo>> todosByDate = {};
    for (final todo in completedTodos) {
      final completedDate = DateTime(
        todo.completedAt!.year,
        todo.completedAt!.month,
        todo.completedAt!.day,
      );
      todosByDate.putIfAbsent(completedDate, () => []).add(todo);
    }
    
    // Count consecutive days starting from today/yesterday
    int streak = 0;
    DateTime checkDate = today;
    
    // Check if there are completed tasks today
    if (todosByDate.containsKey(today)) {
      streak = 1;
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      // If no tasks completed today, start checking from yesterday
      checkDate = today.subtract(const Duration(days: 1));
    }
    
    // Count consecutive days backwards
    while (todosByDate.containsKey(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }
  
  /// Update the user's streak information when a todo is completed
  static Future<void> updateUserStreak(String userId) async {
    final user = DatabaseService.getUserById(userId);
    if (user == null) return;
    
    final currentStreak = calculateCurrentStreak(userId);
    final longestStreak = currentStreak > user.longestStreak 
        ? currentStreak 
        : user.longestStreak;
    
    final updatedUser = user.copyWith(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
    
    await DatabaseService.saveUser(updatedUser);
  }
  
  /// Check if the user has completed any task today
  static bool hasCompletedTaskToday(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final completedTodos = DatabaseService.getTodos()
        .where((todo) => todo.isCompleted && todo.completedAt != null)
        .toList();
    
    return completedTodos.any((todo) {
      final completedDate = DateTime(
        todo.completedAt!.year,
        todo.completedAt!.month,
        todo.completedAt!.day,
      );
      return completedDate == today;
    });
  }
  
  /// Get streak statistics for display
  static Map<String, int> getStreakStats(String userId) {
    final user = DatabaseService.getUserById(userId);
    if (user == null) {
      return {
        'current': 0,
        'longest': 0,
        'total_completed': 0,
      };
    }
    
    final completedCount = DatabaseService.getTodos()
        .where((todo) => todo.isCompleted)
        .length;
    
    return {
      'current': user.currentStreak,
      'longest': user.longestStreak,
      'total_completed': completedCount,
    };
  }
}
