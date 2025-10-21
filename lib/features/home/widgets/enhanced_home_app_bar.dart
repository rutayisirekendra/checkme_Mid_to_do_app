import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EnhancedHomeAppBar extends StatelessWidget {
  final String userName;
  final int currentStreak;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const EnhancedHomeAppBar({
    super.key,
    required this.userName,
    required this.currentStreak,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                  AppColors.lightBackground.withValues(alpha: 0.8),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent, // Solid orange
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryAccent.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userName.substring(0, 1).toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Greeting Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey $userName...',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to be productive?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark 
                        ? AppColors.darkSecondaryText 
                        : AppColors.lightMainText.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Streak Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryAccent, // Solid orange
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryAccent.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$currentStreak',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Notification Button
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
