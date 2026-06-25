import 'package:bepay_interview/core/constants/app_constants.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/// A premium side-drawer for the Bepay home screen.
///
/// Contains:
/// - Profile header with mocked avatar, name, email, and a verified badge
/// - Quick navigation items (Home, Wallet, Send)
/// - Dark Mode toggle switch with smooth animated indicator
/// - App version footer
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // ── Mock profile data ─────────────────────────────────────────────────────
  static const _userName = 'Kishan Patel';
  static const _userEmail = 'kishanpatel@gmail.com';
  static const _appVersion = 'v1.0.0 · Interview Build';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeNotifier = context.watch<ThemeNotifier>();

    // Adaptive colours
    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final textPrimary = isDark
        ? AppTheme.darkTextPrimary
        : AppTheme.textPrimary;
    final textSecondary = isDark
        ? AppTheme.darkTextSecondary
        : AppTheme.textSecondary;
    final dividerColor = isDark ? AppTheme.darkBorder : AppTheme.borderColor;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // ── Profile Header ───────────────────────────────────────────────
            _ProfileHeader(
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),

            Divider(color: dividerColor, height: 1),
            SizedBox(height: 8.h),

            // ── Dark Mode Toggle ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkInactiveBg : AppTheme.inactiveBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  leading: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      themeNotifier.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      key: ValueKey(themeNotifier.isDarkMode),
                      color: themeNotifier.isDarkMode
                          ? const Color(0xFF818CF8) // indigo-400
                          : AppTheme.warning,
                      size: 22.w,
                    ),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: AppTheme.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    themeNotifier.isDarkMode ? 'On' : 'Off',
                    style: AppTheme.inter(
                      fontSize: 11.sp,
                      color: textSecondary,
                    ),
                  ),
                  trailing: _AnimatedToggle(
                    value: themeNotifier.isDarkMode,
                    onChanged: (_) => themeNotifier.toggleTheme(),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── Footer ───────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Text(
                _appVersion,
                style: AppTheme.inter(fontSize: 10.sp, color: textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Header
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.royalBlue, AppTheme.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with gradient ring
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 2.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                AppConstants.avatarURL,
                fit: BoxFit.cover,
                errorBuilder: (context, _, stackTrace) => CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    'KP',
                    style: AppTheme.outfit(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Name + verified badge
          Row(
            children: [
              Text(
                AppDrawer._userName,
                style: AppTheme.outfit(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 9.w,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Verified',
                      style: AppTheme.inter(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Email
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: Colors.white.withValues(alpha: 0.75),
                size: 13.w,
              ),
              SizedBox(width: 5.w),
              Text(
                AppDrawer._userEmail,
                style: AppTheme.inter(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Toggle (custom pill switch)
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedToggle extends StatelessWidget {
  const _AnimatedToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48.w,
        height: 26.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13.r),
          color: value
              ? AppTheme.royalBlue
              : AppTheme.textMuted.withValues(alpha: 0.35),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
