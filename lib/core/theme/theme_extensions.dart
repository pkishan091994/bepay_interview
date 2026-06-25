import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// BuildContext extension that returns the correct adaptive color depending on
/// whether the app is currently in dark or light mode.
///
/// Usage:  `context.appBackground`, `context.appSurface`, etc.
extension AppColors on BuildContext {
  // ── Core brightness helper ──────────────────────────────────────────────
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ── Background / surface ────────────────────────────────────────────────
  Color get appBackground =>
      isDark ? AppTheme.darkBackground : AppTheme.background;

  Color get appSurface =>
      isDark ? AppTheme.darkSurface : AppTheme.surface;

  Color get appInactiveBg =>
      isDark ? AppTheme.darkInactiveBg : AppTheme.inactiveBg;

  // ── Borders / dividers ──────────────────────────────────────────────────
  Color get appBorder =>
      isDark ? AppTheme.darkBorder : AppTheme.borderColor;

  // ── Text ────────────────────────────────────────────────────────────────
  Color get appTextPrimary =>
      isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary;

  Color get appTextSecondary =>
      isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary;

  Color get appTextMuted =>
      isDark
          ? AppTheme.darkTextSecondary.withValues(alpha: 0.55)
          : AppTheme.textMuted;

  // ── Card decoration ─────────────────────────────────────────────────────
  BoxDecoration appCardDecoration({double borderRadius = 24}) => BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(borderRadius.r),
        border: Border.all(color: appBorder, width: 1.w),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      );
}
