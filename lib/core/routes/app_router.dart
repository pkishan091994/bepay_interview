import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bepay_interview/injection_container.dart' as di;
import 'package:bepay_interview/features/wallet/presentation/screens/wallet_home_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/recipient_entry_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/amount_entry_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/review_transaction_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/pin_confirmation_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/screens/transaction_success_screen.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/recipient_entry/recipient_entry_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/amount_entry/amount_entry_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/pin_confirmation/pin_confirmation_bloc.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WalletHomeScreen()),
    GoRoute(
      path: '/send',
      builder: (context, state) => BlocProvider<RecipientEntryBloc>(
        create: (context) => di.sl<RecipientEntryBloc>(),
        child: const RecipientEntryScreen(),
      ),
    ),
    GoRoute(
      path: '/send/amount',
      builder: (context, state) {
        final sendFlowState = context.read<SendFlowBloc>().state;
        final token = sendFlowState.selectedToken;
        return BlocProvider<AmountEntryBloc>(
          create: (context) => AmountEntryBloc(
            maxBalance: token?.balance ?? 0.0,
            decimals: token?.decimals ?? 6,
          ),
          child: const AmountEntryScreen(),
        );
      },
    ),
    GoRoute(
      path: '/send/review',
      builder: (context, state) => const ReviewTransactionScreen(),
    ),
    GoRoute(
      path: '/send/pin',
      builder: (context, state) => BlocProvider<PinConfirmationBloc>(
        create: (context) => di.sl<PinConfirmationBloc>(),
        child: const PinConfirmationScreen(),
      ),
    ),
    GoRoute(
      path: '/send/success',
      builder: (context, state) => const TransactionSuccessScreen(),
    ),
  ],
);
