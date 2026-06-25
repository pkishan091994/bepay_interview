import 'dart:async';
import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/pin_confirmation/pin_confirmation_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/bepay_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

class PinConfirmationScreen extends StatefulWidget {
  const PinConfirmationScreen({super.key});

  @override
  State<PinConfirmationScreen> createState() => _PinConfirmationScreenState();
}

class _PinConfirmationScreenState extends State<PinConfirmationScreen> {
  Timer? _timer;

  void _startTimer(BuildContext context) {
    if (_timer != null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        context.read<PinConfirmationBloc>().add(PinLockTimerTicked());
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read parameters from global coordinator bloc
    final sendFlowState = context.read<SendFlowBloc>().state;
    final token = sendFlowState.selectedToken;
    final recipient = sendFlowState.recipient;
    final amount = sendFlowState.amount;

    final tokenSymbol = token?.symbol ?? 'USDC';
    final recipientAddress = recipient?.address ?? '';

    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        elevation: 0,
        leading: BlocBuilder<PinConfirmationBloc, PinConfirmationState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: context.appTextPrimary,
                size: 22.w,
              ),
              onPressed: state.isSubmitting || state.isLocked
                  ? null
                  : () {
                      context.pop();
                    },
            );
          },
        ),
        title: Text(
          AppStrings.bepayLogo,
          style: AppTheme.outfit(
            color: AppTheme.royalBlue,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
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
            ),
          ),
        ],
      ),
      body: BlocConsumer<PinConfirmationBloc, PinConfirmationState>(
        listener: (context, state) {
          if (state.toastMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.toastMessage!),
                backgroundColor: AppTheme.royalBlue,
              ),
            );
          }
          if (state.isSuccess) {
            context.go('/send/success');
          }
          if (state.isLocked) {
            _startTimer(context);
          } else {
            _stopTimer();
          }
        },
        builder: (context, state) {
          final displayError = state.isLocked
              ? 'Too many incorrect attempts. Locked for ${state.lockSecondsRemaining}s.'
              : state.errorMessage;

          return PopScope(
            canPop: !state.isSubmitting && !state.isLocked,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header description and DOT Indicators
                            Column(
                              children: [
                                SizedBox(height: 24.h),
                                Text(
                                  AppStrings.confirmWithPin,
                                  style: AppTheme.outfit(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.appTextPrimary,
                                  ),
                                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),
                                SizedBox(height: 8.h),
                                Text(
                                  AppStrings.enter4DigitPin,
                                  style: AppTheme.inter(
                                    fontSize: 14.sp,
                                    color: context.appTextSecondary,
                                  ),
                                ).animate().fadeIn(delay: 50.ms, duration: 400.ms).slideY(begin: -0.1, end: 0, curve: Curves.easeOutQuad),
                                SizedBox(height: 36.h),

                                // Pin Dots indicator row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (index) {
                                    final hasDigit = index < state.pin.length;
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                      ),
                                      width: 16.w,
                                      height: 16.w,
                                      decoration: BoxDecoration(
                                        color: hasDigit
                                            ? AppTheme.royalBlue
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: hasDigit
                                              ? AppTheme.royalBlue
                                              : context.appBorder,
                                          width: 2.w,
                                        ),
                                      ),
                                    );
                                  }),
                                ).animate().fadeIn(delay: 100.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),

                                // Error message output
                                if (displayError != null) ...[
                                  SizedBox(height: 16.h),
                                  Text(
                                    displayError,
                                    style: AppTheme.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.error,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),

                            // Bottom Keypad & Verify button layout
                            Column(
                              children: [
                                // Keypad Container card
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.h,
                                    horizontal: 16.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.appSurface,
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(color: context.appBorder),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          _buildDigitKey(
                                            context,
                                            '1',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildDigitKey(
                                            context,
                                            '2',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildDigitKey(
                                            context,
                                            '3',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Row(
                                        children: [
                                          _buildDigitKey(
                                            context,
                                            '4',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildDigitKey(
                                            context,
                                            '5',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildDigitKey(
                                            context,
                                            '6',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Row(
                                        children: [
                                          _buildDigitKey(
                                            context,
                                            '7',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildDigitKey(
                                            context,
                                            '8',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildDigitKey(
                                            context,
                                            '9',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Row(
                                        children: [
                                          _buildBiometricKey(
                                            context,
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildDigitKey(
                                            context,
                                            '0',
                                            tokenSymbol,
                                            recipientAddress,
                                            amount,
                                            state,
                                          ),
                                          _buildBackspaceKey(context, state),
                                        ],
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                                SizedBox(height: 24.h),

                                // Verify action button
                                BepayButton(
                                  text: AppStrings.verify,
                                  isLoading: state.isSubmitting,
                                  icon: Icons.lock_outline_rounded,
                                  onPressed: state.pin.length == 4 &&
                                          !state.isSubmitting &&
                                          !state.isLocked
                                      ? () {
                                          context
                                              .read<PinConfirmationBloc>()
                                              .add(
                                                PinSubmit(
                                                  tokenSymbol: tokenSymbol,
                                                  recipientAddress:
                                                      recipientAddress,
                                                  amount: amount,
                                                ),
                                              );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDigitKey(
    BuildContext context,
    String digit,
    String tokenSymbol,
    String recipientAddress,
    double amount,
    PinConfirmationState state,
  ) {
    final bool isDisabled = state.isLocked || state.isSubmitting || state.pin.length >= 4;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.6,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  context.read<PinConfirmationBloc>().add(
                    PinDigitEntered(
                      digit: digit,
                      tokenSymbol: tokenSymbol,
                      recipientAddress: recipientAddress,
                      amount: amount,
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(16.r),
          highlightColor: AppTheme.royalBlue.withValues(alpha: 0.05),
          splashColor: AppTheme.royalBlue.withValues(alpha: 0.1),
          child: Center(
            child: Text(
              digit,
              style: AppTheme.outfit(
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
                color: isDisabled ? context.appTextMuted : context.appTextPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey(BuildContext context, PinConfirmationState state) {
    final bool isDisabled = state.isLocked || state.isSubmitting || state.pin.isEmpty;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.6,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  context.read<PinConfirmationBloc>().add(
                    PinBackspacePressed(),
                  );
                },
          borderRadius: BorderRadius.circular(16.r),
          highlightColor: AppTheme.error.withValues(alpha: 0.05),
          splashColor: AppTheme.error.withValues(alpha: 0.1),
          child: Center(
            child: Icon(
              Icons.backspace_outlined,
              color: isDisabled ? context.appTextMuted : context.appTextPrimary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricKey(
    BuildContext context,
    String tokenSymbol,
    String recipientAddress,
    double amount,
    PinConfirmationState state,
  ) {
    final bool isDisabled = state.isLocked || state.isSubmitting;
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.6,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  context.read<PinConfirmationBloc>().add(
                    PinBiometricTapped(
                      tokenSymbol: tokenSymbol,
                      recipientAddress: recipientAddress,
                      amount: amount,
                    ),
                  );
                },
          borderRadius: BorderRadius.circular(16.r),
          highlightColor: AppTheme.royalBlue.withValues(alpha: 0.05),
          splashColor: AppTheme.royalBlue.withValues(alpha: 0.1),
          child: Center(
            child: Icon(
              Icons.fingerprint_rounded,
              color: isDisabled ? context.appTextMuted : AppTheme.royalBlue,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
