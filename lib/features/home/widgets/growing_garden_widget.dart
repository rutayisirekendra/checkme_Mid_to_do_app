import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GrowingGardenWidget extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const GrowingGardenWidget({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grassGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_florist,
                  color: AppColors.grassGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Growing Garden',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Watch your garden bloom with productivity',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark 
                            ? AppColors.darkSecondaryText 
                            : AppColors.lightMainText.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Garden visualization
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.grassGreen.withValues(alpha: 0.1),
                  AppColors.grassGreen.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Ground
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.grassGreen.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),
                // Plants based on progress
                ...List.generate(
                  (progress * 8).round().clamp(0, 8),
                  (index) => Positioned(
                    bottom: 20,
                    left: 20 + (index * 40.0),
                    child: _buildPlant(progress, index),
                  ),
                ),
                // Progress percentage overlay
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.grassGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(progress * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Progress stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '$completedTasks',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grassGreen,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    '$totalTasks',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlant(double progress, int index) {
    final plantHeight = 20 + (progress * 40);
    final plantColor = AppColors.grassGreen.withValues(alpha: 0.6 + (progress * 0.4));
    
    return Container(
      width: 20,
      height: plantHeight,
      decoration: BoxDecoration(
        color: plantColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          // Plant stem
          Container(
            width: 4,
            height: plantHeight * 0.7,
            margin: EdgeInsets.only(left: 8, top: plantHeight * 0.3),
            decoration: BoxDecoration(
              color: AppColors.grassGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Plant leaves
          if (progress > 0.3)
            Positioned(
              top: plantHeight * 0.2,
              left: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.grassGreen.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (progress > 0.6)
            Positioned(
              top: plantHeight * 0.4,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.grassGreen.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
