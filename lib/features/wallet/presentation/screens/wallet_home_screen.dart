import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_extensions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bepay_interview/core/utils/number_formatter.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';
import 'package:bepay_interview/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bepay_interview/features/wallet/presentation/widgets/app_drawer.dart';
import 'package:bepay_interview/features/wallet/presentation/widgets/select_token_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  int _currentTab = 0; // Bottom nav tab
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch wallet balances on load
    context.read<WalletBloc>().add(GetBalancesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.appBackground,
      appBar: _buildAppBar(),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WalletBloc>().add(GetBalancesEvent());
        },
        color: AppTheme.royalBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                _buildTotalBalanceSection()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: 20.h),
                _buildPortfolioHealthCard()
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: 24.h),
                _buildAssetsHeader()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                SizedBox(height: 12.h),
                _buildAssetsList()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
                SizedBox(
                  height: 80.h,
                ), // Extra space for FAB and navigation bar
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }


  // --- Widgets ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.appBackground,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: context.appTextPrimary, size: 24.w),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
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
          child: Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.appBorder, width: 1.w),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(19.r),
              child: Image.network(
                AppConstants.avatarURL,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => CircleAvatar(
                  backgroundColor: context.appBorder,
                  child: Icon(
                    Icons.person,
                    color: context.appTextSecondary,
                    size: 20.w,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.totalBalance,
          style: AppTheme.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: context.appTextMuted,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 6.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              BlocBuilder<WalletBloc, WalletState>(
                buildWhen: (previous, current) =>
                    current is WalletLoaded || current is WalletLoading,
                builder: (context, state) {
                  double total = 4285.70;
                  if (state is WalletLoaded) {
                    total = state.totalBalance;
                  }
                  return Text(
                    NumberFormatter.formatCurrency(total),
                    style: AppTheme.outfit(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.bold,
                      color: context.appTextPrimary,
                    ),
                  );
                },
              ),
              SizedBox(width: 8.w),
              Text(
                '+2.4%',
                style: AppTheme.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.royalBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioHealthCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          24.r,
        ), // Highly rounded matching screenshot
        gradient: const LinearGradient(
          colors: [
            AppTheme.royalBlue, // Bright blue
            AppTheme.violet, // Violet
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalBlue.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.portfolioHealth,
                style: AppTheme.inter(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                AppStrings.highSecurity,
                style: AppTheme.outfit(
                  fontSize: 22.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  _buildHealthBadge(AppStrings.verified),
                  SizedBox(width: 8.w),
                  _buildHealthBadge(AppStrings.nonCustodial),
                ],
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 4.h,
            child: Icon(
              Icons.shield_outlined,
              size: 44.w,
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
          width: 0.5.w,
        ),
      ),
      child: Text(
        label,
        style: AppTheme.inter(
          fontSize: 9.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildAssetsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.assets,
          style: AppTheme.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: context.appTextPrimary,
          ),
        ),
        TextButton(
          onPressed: () {
            SelectTokenBottomSheet.show(
              context,
              title: AppStrings.wallet,
              onTokenSelected: (token) {
                context.read<SendFlowBloc>().add(SelectToken(token));
                context.push('/send');
              },
            );
          },
          child: Text(
            AppStrings.viewAll,
            style: AppTheme.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.royalBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetsList() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, state) {
        if (state is WalletLoading) {
          return _buildShimmerAssetsList();
        } else if (state is WalletLoaded) {
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.balances.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final token = state.balances[index];
              return _buildAssetCard(token);
            },
          );
        } else if (state is WalletError) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h),
            decoration: context.appCardDecoration(),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppTheme.error, size: 36.w),
                SizedBox(height: 8.h),
                Text(
                  state.message,
                  style: AppTheme.inter(
                    fontSize: 14.sp,
                    color: context.appTextSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () =>
                      context.read<WalletBloc>().add(GetBalancesEvent()),
                  child: const Text(AppStrings.tryAgain),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAssetCard(TokenBalance token) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: context.appCardDecoration(),
      child: Row(
        children: [
          _buildTokenIcon(token.symbol),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        token.symbol,
                        style: AppTheme.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: context.appTextPrimary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      _buildNetworkBadge(token.network),
                    ],
                  ),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                token.balance.toStringAsFixed(2),
                style: AppTheme.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: context.appTextPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTap: () {
                  context.read<SendFlowBloc>().add(SelectToken(token));
                  context.push('/send');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppTheme.royalBlue.withValues(alpha: 0.5),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    AppStrings.send,
                    style: AppTheme.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.royalBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenIcon(String symbol) {
    Color bg;
    IconData icon;
    Color iconColor;

    switch (symbol) {
      case 'USDC':
        bg = AppTheme.softBlueBg; // Soft blue
        icon = Icons.monetization_on;
        iconColor = AppTheme.usdcBlue;
        break;
      case 'ETH':
        bg = AppTheme.inactiveBg; // Soft grey
        icon = Icons.hexagon_outlined; // Hexagon representation
        iconColor = AppTheme.ethGrey;
        break;
      case 'SOL':
        bg = AppTheme.solPurpleBg; // Soft purple
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
        bg = AppTheme.background;
        icon = Icons.circle_outlined;
        iconColor = AppTheme.textMuted;
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Center(
        child: Icon(icon, color: iconColor, size: 22.w),
      ),
    );
  }

  Widget _buildNetworkBadge(String network) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: context.appInactiveBg,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        network,
        style: AppTheme.inter(
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
          color: context.appTextSecondary,
        ),
      ),
    );
  }

  Widget _buildShimmerAssetsList() {
    return Column(children: List.generate(4, (index) => _buildShimmerCard()));
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: context.appCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: context.appInactiveBg,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: context.appInactiveBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 120.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: context.appInactiveBg,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 60.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: context.appInactiveBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                width: 50.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: context.appInactiveBg,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppTheme.royalBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          // Open Send flow with default state
          final walletState = context.read<WalletBloc>().state;
          TokenBalance? defaultToken;
          if (walletState is WalletLoaded && walletState.balances.isNotEmpty) {
            defaultToken = walletState.balances.first;
          }
          if (defaultToken != null) {
            context.read<SendFlowBloc>().add(SelectToken(defaultToken));
            context.push('/send');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.walletNotLoaded)),
            );
          }
        },
        label: Text(
          AppStrings.sendCrypto,
          style: AppTheme.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: Icon(Icons.send_rounded, color: Colors.white, size: 16.w),
        backgroundColor: AppTheme.royalBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.appSurface,
        border: Border(
          top: BorderSide(color: context.appBorder, width: 1.w),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(0, Icons.home_rounded, AppStrings.home),
              _buildBottomNavItem(
                1,
                Icons.account_balance_wallet_outlined,
                AppStrings.wallet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isActive = _currentTab == index;
    final activeBg = context.isDark
        ? AppTheme.royalBlue.withValues(alpha: 0.15)
        : AppTheme.softBlueBg;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          setState(() {
            _currentTab = 1;
          });
          SelectTokenBottomSheet.show(
            context,
            title: AppStrings.wallet,
            onTokenSelected: (token) {
              context.read<SendFlowBloc>().add(SelectToken(token));
              context.push('/send');
            },
          ).then((_) {
            setState(() {
              _currentTab = 0;
            });
          });
        } else {
          setState(() {
            _currentTab = index;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.royalBlue : context.appTextMuted,
              size: 20.w,
            ),
            if (isActive) ...[
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTheme.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.royalBlue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
