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
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightMainText.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppColors.darkMainText : AppColors.lightMainText).withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemSelected,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: isDark ? AppColors.darkAccent : AppColors.secondaryAccent,
          unselectedItemColor: isDark ? AppColors.darkSecondaryText : Colors.grey[600],
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                size: 28,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 1 ? Icons.calendar_month : Icons.calendar_month_outlined,
                size: 28,
              ),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryAccent, // Solid orange
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryAccent.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 3 ? Icons.list_alt : Icons.list_alt_outlined,
                size: 28,
              ),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                selectedIndex == 4 ? Icons.person : Icons.person_outline,
                size: 28,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
