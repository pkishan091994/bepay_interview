import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:bepay_interview/core/utils/number_formatter.dart';
import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';
import 'package:bepay_interview/features/wallet/presentation/bloc/wallet_bloc.dart';

class SelectTokenBottomSheet extends StatefulWidget {
  final Function(TokenBalance) onTokenSelected;
  final String title;

  const SelectTokenBottomSheet({
    super.key,
    required this.onTokenSelected,
    this.title = AppStrings.selectToken,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(TokenBalance) onTokenSelected,
    String title = AppStrings.selectToken,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SelectTokenBottomSheet(
        onTokenSelected: onTokenSelected,
        title: title,
      ),
    );
  }

  @override
  State<SelectTokenBottomSheet> createState() => _SelectTokenBottomSheetState();
}

class _SelectTokenBottomSheetState extends State<SelectTokenBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            SizedBox(height: 12.h),
            // Drag Handle
            Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.appBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            // Header Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: AppTheme.outfit(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: context.appTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.appTextPrimary,
                      size: 24.w,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            // Search Input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                decoration: BoxDecoration(
                  color: context.appInactiveBg,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                  style: AppTheme.inter(
                    fontSize: 14.sp,
                    color: context.appTextPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: context.appTextMuted,
                      size: 20.w,
                    ),
                    hintText: AppStrings.searchTokenOrName,
                    hintStyle: AppTheme.inter(
                      fontSize: 14.sp,
                      color: context.appTextMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // Scrollable Content
            Expanded(
              child: BlocBuilder<WalletBloc, WalletState>(
                builder: (context, state) {
                  if (state is WalletLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is WalletLoaded) {
                    final tokens = List<TokenBalance>.from(state.balances);

                    // Filter all assets
                    final filteredTokens = tokens.where((t) {
                      return t.symbol.toLowerCase().contains(_searchQuery) ||
                          t.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    // Find recently used tokens (USDC, ETH, SOL) in the loaded assets
                    final recentSymbols = ['USDC', 'ETH', 'SOL'];
                    final recentTokens = <TokenBalance>[];
                    for (final sym in recentSymbols) {
                      TokenBalance? found;
                      for (final t in tokens) {
                        if (t.symbol == sym) {
                          found = t;
                          break;
                        }
                      }
                      if (found != null) {
                        recentTokens.add(found);
                      } else if (tokens.isNotEmpty) {
                        recentTokens.add(tokens.first);
                      }
                    }

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recently Used Section (only show if search query is empty)
                          if (_searchQuery.isEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                AppStrings.recentlyUsed,
                                style: AppTheme.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: context.appTextMuted,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 80.h,
                              child: ListView.separated(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                scrollDirection: Axis.horizontal,
                                itemCount: recentTokens.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: 20.w),
                                itemBuilder: (context, index) {
                                  final token = recentTokens[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      widget.onTokenSelected(token);
                                    },
                                    child: Column(
                                      children: [
                                        _buildCircularTokenIcon(token.symbol),
                                        SizedBox(height: 8.h),
                                        Text(
                                          token.symbol,
                                          style: AppTheme.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: context.appTextSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                          // All Assets Section
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              AppStrings.allAssets,
                              style: AppTheme.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: context.appTextMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: filteredTokens.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final token = filteredTokens[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onTokenSelected(token);
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      _buildCircularTokenIcon(token.symbol),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  token.symbol,
                                                  style: AppTheme.outfit(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: context.appTextPrimary,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                _buildBottomSheetNetworkBadge(
                                                    token.network),
                                              ],
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              token.name,
                                              style: AppTheme.inter(
                                                fontSize: 12.sp,
                                                color: context.appTextSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            NumberFormatter.formatBalance(token),
                                            style: AppTheme.outfit(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: context.appTextPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            NumberFormatter.formatTokenFiatValue(token),
                                            style: AppTheme.inter(
                                              fontSize: 12.sp,
                                              color: context.appTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 20.h),
                        ],
                      ),
                    );
                  } else if (state is WalletError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularTokenIcon(String symbol) {
    Color bg;
    IconData icon;
    Color iconColor;

    switch (symbol) {
      case 'USDC':
        bg = AppTheme.softBlueBg;
        icon = Icons.monetization_on;
        iconColor = AppTheme.usdcBlue;
        break;
      case 'ETH':
        bg = AppTheme.inactiveBg;
        icon = Icons.hexagon_outlined;
        iconColor = AppTheme.ethGrey;
        break;
      case 'SOL':
        bg = AppTheme.solPurpleBg;
        icon = Icons.flash_on;
        iconColor = AppTheme.solPurple;
        break;
      case 'BTC':
        bg = const Color(0xFFFFFBEB);
        icon = Icons.currency_bitcoin;
        iconColor = AppTheme.btcOrange;
        break;
      case 'MATIC':
        bg = const Color(0xFFF5F3FF);
        icon = Icons.grid_view_rounded;
        iconColor = AppTheme.polygonPurple;
        break;
      default:
        bg = AppTheme.inactiveBg;
        icon = Icons.circle_outlined;
        iconColor = AppTheme.textMuted;
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.appBorder.withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: 22.w),
      ),
    );
  }

  Widget _buildBottomSheetNetworkBadge(String network) {
    Color bg;
    Color text;

    switch (network.toLowerCase()) {
      case 'polygon':
        bg = const Color(0xFFF3E8FF);
        text = AppTheme.polygonPurple;
        break;
      case 'mainnet':
      case 'ethereum':
        bg = AppTheme.softBlueBg;
        text = AppTheme.royalBlue;
        break;
      case 'solana':
        bg = const Color(0xFFECFDF5);
        text = AppTheme.successIcon;
        break;
      case 'native':
      case 'bitcoin':
        bg = const Color(0xFFFFF7ED);
        text = AppTheme.btcOrange;
        break;
      default:
        bg = AppTheme.inactiveBg;
        text = AppTheme.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        network.toUpperCase(),
        style: AppTheme.inter(
          fontSize: 8.sp,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}
