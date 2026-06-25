import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';

/// A segmented tab control selector for switching recipient input formats.
///
/// Highlights the active tab with a white pill container and blue text,
/// while keeping inactive tabs styled in muted grey.
class RecipientSegmentedTabs extends StatelessWidget {
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  const RecipientSegmentedTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [AppStrings.bepayIdTab, AppStrings.walletAddressTab];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: context.appInactiveBg, // Light grey background pill (Slate 100)
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final label = tabs[index];
          final isActive = selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: isActive ? context.appSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.inter(
                    fontSize: 12.sp,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive
                        ? AppTheme
                              .royalBlue // Blue for active tab
                        : context.appTextSecondary, // Muted grey for inactive tab
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
