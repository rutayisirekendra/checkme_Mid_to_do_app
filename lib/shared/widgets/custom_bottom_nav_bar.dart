import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
              ? AppColors.darkBorder 
              : AppColors.lightMainText.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText)
                .withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText)
                .withValues(alpha: 0.05),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                  isSelected: selectedIndex == 0,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: selectedIndex == 1 ? Icons.calendar_month_rounded : Icons.calendar_month_outlined,
                  label: 'Calendar',
                  index: 1,
                  isSelected: selectedIndex == 1,
                  isDark: isDark,
                ),
                _buildCenterButton(isDark),
                _buildNavItem(
                  icon: selectedIndex == 3 ? Icons.task_alt_rounded : Icons.task_alt_outlined,
                  label: 'Tasks',
                  index: 3,
                  isSelected: selectedIndex == 3,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: selectedIndex == 4 ? Icons.person_rounded : Icons.person_outline_rounded,
                  label: 'Profile',
                  index: 4,
                  isSelected: selectedIndex == 4,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.darkAccent : AppColors.primaryAccent).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Icon(
                icon,
                size: isSelected ? 26 : 24,
                color: isSelected
                    ? (isDark ? AppColors.darkAccent : AppColors.primaryAccent)
                    : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isSelected ? 12 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? AppColors.darkAccent : AppColors.primaryAccent)
                    : (isDark ? AppColors.darkSecondaryText : AppColors.lightMainText.withValues(alpha: 0.6)),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(bool isDark) {
    return GestureDetector(
      onTap: () => onItemSelected(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryAccent,
              AppColors.secondaryAccent,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryAccent.withValues(alpha: 0.2),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}
