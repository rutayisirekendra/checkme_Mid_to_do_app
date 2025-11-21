import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/modern_bottom_nav_bar.dart';
import '../home/screens/home_screen.dart';
import '../calendar/screens/enhanced_calendar_screen.dart';
import '../todo/screens/enhanced_todo_list_screen.dart';
import '../notes/screens/enhanced_notes_screen.dart';
import '../settings/screens/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Main content area that takes up full screen
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: const [
              HomeScreen(),
              EnhancedCalendarScreen(),
              EnhancedTodoListScreen(),
              EnhancedNotesScreen(),
              SettingsScreen(),
            ],
          ),
          // Floating navigation bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ModernBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}


