import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/todo_provider.dart';

class EnhancedSearchBar extends ConsumerWidget {
  final VoidCallback? onTap;

  const EnhancedSearchBar({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final searchQuery = ref.watch(searchQueryProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF2F2F5), // light gray pill
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5D6), // light peach
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.secondaryAccent,
              size: 20,
            ),
          ),

          const SizedBox(width: 16),

          // Search Input
          Expanded(
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).updateQuery(value);
              },
              onTap: onTap,
              decoration: InputDecoration(
                hintText: 'Search your todos...',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark 
                      ? AppColors.darkSecondaryText 
                      : AppColors.lightMainText.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                filled: false, // transparent field blending with container
                contentPadding: EdgeInsets.zero,
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Clear Button (if search has content)
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                ref.read(searchQueryProvider.notifier).clearQuery();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.lightOverdue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: AppColors.lightOverdue,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
