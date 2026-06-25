import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';

/// A customized text form input for Bepay recipient identifiers.
///
/// Styled with clean, rounded corners and dynamic validation feedback.
class RecipientInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final bool isValid;
  final String hintText;
  final String labelText;
  final Widget? suffixAction;

  const RecipientInputField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.errorText,
    this.isValid = false,
    required this.hintText,
    required this.labelText,
    this.suffixAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input label above the field
        Text(
          labelText,
          style: AppTheme.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: context.appTextSecondary,
          ),
        ),
        SizedBox(height: 8.h),
        // Input container matching screenshots (clean, elevated, rounded corners)
        Container(
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: hasError
                  ? AppTheme
                        .errorRed // Red error border matching screenshot
                  : isValid
                  ? AppTheme
                        .royalBlue // Blue active border
                  : context.appBorder,
              width: 1.5.w,
            ),
          ),
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            style: AppTheme.inter(
              fontSize: 15.sp,
              color: context.appTextPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTheme.inter(
                fontSize: 14.sp,
                color: context.appTextMuted,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              border: InputBorder.none,
              // Suffix validation / status indicators
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Suffix action when empty
                  if (controller.text.isEmpty && suffixAction != null)
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: suffixAction!,
                    ),
                  // Clear button: shows up only when there is input
                  if (controller.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: context.appTextMuted,
                        size: 18.w,
                      ),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
                  // Validation status indicator
                  if (isValid)
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.royalBlue, // Blue validation checkmark
                      ),
                    ),
                  if (hasError)
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme
                            .errorRed, // Red error warning icon matching screenshot
                      ),
                    ),
                ],
              ),
            ),
            keyboardType: TextInputType.text,
            autocorrect: false,
            enableSuggestions: false,
          ),
        ),
        // Error helper text
        if (hasError) ...[
          SizedBox(height: 6.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              errorText!,
              style: AppTheme.inter(
                fontSize: 12.sp,
                color: AppTheme.errorRed, // Red text matching screenshot
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
