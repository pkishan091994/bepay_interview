import 'package:bloc/bloc.dart';
import 'package:bepay_interview/core/usecases/usecase.dart';
import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';
import 'package:bepay_interview/features/wallet/domain/usecases/get_balances.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class WalletEvent extends Equatable {
  const WalletEvent();
  @override
  List<Object?> get props => [];
}

class GetBalancesEvent extends WalletEvent {}

// --- States ---
abstract class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final List<TokenBalance> balances;
  const WalletLoaded({required this.balances});

  double get totalBalance =>
      balances.fold(0.0, (sum, token) => sum + token.fiatBalance);

  @override
  List<Object?> get props => [balances];
}

class WalletError extends WalletState {
  final String message;
  const WalletError({required this.message});
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetBalances getBalances;

  WalletBloc({required this.getBalances}) : super(WalletInitial()) {
    on<GetBalancesEvent>((event, emit) async {
      emit(WalletLoading());
      try {
        final balances = await getBalances(NoParams());
        emit(WalletLoaded(balances: balances));
      } catch (e) {
        emit(const WalletError(message: 'Failed to retrieve balances'));
      }
    });
  }
}
