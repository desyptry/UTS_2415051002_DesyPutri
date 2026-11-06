import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryDark = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFFE0F7F4);
  static const Color primaryGradientStart = Color(0xFF00BFA5);
  static const Color primaryGradientEnd = Color(0xFF00897B);

  // Secondary & Accents
  static const Color coral = Color(0xFFFF7043);
  static const Color coralLight = Color(0xFFFBE9E7);
  static const Color amber = Color(0xFFFFA726);
  static const Color amberLight = Color(0xFFFFF3E0);
  static const Color skyBlue = Color(0xFF0288D1);
  static const Color skyBlueLight = Color(0xFFE1F5FE);
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFFD1FAE5);

  // Background & Surfaces
  static const Color background = Color(0xFFF6F9F8);
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFE5EBE8);

  // Typography
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF009688)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF8A65), Color(0xFFFF5722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

