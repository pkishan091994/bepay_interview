import 'package:bepay_interview/core/constants/app_constants.dart';
import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/recipient_entry/recipient_entry_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/bepay_button.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/external_address_warning.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/recent_recipients_list.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/recipient_input_field.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/recipient_segmented_tabs.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/recipient_type_badge.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/mock_qr_scanner.dart';
import 'package:bepay_interview/features/send_flow/presentation/widgets/mock_contact_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// RecipientEntryScreen displays the revised recipient layout matching the Bepay prototype.
///
/// Features segmented tab switching, context-aware input hints, cautions,
/// vertical list contact cards, and full-width continue actions.
class RecipientEntryScreen extends StatefulWidget {
  const RecipientEntryScreen({super.key});

  @override
  State<RecipientEntryScreen> createState() => _RecipientEntryScreenState();
}

class _RecipientEntryScreenState extends State<RecipientEntryScreen> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read the selected token from the global SendFlow coordinator state
    final sendFlowState = context.read<SendFlowBloc>().state;
    final selectedToken = sendFlowState.selectedToken;
    final tokenSymbol = selectedToken?.symbol ?? 'Crypto';

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
      body: BlocConsumer<RecipientEntryBloc, RecipientEntryState>(
        listener: (context, state) {
          // Sync controller text if modified externally (e.g. from choosing a recent contact card)
          if (state.inputString != _inputController.text) {
            _inputController.text = state.inputString;
            _inputController.selection = TextSelection.fromPosition(
              TextPosition(offset: state.inputString.length),
            );
          }
        },
        builder: (context, state) {
          // Resolve label and hint text depending on the active tab
          String labelText;
          String hintText;

          switch (state.selectedTab) {
            case 0:
              labelText = AppStrings.recipientId;
              hintText = AppStrings.hintBepayId;
              break;
            case 1:
              labelText = AppStrings.walletAddress;
              hintText = AppStrings.hintAddress;
              break;
            default:
              labelText = AppStrings.recipientId;
              hintText = AppStrings.hintBepayId;
          }

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Header Title: "Send USDC" matching prototype screenshot
                              Text(
                                '${AppStrings.send} $tokenSymbol',
                                style: AppTheme.outfit(
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.appTextPrimary,
                                ),
                              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                              SizedBox(height: 6.h),
                              Text(
                                AppStrings.whoToSendTo,
                                style: AppTheme.inter(
                                  fontSize: 14.sp,
                                  color: context.appTextSecondary,
                                ),
                              ).animate().fadeIn(delay: 50.ms, duration: 400.ms).slideX(begin: -0.05, end: 0, curve: Curves.easeOutQuad),
                              SizedBox(height: 24.h),

                              // Segmented tab bar switcher widget
                              RecipientSegmentedTabs(
                                selectedTab: state.selectedTab,
                                onTabChanged: (index) {
                                  context.read<RecipientEntryBloc>().add(
                                    RecipientTabChanged(index),
                                  );
                                },
                              ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                              SizedBox(height: 24.h),

                              // Custom error-handling input field widget
                              RecipientInputField(
                                controller: _inputController,
                                errorText: state.errorMessage,
                                isValid: state.isValid,
                                hintText: hintText,
                                labelText: labelText,
                                suffixAction: state.selectedTab == 0
                                    ? IconButton(
                                        icon: Icon(
                                          Icons.contacts_rounded,
                                          color: AppTheme.royalBlue,
                                          size: 20.w,
                                        ),
                                        onPressed: () async {
                                          final result = await MockContactPicker.show(context);
                                          if (result != null && context.mounted) {
                                            context.read<RecipientEntryBloc>().add(
                                              RecipientInputChanged(result),
                                            );
                                          }
                                        },
                                      )
                                    : IconButton(
                                        icon: Icon(
                                          Icons.qr_code_scanner_rounded,
                                          color: AppTheme.royalBlue,
                                          size: 20.w,
                                        ),
                                        onPressed: () async {
                                          final result = await MockQrScanner.show(context);
                                          if (result != null && context.mounted) {
                                            context.read<RecipientEntryBloc>().add(
                                              RecipientInputChanged(result),
                                            );
                                          }
                                        },
                                      ),
                                onChanged: (value) {
                                  context.read<RecipientEntryBloc>().add(
                                    RecipientInputChanged(value),
                                  );
                                },
                              ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                              SizedBox(height: 16.h),

                              // Destination badges and warnings (only shown when input format checks pass)
                              if (state.isValid && state.recipient != null) ...[
                                Row(
                                  children: [
                                    Text(
                                      AppStrings.destinationLabel,
                                      style: AppTheme.inter(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: context.appTextSecondary,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    RecipientTypeBadge(
                                      type: state.recipient!.type,
                                    ),
                                  ],
                                ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.95, 0.95)),
                                SizedBox(height: 12.h),
                                ExternalAddressWarning(
                                  isExternal: state.recipient!.isExternal,
                                ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.95, 0.95)),
                                SizedBox(height: 24.h),
                              ],

                              // Vertical list contact cards (matching Jordan, Sarah, Marcus in screenshot)
                              if (state.isLoadingRecipients || state.recentRecipients.isNotEmpty) ...[
                                RecentRecipientsList(
                                  recipients: state.recentRecipients,
                                  isLoading: state.isLoadingRecipients,
                                  onSelect: (recipient) {
                                    context.read<RecipientEntryBloc>().add(
                                      SelectRecentRecipient(recipient),
                                    );
                                  },
                                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                              ],
                            ],
                          ),

                          // Full width blue Continue button with trailing arrow icon
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: BepayButton(
                              text: AppStrings.continueButton,
                              icon: Icons.arrow_forward_rounded,
                              onPressed:
                                  state.isValid && state.recipient != null
                                  ? () {
                                      // Save verified recipient details to global send flow
                                      context.read<SendFlowBloc>().add(
                                        SetRecipient(state.recipient!),
                                      );

                                      // Navigate to Amount Entry Screen using GoRouter
                                      context.push('/send/amount');
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
