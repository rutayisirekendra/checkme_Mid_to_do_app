import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/note.dart';
import '../../../shared/providers/category_provider.dart';

class EnhancedNoteCard extends ConsumerWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTogglePin;

  const EnhancedNoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onTogglePin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = ref.watch(categoryProvider);

    // Find category by matching name
    final category = categories.cast<dynamic>().firstWhere(
          (cat) => cat.name == (note.category ?? 'Personal'),
      orElse: () => null,
    );

    final categoryColor = category != null ? Color(category.color) : AppColors.primaryAccent;
    final categoryIcon = category != null
        ? IconData(category.effectiveIconCodePoint, fontFamily: 'MaterialIcons')
        : Icons.note;

    // Small icon/card background used for category icon
    Widget _smallIconBg({required Widget child, required Color color}) {
      return Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.14), color.withOpacity(0.06)],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: child,
      );
    }

    // Determine date label and color (uses date-only comparison)
    Map<String, dynamic> _dateStatus(DateTime date) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final d = DateTime(date.year, date.month, date.day);
      final diff = d.difference(today).inDays; // positive => future

      // Colors chosen to be visually distinct
      const Color colorToday = Color(0xFF2563EB); // blue
      const Color colorTomorrow = Color(0xFFFB923C); // orange
      const Color colorYesterday = Color(0xFF6B7280); // gray
      const Color colorOverdue = Color(0xFFEF4444); // red
      const Color colorFuture = Color(0xFF10B981); // green
      const Color colorDefault = Color(0xFF374151); // slate

      if (diff == 0) {
        return {'label': 'Today', 'color': colorToday};
      } else if (diff == 1) {
        return {'label': 'Tomorrow', 'color': colorTomorrow};
      } else if (diff == -1) {
        return {'label': 'Yesterday', 'color': colorYesterday};
      } else if (diff < -1) {
        return {'label': 'Overdue', 'color': colorOverdue};
      } else if (diff > 1) {
        return {'label': 'In $diff days', 'color': colorFuture};
      } else {
        return {'label': '${date.day}/${date.month}/${date.year}', 'color': colorDefault};
      }
    }

    final dateStatus = _dateStatus(note.createdAt);
    final badgeColor = dateStatus['color'] as Color;
    final badgeLabel = dateStatus['label'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: note.isPinned
              ? categoryColor.withOpacity(0.28)
              : (isDark ? AppColors.darkBorder : AppColors.lightMainText.withOpacity(0.08)),
          width: note.isPinned ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightMainText).withOpacity(0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: categoryColor.withOpacity(0.08),
          highlightColor: categoryColor.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Icon, Title, Pin (pin top-right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _smallIconBg(
                      color: categoryColor,
                      child: Icon(categoryIcon, color: categoryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Title + badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkMainText : AppColors.lightMainText,
                              fontSize: 16,
                              letterSpacing: -0.2,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Category Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  category?.name ?? 'Personal',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Date badge using clock icon and status color
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  color: badgeColor.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: badgeColor.withOpacity(0.18),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded, // clock icon
                                      size: 14,
                                      color: badgeColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      badgeLabel,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: badgeColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (note.isLocked) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.flowerYellow.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.lock, size: 14, color: AppColors.flowerYellow),
                                )
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Pin indicator top-right
                    GestureDetector(
                      onTap: onTogglePin,
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: note.isPinned ? categoryColor.withOpacity(0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                          size: 18,
                          color: note.isPinned ? categoryColor : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withOpacity(0.7)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Content Preview in styled container (matching todo description style)
                if (note.content.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground.withValues(alpha: 0.5)
                          : AppColors.lightBackground.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.5)
                            : AppColors.lightMainText.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      note.content,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkSecondaryText
                            : AppColors.lightMainText.withValues(alpha: 0.7),
                        height: 1.5,
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Footer: actions right-aligned
                Row(
                  children: [
                    const Spacer(),
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      color: AppColors.primaryAccent,
                      onTap: onEdit,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete_outline,
                      color: AppColors.lightOverdue,
                      onTap: onDelete,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.20),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}