import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  final String userName;
  final String? avatarPath;

  const HomeAppBar({
    super.key,
    required this.userName,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryAccent,
            backgroundImage: avatarPath != null ? AssetImage(avatarPath!) : null,
            child: avatarPath == null
                ? Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 16),
          
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello,',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark 
                        ? AppColors.darkSecondaryText 
                        : AppColors.lightMainText.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  userName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Notifications
          IconButton(
            onPressed: () {
              // TODO: Implement notifications
            },
            icon: Icon(
              Icons.notifications_outlined,
              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
            ),
          ),
        ],
      ),
    );
  }
}

