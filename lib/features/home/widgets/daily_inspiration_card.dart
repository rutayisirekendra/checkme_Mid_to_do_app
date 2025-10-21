import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DailyInspirationCard extends StatelessWidget {
  const DailyInspirationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final quotes = [
      "The way to get started is to quit talking and begin doing.",
      "Don't be afraid to give up the good to go for the great.",
      "Innovation distinguishes between a leader and a follower.",
      "The future belongs to those who believe in the beauty of their dreams.",
      "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    ];

    final randomQuote = quotes[DateTime.now().day % quotes.length];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryAccent.withValues(alpha: 0.1),
            AppColors.secondaryAccent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryAccent.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.secondaryAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Inspiration',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            randomQuote,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark 
                  ? AppColors.darkMainText.withValues(alpha: 0.8)
                  : AppColors.lightMainText.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

