import 'package:flutter/material.dart';

/// Global color palette used across the app.
///
/// Use these colors instead of hardcoding colors in widgets so that theme
/// updates can be made in one place.
class AppColors {
  AppColors._();

  // Primary branding colors
  static const Color primary = Color(0xFF6B7280);
  static const Color primaryDark = Color(0xFF4B5563);
  static const Color primaryLight = Color(0xFF9CA3AF);
  static const Color primaryExtraLight = Color(0xFFEFF6FF);

  // Secondary / accent
  static const Color secondary = Color(0xFF9CA3AF);
  static const Color accent = Color(0xFFFFA000);

  // Background / surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);

  // Text
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textHint = Color(0xFF9CA3AF);

  // Greys
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF); //primaryLight
  static const Color grey500 = Color(0xFF6B7280); //primary
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151); //primaryDark

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // Common
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color black87 = Color(0xDD000000);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color black54 = Color(0x8A000000);
  static const Color transparent = Colors.transparent;

  // Misc
  static const Color amber = Color(0xFFFFC107);
}
