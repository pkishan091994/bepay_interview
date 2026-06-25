import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';

/// A badge that displays the detected type of a valid recipient.
///
/// Categorizes EVM addresses, BepayIDs, emails, and phone numbers
/// into clean, distinct color pills.
class RecipientTypeBadge extends StatelessWidget {
  final RecipientType type;

  const RecipientTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    String label;
    Color bgColor;
    Color textColor;

    switch (type) {
      case RecipientType.address:
        label = AppStrings.blockchainAddressBadge;
        bgColor = context.appInactiveBg; // Muted Slate Grey
        textColor = context.appTextSecondary;
        break;
      case RecipientType.bepayId:
        label = AppStrings.bepayIdBadge;
        bgColor = isDark ? AppTheme.royalBlue.withValues(alpha: 0.15) : AppTheme.softBlueBg; // Soft blue
        textColor = AppTheme.royalBlue;
        break;
      case RecipientType.email:
        label = AppStrings.emailAddressBadge;
        bgColor = isDark ? AppTheme.solPurple.withValues(alpha: 0.15) : AppTheme.solPurpleBg; // Soft purple
        textColor = AppTheme.solPurple;
        break;
      case RecipientType.phone:
        label = AppStrings.phoneNumberBadge;
        bgColor = isDark ? AppTheme.usdtGreen.withValues(alpha: 0.15) : AppTheme.usdtGreenBg; // Soft green
        textColor = AppTheme.usdtGreen;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: AppTheme.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
