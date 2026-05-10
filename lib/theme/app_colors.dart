import 'package:flutter/material.dart';

/// LuminAI Design System — Color Tokens
///
/// High-contrast monochrome palette with glassmorphism support.
/// Deep Navy for branding/active states, Slate Grey for secondary,
/// Pure White canvas for maximum legibility.
class AppColors {
  AppColors._();

  // ─── Brand Primaries ───────────────────────────────────────
  static const Color deepNavy = Color(0xFF1A1A2E);
  static const Color slateGrey = Color(0xFF2D3436);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ─── Surface Tiers ─────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF6F2F4);
  static const Color surface = Color(0xFFFCF8FA);
  static const Color surfaceContainer = Color(0xFFF1EDEF);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E9);
  static const Color surfaceContainerHighest = Color(0xFFE5E1E3);
  static const Color surfaceDim = Color(0xFFDDD9DB);

  // ─── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF2D3436);
  static const Color textTertiary = Color(0xFF78767D);
  static const Color textInverse = Color(0xFFFFFFFF);

  // ─── Glassmorphism ─────────────────────────────────────────
  /// 15% opacity Deep Navy fill for glass cards
  static Color glassFill = deepNavy.withOpacity(0.15);

  /// 1px white inner stroke for glass edges
  static Color glassStroke = pureWhite.withOpacity(0.20);

  /// Frosted background overlay
  static Color glassFrost = pureWhite.withOpacity(0.70);

  // ─── Semantic / Alert ──────────────────────────────────────
  static const Color warningOrange = Color(0xFFFF8C00); // Dark Orange
  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color successGreen = Color(0xFF00C853);
  static const Color infoBlue = Color(0xFF2196F3);

  // ─── Interactive ───────────────────────────────────────────
  static const Color buttonPrimary = deepNavy;
  static const Color buttonPrimaryText = pureWhite;
  static const Color buttonSecondaryBorder = slateGrey;

  // ─── Progress / Data ───────────────────────────────────────
  static const Color progressTrack = Color(0xFFE5E1E3);
  static const Color progressFill = deepNavy;

  // ─── Outline ───────────────────────────────────────────────
  static const Color outline = Color(0xFF78767D);
  static const Color outlineVariant = Color(0xFFC8C5CD);
}
