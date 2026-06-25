import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/bepay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

class ReviewTransactionScreen extends StatefulWidget {
  const ReviewTransactionScreen({super.key});

  @override
  State<ReviewTransactionScreen> createState() =>
      _ReviewTransactionScreenState();
}

class _ReviewTransactionScreenState extends State<ReviewTransactionScreen> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final initialNote = context.read<SendFlowBloc>().state.note;
    _noteController = TextEditingController(text: initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendFlowState = context.watch<SendFlowBloc>().state;
    final token = sendFlowState.selectedToken;
    final recipient = sendFlowState.recipient;
    final amount = sendFlowState.amount;
    final isLoadingFee = sendFlowState.isLoadingFee;
    final estimatedFee = sendFlowState.estimatedFee ?? 0.02;

    final tokenSymbol = token?.symbol ?? 'USDC';
    final tokenNetwork = token?.network ?? 'Polygon';

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: context.appTextPrimary,
            size: 22.w,
          ),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          AppStrings.reviewTransaction,
          style: AppTheme.outfit(
            color: context.appTextPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              radius: 19.r,
              backgroundColor: context.appBorder,
              backgroundImage: const NetworkImage(AppConstants.avatarURL),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Amount Display Card (with blue-violet gradient)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: 24.h,
                    horizontal: 20.w,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.royalBlue, // Bright blue
                        AppTheme.violet, // Violet
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkIndigo.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.sendingAmount,
                        style: AppTheme.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '${amount.toStringAsFixed(2)} $tokenSymbol',
                        style: AppTheme.outfit(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Recipient handle badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: AppTheme.royalBlue,
                              size: 14.w,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                recipient?.address ??
                                    AppStrings.fallbackRecipientBepayId,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppTheme.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.royalBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuad),
                SizedBox(height: 24.h),

                // 2. Transaction details breakdown card
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: context.appBorder),
                  ),
                  child: Column(
                    children: [
                      // Network row
                      _buildDetailRow(
                        label: AppStrings.network,
                        valueWidget: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 20.w,
                              height: 20.w,
                              decoration: const BoxDecoration(
                                color: AppTheme.polygonPurple,
                                // Purple color representing Polygon
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                tokenNetwork.isNotEmpty ? tokenNetwork[0] : 'N',
                                style: AppTheme.outfit(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Flexible(
                              child: Text(
                                tokenNetwork,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: context.appTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                       Divider(height: 24.h, color: context.appBorder),

                      // Fee row
                      _buildDetailRow(
                        label: AppStrings.estimatedFee,
                        valueWidget: isLoadingFee
                            ? SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white70,
                                  ),
                                ),
                              )
                            : Text(
                                '${estimatedFee.toStringAsFixed(2)} $tokenSymbol',
                                style: AppTheme.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: context.appTextSecondary,
                                ),
                              ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 12.w,
                              color: context.appTextMuted,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                'Network fee paid using $tokenSymbol',
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: context.appTextMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 24.h, color: context.appBorder),

                      // Total to Deduct row
                      _buildDetailRow(
                        label: AppStrings.totalToDeduct,
                        valueWidget: isLoadingFee
                            ? SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.royalBlue,
                                  ),
                                ),
                              )
                            : Text(
                                '${(amount + estimatedFee).toStringAsFixed(2)} $tokenSymbol',
                                style: AppTheme.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme
                                      .royalBlue, // Blue color matching mockup
                                ),
                              ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: 20.h),

                // 3. Optional note input
                Text(
                  AppStrings.optionalNote,
                  style: AppTheme.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: context.appTextSecondary,
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: 8.h),
                TextField(
                  controller: _noteController,
                  maxLines: 1,
                  style: AppTheme.inter(
                    fontSize: 14.sp,
                    color: context.appTextPrimary,
                  ),
                  onChanged: (val) {
                    context.read<SendFlowBloc>().add(UpdateNote(val));
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.noteHint,
                    hintStyle: AppTheme.inter(color: context.appTextMuted),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    filled: true,
                    fillColor: context.appBackground,
                    suffixIcon: Icon(
                      Icons.edit_note_rounded,
                      color: context.appTextSecondary,
                      size: 22.w,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: context.appBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: context.appBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppTheme.royalBlue),
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: 20.h),

                // 4. Warning notification banner
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: context.isDark ? AppTheme.error.withValues(alpha: 0.15) : AppTheme.errorLight, // Light Red
                    border: Border.all(
                      color: context.isDark ? AppTheme.error.withValues(alpha: 0.3) : AppTheme.errorBorder,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.error,
                        size: 18.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          AppStrings.warningReverse,
                          style: AppTheme.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: context.isDark ? AppTheme.error : AppTheme.errorTextDark, // Dark Red text
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutQuad),
                SizedBox(height: 32.h),

                // 5. Actions: Confirm & Edit
                Column(
                  children: [
                    BepayButton(
                      text: AppStrings.confirmTransaction,
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: () {
                        // Navigate to PIN Confirmation Screen using GoRouter
                        context.push('/send/pin');
                      },
                    ),
                    SizedBox(height: 12.h),
                    BepayButton(
                      text: AppStrings.edit,
                      type: BepayButtonType.secondary,
                      // Secondary borderless style matching mockup
                      onPressed: () {
                        // Pop back to edit amount using GoRouter
                        context.pop();
                      },
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required Widget valueWidget}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: context.appTextSecondary,
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(child: valueWidget),
      ],
    );
  }
}
