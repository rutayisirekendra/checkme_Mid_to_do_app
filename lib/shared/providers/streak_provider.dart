import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/streak_service.dart';
import 'auth_provider.dart';
import 'todo_provider.dart';

// Streak statistics provider
final streakStatsProvider = Provider<Map<String, int>>((ref) {
  // Watch for user changes
  final userAsync = ref.watch(currentUserProvider);
  // Watch for todo changes to trigger recalculation
  ref.watch(todoListProvider);
  
  final userId = userAsync.value?.id;
  if (userId == null || userId.isEmpty) {
    return {
      'current': 0,
      'longest': 0,
      'total_completed': 0,
    };
  }

  // Keep provider alive to avoid recalculation
  ref.keepAlive();
  
  try {
    return StreakService.getStreakStats(userId);
  } catch (e) {
    print('Error calculating streak stats: $e');
    return {
      'current': 0,
      'longest': 0,
      'total_completed': 0,
    };
  }
});

// Current streak provider (reactive to todo completions)
final currentStreakProvider = Provider<int>((ref) {
  // Watch for user changes
  final userAsync = ref.watch(currentUserProvider);
  // Watch for todo changes to trigger recalculation
  ref.watch(todoListProvider);
  
  final userId = userAsync.value?.id;
  if (userId == null || userId.isEmpty) {
    return 0;
  }

  // Keep provider alive to avoid recalculation
  ref.keepAlive();
  
  try {
    return StreakService.calculateCurrentStreak(userId);
  } catch (e) {
    print('Error calculating current streak: $e');
    return 0;
  }
});

// Today's completion status provider
final hasCompletedTodayProvider = Provider<bool>((ref) {
  // Watch for user changes
  final userAsync = ref.watch(currentUserProvider);
  // Watch for todo changes to trigger recalculation
  ref.watch(todoListProvider);
  
  final userId = userAsync.value?.id;
  if (userId == null || userId.isEmpty) {
    return false;
  }

  // Keep provider alive to avoid recalculation
  ref.keepAlive();
  
  try {
    return StreakService.hasCompletedTaskToday(userId);
  } catch (e) {
    print('Error checking today completion: $e');
    return false;
  }
});

// Streak notification provider - watches for streak changes
final streakNotificationProvider = StateNotifierProvider<StreakNotificationNotifier, StreakNotificationState>((ref) {
  return StreakNotificationNotifier(ref);
});

class StreakNotificationState {
  final int? previousStreak;
  final int currentStreak;
  final bool showCelebration;
  final String? celebrationMessage;

  const StreakNotificationState({
    this.previousStreak,
    required this.currentStreak,
    this.showCelebration = false,
    this.celebrationMessage,
  });

  StreakNotificationState copyWith({
    int? previousStreak,
    int? currentStreak,
    bool? showCelebration,
    String? celebrationMessage,
  }) {
    return StreakNotificationState(
      previousStreak: previousStreak ?? this.previousStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      showCelebration: showCelebration ?? this.showCelebration,
      celebrationMessage: celebrationMessage ?? this.celebrationMessage,
    );
  }
}

class StreakNotificationNotifier extends StateNotifier<StreakNotificationState> {
  final Ref _ref;

  StreakNotificationNotifier(this._ref) : super(const StreakNotificationState(currentStreak: 0)) {
    // Listen to streak changes
    _ref.listen(currentStreakProvider, (previous, next) {
      _handleStreakChange(previous, next);
    });
  }

  void _handleStreakChange(int? previous, int current) {
    if (previous != null && current > previous) {
      // Streak increased - show celebration
      String message = _getStreakMessage(current);
      
      state = state.copyWith(
        previousStreak: previous,
        currentStreak: current,
        showCelebration: true,
        celebrationMessage: message,
      );
      
      // Auto-hide celebration after a delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          hideCelebration();
        }
      });
    } else {
      state = state.copyWith(
        previousStreak: previous,
        currentStreak: current,
        showCelebration: false,
      );
    }
  }

  String _getStreakMessage(int streak) {
    switch (streak) {
      case 1:
        return "🎉 Great start! Your first day streak!";
      case 2:
        return "🔥 Two days in a row! Keep it going!";
      case 3:
        return "⭐ Three days strong! Building the habit!";
      case 7:
        return "🏆 One week streak! You're on fire!";
      case 14:
        return "💎 Two weeks! You're unstoppable!";
      case 30:
        return "🌟 30 days! You're a productivity champion!";
      default:
        if (streak % 10 == 0) {
          return "🚀 ${streak} days! Amazing consistency!";
        }
        return "🔥 ${streak} days streak! Keep going!";
    }
  }

  void hideCelebration() {
    state = state.copyWith(showCelebration: false);
  }
}
