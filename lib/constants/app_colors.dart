import 'package:flutter/material.dart';

/// AppColors derived from the Sauvaad logo:
/// Vibrant cyan (#00D2FF) into deep indigo/violet (#6366F1) and royal purple (#9333EA)
/// over a deep midnight space background (#070A14).
class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF070A14);
  static const Color backgroundAlt = Color(0xFF0D1322);
  static const Color surface = Color(0xFF11192C);
  static const Color surfaceElevated = Color(0xFF1B243B);
  static const Color surfaceBorder = Color(0xFF263353);

  // Gradient Colors
  static const Color cyan = Color(0xFF00D2FF);
  static const Color blue = Color(0xFF38BDF8);
  static const Color indigo = Color(0xFF6366F1);
  static const Color purple = Color(0xFF9333EA);
  static const Color violet = Color(0xFFA855F7);
  static const Color magenta = Color(0xFFD946EF);

  // Action & State Colors
  static const Color callGreen = Color(0xFF10B981);
  static const Color callRed = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF64748B);

  // Primary Gradient (Logo Ribbon flow)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyan, indigo, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary Soft Glow Gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [cyan, violet],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Dark Surface Gradient for Cards
  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Color(0xFF141D33),
      Color(0xFF0E1626),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Call Green Gradient
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
