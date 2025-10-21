import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class StreakVisualizer extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakVisualizer({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColors.secondaryAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Streak',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Streak visualization
          Row(
            children: [
              Expanded(
                child: _buildStreakInfo(
                  'Current',
                  currentStreak.toString(),
                  AppColors.secondaryAccent,
                  theme,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakInfo(
                  'Best',
                  longestStreak.toString(),
                  AppColors.primaryAccent,
                  theme,
                  isDark,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Visual streak path
          _buildStreakPath(currentStreak, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildStreakInfo(
    String label,
    String value,
    Color color,
    ThemeData theme,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark 
                ? AppColors.darkSecondaryText 
                : AppColors.lightMainText.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakPath(int streak, ThemeData theme, bool isDark) {
    final days = List.generate(7, (index) => index < streak);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final isActive = entry.value;
        
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive 
                ? AppColors.secondaryAccent 
                : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isActive 
                    ? AppColors.white 
                    : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText).withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}