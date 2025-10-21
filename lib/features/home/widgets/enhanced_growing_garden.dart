import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EnhancedGrowingGarden extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;

  const EnhancedGrowingGarden({
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.grassGreen.withValues(alpha: 0.1),
            AppColors.primaryAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.grassGreen.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grassGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.grassGreen.withValues(alpha: 0.2),
                      AppColors.grassGreen.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.local_florist_rounded,
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
                      '$completedTasks of $totalTasks tasks completed',
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
              // Progress Percentage
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.grassGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.grassGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Garden Visualization
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
                    height: 20,
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
                ...List.generate(5, (index) {
                  final plantProgress = (progress * 5) > index ? 1.0 : ((progress * 5) - index).clamp(0.0, 1.0);
                  return Positioned(
                    left: 20 + (index * 60.0),
                    bottom: 20,
                    child: _buildPlant(plantProgress, index),
                  );
                }),
                
                // Progress overlay
                if (progress > 0)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.grassGreen.withValues(alpha: 0.1),
                            Colors.transparent,
                          ],
                          stops: [progress, progress],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlant(double progress, int index) {
    final height = 20 + (progress * 60);
    final opacity = progress > 0.3 ? 1.0 : progress * 3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Plant stem
          Container(
            width: 4,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.grassGreen.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Plant leaves/flowers
          if (progress > 0.5)
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.flowerPink.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco_rounded,
                color: AppColors.white.withValues(alpha: opacity),
                size: 12,
              ),
            ),
        ],
      ),
    );
  }
}
