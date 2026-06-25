import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum BepayButtonType { primary, secondary, outlined }

class BepayButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final BepayButtonType type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const BepayButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = BepayButtonType.primary,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null && !isLoading;

    switch (type) {
      case BepayButtonType.primary:
        return SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: isEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppTheme.royalBlue,
              foregroundColor: textColor ?? Colors.white,
              disabledBackgroundColor: context.appInactiveBg,
              disabledForegroundColor: context.appTextMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: textColor ?? Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : _buildButtonContent(defaultTextColor: Colors.white),
          ),
        );
      case BepayButtonType.secondary:
      case BepayButtonType.outlined:
        return SizedBox(
          width: double.infinity,
          height: 50.h,
          child: OutlinedButton(
            onPressed: isEnabled ? onPressed : null,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor ?? context.appInactiveBg,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      color: textColor ?? context.appTextSecondary,
                      strokeWidth: 2.5,
                    ),
                  )
                : _buildButtonContent(defaultTextColor: context.appTextSecondary),
          ),
        );
    }
  }

  Widget _buildButtonContent({Color? defaultTextColor}) {
    final style = AppTheme.inter(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: textColor ?? defaultTextColor,
    );

    final Widget content;
    if (icon != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(text, style: style, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 8.w),
          Icon(
            icon,
            color: textColor ?? defaultTextColor ?? Colors.white,
            size: 18.w,
          ),
        ],
      );
    } else {
      content = Text(text, style: style, overflow: TextOverflow.ellipsis);
    }

    return FittedBox(fit: BoxFit.scaleDown, child: content);
  }
}
