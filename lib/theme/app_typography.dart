import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// LuminAI Design System — Typography Tokens
///
/// Inter: all core functional text (headers, body, labels)
/// Russo One: performance-critical data (rep counts, timers, HR)
class AppTypography {
  AppTypography._();

  // ─── Russo One — Performance Metrics ───────────────────────
  /// Large display metrics: rep counts, timers, big numbers
  static TextStyle displayMetrics = GoogleFonts.russoOne(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.1,
    letterSpacing: 0.96, // 0.02em
    color: AppColors.textPrimary,
  );

  /// Medium metric: set counts, weight values
  static TextStyle metricMd = GoogleFonts.russoOne(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  /// Small metric: BPM, kcal, small data points
  static TextStyle metricSm = GoogleFonts.russoOne(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  // ─── Inter — UI Text ──────────────────────────────────────

  /// Page titles, hero text
  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.64, // -0.02em
    color: AppColors.textPrimary,
  );

  /// Section headers, card titles
  static TextStyle headlineMd = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Subsection headers
  static TextStyle headlineSm = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// Primary body text
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  /// Standard body text
  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Secondary / supporting text
  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  /// Uppercase labels, category tags
  static TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 1.2, // 0.1em
    color: AppColors.textTertiary,
  );

  /// Small labels (timestamps, metadata)
  static TextStyle labelSm = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.textTertiary,
  );

  /// Button text
  static TextStyle button = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.28,
    color: AppColors.textPrimary,
  );

  /// Unit labels next to metrics (e.g., "BPM", "KG")
  static TextStyle metricUnit = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: 1.4,
    color: AppColors.textTertiary,
  );
}
