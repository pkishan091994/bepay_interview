import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class AmountEntryEvent extends Equatable {
  const AmountEntryEvent();

  @override
  List<Object?> get props => [];
}

class AmountKeyTyped extends AmountEntryEvent {
  final String key;
  const AmountKeyTyped(this.key);

  @override
  List<Object?> get props => [key];
}

class AmountBackspacePressed extends AmountEntryEvent {}

class AmountMaxPressed extends AmountEntryEvent {}

class AmountUpdateToken extends AmountEntryEvent {
  final double maxBalance;
  final int decimals;

  const AmountUpdateToken({required this.maxBalance, required this.decimals});

  @override
  List<Object?> get props => [maxBalance, decimals];
}

// --- State ---
class AmountEntryState extends Equatable {
  final String amountString;
  final double amount;
  final bool isValid;
  final String? errorMessage;

  const AmountEntryState({
    required this.amountString,
    required this.amount,
    required this.isValid,
    this.errorMessage,
  });

  factory AmountEntryState.initial() {
    return const AmountEntryState(
      amountString: '0',
      amount: 0.0,
      isValid: false,
    );
  }

  AmountEntryState copyWith({
    String? amountString,
    double? amount,
    bool? isValid,
    String? errorMessage,
  }) {
    return AmountEntryState(
      amountString: amountString ?? this.amountString,
      amount: amount ?? this.amount,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage, // Null clears the error
    );
  }

  @override
  List<Object?> get props => [amountString, amount, isValid, errorMessage];
}

// --- Bloc ---
class AmountEntryBloc extends Bloc<AmountEntryEvent, AmountEntryState> {
  double maxBalance;
  int decimals;

  AmountEntryBloc({required this.maxBalance, required this.decimals})
    : super(AmountEntryState.initial()) {
    on<AmountKeyTyped>(_onKeyTyped);
    on<AmountBackspacePressed>(_onBackspacePressed);
    on<AmountMaxPressed>(_onMaxPressed);
    on<AmountUpdateToken>(_onUpdateToken);
  }

  void _onUpdateToken(AmountUpdateToken event, Emitter<AmountEntryState> emit) {
    maxBalance = event.maxBalance;
    decimals = event.decimals;
    emit(AmountEntryState.initial());
  }

  void _onKeyTyped(AmountKeyTyped event, Emitter<AmountEntryState> emit) {
    String current = state.amountString;
    final key = event.key;

    if (key == '.') {
      if (current.contains('.')) {
        return; // Ignore duplicate decimal point
      }
      if (current.isEmpty || current == '0') {
        current = '0.';
      } else {
        current = '$current.';
      }
    } else {
      // Digit 0-9
      if (current == '0') {
        if (key == '0') {
          return; // Ignore multiple leading zeros
        }
        current = key;
      } else {
        // Check if decimals limit is exceeded
        if (current.contains('.')) {
          final parts = current.split('.');
          if (parts[1].length >= decimals) {
            return; // Reject more decimals than permitted
          }
        }
        current = '$current$key';
      }
    }

    final parsedAmount = double.tryParse(current) ?? 0.0;
    _emitUpdatedState(emit, current, parsedAmount);
  }

  void _onBackspacePressed(
    AmountBackspacePressed event,
    Emitter<AmountEntryState> emit,
  ) {
    String current = state.amountString;
    if (current.isEmpty || current == '0') {
      return;
    }

    current = current.substring(0, current.length - 1);
    if (current.isEmpty) {
      current = '0';
    }

    final parsedAmount = double.tryParse(current) ?? 0.0;
    _emitUpdatedState(emit, current, parsedAmount);
  }

  void _onMaxPressed(AmountMaxPressed event, Emitter<AmountEntryState> emit) {
    final formatted = _formatDouble(maxBalance, decimals);
    _emitUpdatedState(emit, formatted, maxBalance);
  }

  void _emitUpdatedState(
    Emitter<AmountEntryState> emit,
    String amountStr,
    double amountVal,
  ) {
    String? error;
    bool valid = false;

    if (amountVal > maxBalance) {
      error = 'Insufficient balance';
    } else if (amountVal <= 0.0) {
      error = null; // Do not show error for 0.0, just keep isValid = false
    } else {
      valid = true;
    }

    emit(
      state.copyWith(
        amountString: amountStr,
        amount: amountVal,
        isValid: valid,
        errorMessage: error,
      ),
    );
  }

  String _formatDouble(double value, int decimals) {
    String result = value.toStringAsFixed(decimals);
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      if (result.endsWith('.')) {
        result = result.substring(0, result.length - 1);
      }
    }
    return result;
  }
}
