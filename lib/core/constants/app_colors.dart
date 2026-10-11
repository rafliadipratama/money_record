import 'package:flutter/material.dart';

/// Design tokens for the Modern Fintech Design System.
/// Built with high-contrast accessibility (WCAG AA compliant)
/// and dark/light adaptive elevation.
class AppColors {
  AppColors._();

  // Primary Trust Accents
  static const Color primary = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF1E293B);
  static const Color primaryAccent = Color(0xFF3B82F6); // Blue 500

  // Income / Growth Palette (Emerald)
  static const Color income = Color(0xFF10B981); // Emerald 500
  static const Color incomeLight = Color(0xFFD1FAE5);
  static const Color incomeDark = Color(0xFF047857);

  // Expense / Alert Palette (Rose / Coral)
  static const Color expense = Color(0xFFF43F5E); // Rose 500
  static const Color expenseLight = Color(0xFFFFE4E6);
  static const Color expenseDark = Color(0xFFBE123C);

  // Neutral Backgrounds & Cards
  static const Color bgDark = Color(0xFF0A0F1D);
  static const Color cardDark = Color(0xFF131B2E);
  static const Color cardBorderDark = Color(0x1FFFFFFF); // 12% white
  static const Color cardGlassDark = Color(0x99131B2E);

  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color cardGlassLight = Color(0xCCFFFFFF);

  // Text Colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Category Colors
  static const List<Color> categoryPalette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
    Color(0xFF6366F1), // Indigo
  ];
}
