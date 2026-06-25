import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/bepay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sendFlowState = context.read<SendFlowBloc>().state;
    final token = sendFlowState.selectedToken;
    final recipient = sendFlowState.recipient;
    final amount = sendFlowState.amount;

    final tokenSymbol = token?.symbol ?? 'USDC';
    final tokenNetwork = token?.network ?? 'Polygon';

    const mockTxId = 'tx_123456789';
    const fee = 0.02;

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.bepayLogo,
          style: AppTheme.outfit(
            color: AppTheme.royalBlue,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Main circular status and text description
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Premium nested shadow circular check icon
                          Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              color: context.isDark ? AppTheme.royalBlue.withValues(alpha: 0.15) : AppTheme.softBlueBg, // Soft Blue
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.royalBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              width: 80.w,
                              height: 80.w,
                              decoration: BoxDecoration(
                                color:
                                    context.isDark ? AppTheme.royalBlue.withValues(alpha: 0.3) : AppTheme.softBlueBorder, // Medium Soft Blue
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.royalBlue.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 16,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.royalBlue, // Royal Bepay Blue
                                size: 54.w,
                              ),
                            ),
                          ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut).rotate(begin: -0.15, end: 0, duration: 800.ms),
                          SizedBox(height: 32.h),

                          // Success announcement header
                          Text(
                            AppStrings.transactionSuccessful,
                            style: AppTheme.outfit(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: context.appTextPrimary,
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                          SizedBox(height: 8.h),

                          // Transfer recap text
                          Text(
                            '${amount.toStringAsFixed(2)} $tokenSymbol ${AppStrings.sentTo} ${recipient?.address ?? AppStrings.fallbackRecipientBepayId}',
                            textAlign: TextAlign.center,
                            style: AppTheme.inter(
                              fontSize: 14.sp,
                              color: context.appTextSecondary,
                              height: 1.4,
                            ),
                          ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                          SizedBox(height: 36.h),

                          // Detailed breakdown Card
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: context.appSurface,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: context.appBorder),
                            ),
                            child: Column(
                              children: [
                                // Network Name Row
                                _buildReceiptRow(
                                  context: context,
                                  label: AppStrings.network,
                                  valueWidget: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 20.w,
                                        height: 20.w,
                                        decoration: const BoxDecoration(
                                          color: AppTheme
                                              .polygonPurple, // Polygon Purple
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          tokenNetwork.isNotEmpty
                                              ? tokenNetwork[0]
                                              : 'N',
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
                                Divider(
                                  height: 24.h,
                                  color: context.appBorder,
                                ),

                                // Transaction ID row (with copy helper)
                                _buildReceiptRow(
                                  context: context,
                                  label: AppStrings.transactionId,
                                  valueWidget: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          mockTxId,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: context.appTextSecondary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(
                                            const ClipboardData(text: mockTxId),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                AppStrings.detailsCopied,
                                              ),
                                              backgroundColor:
                                                  AppTheme.royalBlue,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(
                                          4.r,
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(4.w),
                                          child: Icon(
                                            Icons.content_copy_rounded,
                                            color: AppTheme.royalBlue,
                                            size: 16.w,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 24.h,
                                  color: context.appBorder,
                                ),

                                // Transfer Fee row
                                _buildReceiptRow(
                                  context: context,
                                  label: AppStrings.fee,
                                  valueWidget: Text(
                                    '${fee.toStringAsFixed(2)} $tokenSymbol',
                                    style: AppTheme.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: context.appTextSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Bottom home and details button navigations
                      Column(
                        children: [
                          BepayButton(
                            text: AppStrings.viewDetails,
                            onPressed: () {
                              // Open details alert dialog
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    AppStrings.transactionDetailsTitle,
                                  ),
                                  content: Text(
                                    'Token: $tokenSymbol\nNetwork: $tokenNetwork\nTo: ${recipient?.address}\nAmount: $amount\nFee: $fee $tokenSymbol\nTX: $mockTxId',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text(AppStrings.closeButton),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          BepayButton(
                            text: AppStrings.backToHome,
                            type: BepayButtonType
                                .secondary, // Gray background style
                            onPressed: () {
                              // Reset global send flow state and navigate back to WalletHomeScreen using GoRouter
                              context.read<SendFlowBloc>().add(ResetFlow());
                              context.go('/');
                            },
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReceiptRow({
    required BuildContext context,
    required String label,
    required Widget valueWidget,
  }) {
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
