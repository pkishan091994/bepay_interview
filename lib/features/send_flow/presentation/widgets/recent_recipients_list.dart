import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A vertical list of recent recipients styled like the Bepay prototype card layout.
///
/// Features circular avatars (or initials for placeholders), names,
/// address handles, custom badges (e.g., LAST USED), and timestamps.
/// Shows shimmer placeholders when [isLoading] is set to true.
class RecentRecipientsList extends StatelessWidget {
  final List<Recipient> recipients;
  final ValueChanged<Recipient> onSelect;
  final bool isLoading;

  const RecentRecipientsList({
    super.key,
    required this.recipients,
    required this.onSelect,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildShimmerList(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List Header with Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.recentRecipients,
              style: AppTheme.outfit(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: context.appTextPrimary,
              ),
            ),
            const SizedBox(),
          ],
        ),
        SizedBox(height: 12.h),
        // Vertical List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipients.length,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final contact = recipients[index];
            return _buildContactCard(context, contact);
          },
        ),
      ],
    );
  }

  // Shimmer List placeholder
  Widget _buildShimmerList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 140.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: context.appInactiveBg,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            return _buildShimmerCard(context);
          },
        ),
      ],
    );
  }

  // Shimmer Card placeholder
  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: context.appCardDecoration(),
      child: Row(
        children: [
          // Circular Avatar Placeholder
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: context.appInactiveBg,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),
          // Contact Details Placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: context.appInactiveBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 140.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: context.appInactiveBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vertical card widget matching the prototype screenshots
  Widget _buildContactCard(BuildContext context, Recipient contact) {
    // Generate initials if no image is available
    final nameParts = contact.name.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : nameParts[0]
              .substring(0, nameParts[0].length >= 2 ? 2 : 1)
              .toUpperCase();

    // Select profile picture URLs or use initials avatar
    String? imageUrl;
    if (contact.name == 'Sarah Chen') {
      imageUrl = 'https://api.dicebear.com/7.x/adventurer/png?seed=Sarah';
    } else if (contact.name == 'Marcus Wu') {
      imageUrl = 'https://api.dicebear.com/7.x/adventurer/png?seed=Marcus';
    }

    return GestureDetector(
      onTap: () => onSelect(contact),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: context.appCardDecoration(),
        child: Row(
          children: [
            // Circular Avatar or Initials
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialsAvatar(initials),
                      )
                    : _buildInitialsAvatar(initials),
              ),
            ),
            SizedBox(width: 14.w),
            // Contact Details (Name, address handle, badge)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact.name,
                        style: AppTheme.outfit(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: context.appTextPrimary,
                        ),
                      ),
                      if (contact.badge != null) ...[
                        SizedBox(width: 8.w),
                        _buildBadge(context, contact.badge!),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    contact.address,
                    style: AppTheme.inter(
                      fontSize: 12.sp,
                      color: context.appTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Timestamp on the right
            if (contact.timestamp != null)
              Text(
                contact.timestamp!,
                style: AppTheme.inter(
                  fontSize: 11.sp,
                  color: context.appTextMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Fallback / initials avatar (purple matching Jordan Doe in screenshot)
  Widget _buildInitialsAvatar(String initials) {
    return Container(
      color: AppTheme.violet, // Purple violet color matching screenshot
      child: Center(
        child: Text(
          initials,
          style: AppTheme.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Badge tag (like "LAST USED" in screenshot)
  Widget _buildBadge(BuildContext context, String label) {
    final isDark = context.isDark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.royalBlue.withValues(alpha: 0.15)
            : AppTheme.softBlueBg, // Soft light-blue background
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: AppTheme.inter(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: AppTheme.royalBlue, // Bepay blue text
        ),
      ),
    );
  }
}
