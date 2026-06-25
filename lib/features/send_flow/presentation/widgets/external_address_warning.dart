import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A banner displaying caution/info messages based on the recipient destination.
///
/// Warning (Amber): Shown when sending to an external blockchain address (gas fees warning).
/// Info (Green): Shown when sending to an internal Bepay user (zero fee transfer alert).
class ExternalAddressWarning extends StatelessWidget {
  final bool isExternal;

  const ExternalAddressWarning({super.key, required this.isExternal});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    if (isExternal) {
      // Amber Warning Banner for External Blockchain destinations
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.warning.withValues(alpha: 0.15) : AppTheme.warningLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppTheme.warning.withValues(alpha: 0.3) : AppTheme.warningBorder,
            width: 1.w,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: isDark ? AppTheme.warning : AppTheme.warningIcon,
              size: 20.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                AppStrings.warningExternalCaution,
                style: AppTheme.inter(
                  fontSize: 12.sp,
                  color: isDark ? AppTheme.warning : AppTheme.warningTextDark,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Green Info Banner for Internal Bepay transfers (Zero Fees)
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.success.withValues(alpha: 0.15) : AppTheme.successLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppTheme.success.withValues(alpha: 0.3) : AppTheme.successBorder,
            width: 1.w,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: isDark ? AppTheme.success : AppTheme.successIcon,
              size: 20.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                AppStrings.infoInternalSuccess,
                style: AppTheme.inter(
                  fontSize: 12.sp,
                  color: isDark ? AppTheme.success : AppTheme.successTextDark,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
