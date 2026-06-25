import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bepay_interview/core/utils/number_formatter.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/amount_entry/amount_entry_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/bepay_button.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/custom_numeric_keypad.dart';
import 'package:bepay_interview/features/wallet/presentation/widgets/select_token_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AmountEntryScreen extends StatelessWidget {
  const AmountEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendFlowBloc, SendFlowState>(
      listenWhen: (previous, current) =>
          previous.selectedToken != current.selectedToken,
      listener: (context, state) {
        final newToken = state.selectedToken;
        if (newToken != null) {
          context.read<AmountEntryBloc>().add(
            AmountUpdateToken(
              maxBalance: newToken.balance,
              decimals: newToken.decimals,
            ),
          );
        }
      },
      child: BlocBuilder<SendFlowBloc, SendFlowState>(
        builder: (context, sendFlowState) {
          final token = sendFlowState.selectedToken;
          final tokenSymbol = token?.symbol ?? 'USDC';
          final tokenNetwork = token?.network ?? 'Polygon';
          final fiatRate = token?.fiatRate ?? 1.0;

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
                AppStrings.amountEntry,
                style: AppTheme.outfit(
                  color: context.appTextPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Upper Screen Sections
                      Column(
                        children: [
                          SizedBox(height: 8.h),
                          // Header Title (e.g. Send USDC on Polygon)
                          Text(
                            '${AppStrings.send} $tokenSymbol on $tokenNetwork',
                            style: AppTheme.outfit(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: context.appTextPrimary,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),
                          SizedBox(height: 16.h),

                          // Balance selector pill (non-clickable)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: context.isDark ? AppTheme.royalBlue.withValues(alpha: 0.15) : AppTheme.softBlueBg, // Soft Blue
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color:
                                    context.isDark ? AppTheme.royalBlue.withValues(alpha: 0.3) : AppTheme.softBlueBorder, // Soft Blue Border
                                width: 1.w,
                              ),
                            ),
                            child: Text(
                              '${AppStrings.balance}: ${token?.balance ?? 0.0} $tokenSymbol',
                              style: AppTheme.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: context.isDark ? AppTheme.royalBlue : AppTheme.darkBlue, // Darker Blue
                              ),
                            ),
                          ).animate().fadeIn(delay: 50.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                          SizedBox(height: 36.h),

                          // Big Amount and Suffix Display (Targeted Builder)
                          BlocBuilder<AmountEntryBloc, AmountEntryState>(
                            buildWhen: (previous, current) =>
                                previous.amountString != current.amountString ||
                                previous.amount != current.amount,
                            builder: (context, state) {
                              final fiatValue = state.amount * fiatRate;
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        state.amountString,
                                        style: AppTheme.outfit(
                                          fontSize: 44.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.royalBlue,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      GestureDetector(
                                        onTap: () {
                                          SelectTokenBottomSheet.show(
                                            context,
                                            title: AppStrings.selectToken,
                                            onTokenSelected: (selectedToken) {
                                              context.read<SendFlowBloc>().add(
                                                SelectToken(selectedToken),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10.w,
                                            vertical: 4.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appInactiveBg,
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                            border: Border.all(
                                              color: context.appBorder,
                                              width: 1.w,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                tokenSymbol,
                                                style: AppTheme.outfit(
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: context.appTextPrimary,
                                                ),
                                              ),
                                              SizedBox(width: 4.w),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: context.appTextPrimary,
                                                size: 20.w,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  // Fiat rate approximation
                                  Text(
                                    '= ${NumberFormatter.formatCurrency(fiatValue)}',
                                    style: AppTheme.inter(
                                      fontSize: 15.sp,
                                      color:
                                          context.appTextSecondary, // Slate 500
                                    ),
                                  ),
                                ],
                              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95));
                            },
                          ),

                          // Error display if validation fails (Targeted Builder)
                          BlocBuilder<AmountEntryBloc, AmountEntryState>(
                            buildWhen: (previous, current) =>
                                previous.errorMessage != current.errorMessage,
                            builder: (context, state) {
                              if (state.errorMessage == null) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: [
                                  SizedBox(height: 12.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.isDark ? AppTheme.error.withValues(alpha: 0.15) : AppTheme.errorLight, // Light Red
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: context.isDark ? Border.all(color: AppTheme.error.withValues(alpha: 0.3), width: 1.w) : null,
                                    ),
                                    child: Text(
                                      state.errorMessage!,
                                      style: AppTheme.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w500,
                                        color: context.isDark ? AppTheme.error : AppTheme.error, // Red
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      // Lower Screen Layout: Keypad & Continue Action
                      Column(
                        children: [
                          CustomNumericKeypad(
                            onKeyTap: (val) {
                              context.read<AmountEntryBloc>().add(
                                AmountKeyTyped(val),
                              );
                            },
                            onBackspaceTap: () {
                              context.read<AmountEntryBloc>().add(
                                AmountBackspacePressed(),
                              );
                            },
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                          SizedBox(height: 16.h),

                          // Separate MAX button
                          GestureDetector(
                            onTap: () {
                              context.read<AmountEntryBloc>().add(
                                AmountMaxPressed(),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: context.isDark ? AppTheme.royalBlue.withValues(alpha: 0.15) : AppTheme.softBlueBg,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: context.isDark ? AppTheme.royalBlue.withValues(alpha: 0.3) : AppTheme.softBlueBorder,
                                  width: 1.w,
                                ),
                              ),
                              child: Text(
                                '${AppStrings.useMax} (${token?.balance ?? 0.0} $tokenSymbol)',
                                style: AppTheme.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.royalBlue,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                          SizedBox(height: 16.h),

                          // Continue Button (Targeted Builder)
                          BlocBuilder<AmountEntryBloc, AmountEntryState>(
                            builder: (context, state) {
                              return BepayButton(
                                text: AppStrings.continueButton,
                                onPressed:
                                    state.isValid && state.errorMessage == null
                                    ? () {
                                        // Save selected amount into coordinator BLoC state
                                        context.read<SendFlowBloc>().add(
                                          SetAmountAndNote(
                                            amount: state.amount,
                                            note: '',
                                          ),
                                        );
                                        // Navigate to Review Transaction Screen using GoRouter
                                        context.push('/send/review');
                                      }
                                    : null,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
