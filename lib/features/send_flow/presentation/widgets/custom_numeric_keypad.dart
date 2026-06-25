import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';

class CustomNumericKeypad extends StatelessWidget {
  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspaceTap;

  const CustomNumericKeypad({
    super.key,
    required this.onKeyTap,
    required this.onBackspaceTap,
  });

  @override
  Widget build(BuildContext context) {
    // Styling constants
    final keyStyle = AppTheme.outfit(
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
      color: context.appTextPrimary,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: context.appBackground,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildKey('1', keyStyle),
              _buildKey('2', keyStyle),
              _buildKey('3', keyStyle),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildKey('4', keyStyle),
              _buildKey('5', keyStyle),
              _buildKey('6', keyStyle),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildKey('7', keyStyle),
              _buildKey('8', keyStyle),
              _buildKey('9', keyStyle),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildKey('.', keyStyle),
              _buildKey('0', keyStyle),
              _buildBackspaceKey(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value, TextStyle style) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: InkWell(
          onTap: () => onKeyTap(value),
          borderRadius: BorderRadius.circular(16.r),
          highlightColor: AppTheme.royalBlue.withValues(alpha: 0.05),
          splashColor: AppTheme.royalBlue.withValues(alpha: 0.1),
          child: Center(child: Text(value, style: style)),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: InkWell(
          onTap: onBackspaceTap,
          borderRadius: BorderRadius.circular(16.r),
          highlightColor: AppTheme.error.withValues(alpha: 0.05),
          splashColor: AppTheme.error.withValues(alpha: 0.1),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: context.appTextPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
