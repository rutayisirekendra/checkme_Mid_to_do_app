import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EnhancedDailyInspiration extends StatelessWidget {
  final String quote;
  final String author;

  const EnhancedDailyInspiration({
    super.key,
    this.quote = "The future belongs to those who believe in the beauty of their dreams.",
    this.author = "Eleanor Roosevelt",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryAccent.withValues(alpha: 0.15),
            AppColors.primaryAccent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondaryAccent.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryAccent.withValues(alpha: 0.1),
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
                      AppColors.secondaryAccent.withValues(alpha: 0.2),
                      AppColors.secondaryAccent.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.secondaryAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Inspiration',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stay motivated and focused',
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
            ],
          ),

          const SizedBox(height: 20),

          // Quote Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.darkSurface.withValues(alpha: 0.5)
                  : AppColors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark 
                    ? AppColors.darkBorder
                    : AppColors.lightMainText.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"$quote"',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '— $author',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark 
                          ? AppColors.darkSecondaryText 
                          : AppColors.lightMainText.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
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
}
