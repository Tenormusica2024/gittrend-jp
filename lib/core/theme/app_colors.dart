import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF0EA5E9);
  static const Color primaryDark = Color(0xFF0284C7);
  static const Color secondary = Color(0xFF14B8A6);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color star = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Map<String, Color> languageColors = {
    'Python': Color(0xFF3572A5),
    'JavaScript': Color(0xFFF1E05A),
    'TypeScript': Color(0xFF3178C6),
    'Java': Color(0xFFB07219),
    'Kotlin': Color(0xFFA97BFF),
    'Swift': Color(0xFFFFAC45),
    'Go': Color(0xFF00ADD8),
    'Rust': Color(0xFFDEA584),
    'Ruby': Color(0xFF701516),
    'PHP': Color(0xFF4F5D95),
    'C++': Color(0xFFF34B7D),
    'C#': Color(0xFF178600),
    'Dart': Color(0xFF00B4AB),
  };
}
