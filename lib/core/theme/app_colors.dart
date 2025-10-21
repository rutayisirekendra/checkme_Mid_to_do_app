// import 'package:flutter/material.dart';
//
// class AppColors {
//   // Light Mode Colors
//   static const Color primaryAccent = Color(0xFF4E7D96); // Blue-Gray
//   static const Color secondaryAccent = Color(0xFFFF844B); // Deep Orange
//   static const Color lightBackground = Color(0xFFE3EDF2); // Soft Gray
//   static const Color lightMainText = Color(0xFF0A0D25); // Dark Navy
//   static const Color lightOverdue = Color(0xFFD32F2F); // Deep Red
//
//   // Dark Mode Colors - More Vibrant and Distinct
//   static const Color darkBackground = Color(0xFF0A0A0A); // Deep Black
//   static const Color darkSurface = Color(0xFF1A1A1A); // Dark Surface
//   static const Color darkMainText = Color(0xFFE8E8E8); // Bright White
//   static const Color darkSecondaryText = Color(0xFFB0B0B0); // Light Gray
//   static const Color darkOverdue = Color(0xFFFF4444); // Bright Red
//   static const Color darkCard = Color(0xFF2A2A2A); // Card Background
//   static const Color darkBorder = Color(0xFF404040); // Border Color
//   static const Color darkAccent = Color(0xFF6366F1); // Indigo Accent
//   static const Color darkSecondary = Color(0xFFF59E0B); // Amber Secondary
//   static const Color darkSuccess = Color(0xFF10B981); // Emerald Success
//   static const Color darkWarning = Color(0xFFF59E0B); // Amber Warning
//
//   // Common Colors
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color black = Color(0xFF000000);
//   static const Color transparent = Color(0x00000000);
//
//   // Glassmorphism Colors
//   static const Color glassWhite = Color(0x80FFFFFF);
//   static const Color glassBlack = Color(0x80000000);
//
//   // Gradient Colors
//   static const List<Color> primaryGradient = [
//     Color(0xFF4E7D96),
//     Color(0xFF5A8BA8),
//   ];
//
//   static const List<Color> secondaryGradient = [
//     Color(0xFFFF844B),
//     Color(0xFFFF9A6B),
//   ];
//
//   // Growing Garden Colors
//   static const Color grassGreen = Color(0xFF4CAF50);
//   static const Color flowerPink = Color(0xFFE91E63);
//   static const Color flowerYellow = Color(0xFFFFC107);
//   static const Color flowerPurple = Color(0xFF9C27B0);
//   static const Color sunYellow = Color(0xFFFFEB3B);
//   static const Color skyBlue = Color(0xFF2196F3);
// }
//
//
import 'package:flutter/material.dart';

class AppColors {
  // Light Mode Colors - Unified with Orange as the Primary Accent
  static const Color primaryAccent = Color(0xFFFF844B); // Was Blue-Gray, now unified Orange
  static const Color secondaryAccent = Color(0xFFFF844B); // Stays Deep Orange
  static const Color lightBackground = Color(0xFFF0F4F8); // A cleaner, softer off-white
  static const Color lightMainText = Color(0xFF1A202C); // A softer, less intense dark gray
  static const Color lightOverdue = Color(0xFFD32F2F); // Deep Red (Unchanged)

  // Dark Mode Colors - Unified with Amber as the Primary Accent
  static const Color darkBackground = Color(0xFF121212); // Standard Material Dark
  static const Color darkSurface = Color(0xFF1E1E1E); // Slightly lighter surface for contrast
  static const Color darkMainText = Color(0xFFE8E8E8); // Bright White (Unchanged)
  static const Color darkSecondaryText = Color(0xFFB0B0B0); // Light Gray (Unchanged)
  static const Color darkOverdue = Color(0xFFFF4444); // Bright Red (Unchanged)
  static const Color darkCard = Color(0xFF1E1E1E); // Matching the new darkSurface color
  static const Color darkBorder = Color(0xFF3A3A3A); // A slightly softer border color
  static const Color darkAccent = Color(0xFFF59E0B); // Was Indigo, now unified Amber
  static const Color darkSecondary = Color(0xFFF59E0B); // Amber Secondary (Unchanged)
  static const Color darkSuccess = Color(0xFF10B981); // Emerald Success (Unchanged)
  static const Color darkWarning = Color(0xFFF59E0B); // Amber Warning (Unchanged)

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Glassmorphism Colors
  static const Color glassWhite = Color(0x80FFFFFF);
  static const Color glassBlack = Color(0x80000000);

  // Gradient Colors - Updated to reflect the unified orange theme
  static const List<Color> primaryGradient = [
    Color(0xFFFF844B),
    Color(0xFFFF9A6B),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF844B),
    Color(0xFFFF9A6B),
  ];

  // Growing Garden Colors (Unchanged)
  static const Color grassGreen = Color(0xFF4CAF50);
  static const Color flowerPink = Color(0xFFE91E63);
  static const Color flowerYellow = Color(0xFFFFC107);
  static const Color flowerPurple = Color(0xFF9C27B0);
  static const Color sunYellow = Color(0xFFFFEB3B);
  static const Color skyBlue = Color(0xFF2196F3);
}

