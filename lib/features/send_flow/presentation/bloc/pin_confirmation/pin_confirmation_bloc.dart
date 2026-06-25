import 'package:bloc/bloc.dart';
import 'package:bepay_interview/core/constants/app_strings.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/submit_transaction.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class PinConfirmationEvent extends Equatable {
  const PinConfirmationEvent();
  @override
  List<Object?> get props => [];
}

class PinDigitEntered extends PinConfirmationEvent {
  final String digit;
  final String tokenSymbol;
  final String recipientAddress;
  final double amount;

  const PinDigitEntered({
    required this.digit,
    required this.tokenSymbol,
    required this.recipientAddress,
    required this.amount,
  });

  @override
  List<Object?> get props => [digit, tokenSymbol, recipientAddress, amount];
}

class PinBackspacePressed extends PinConfirmationEvent {}

class PinBiometricTapped extends PinConfirmationEvent {
  final String tokenSymbol;
  final String recipientAddress;
  final double amount;

  const PinBiometricTapped({
    required this.tokenSymbol,
    required this.recipientAddress,
    required this.amount,
  });

  @override
  List<Object?> get props => [tokenSymbol, recipientAddress, amount];
}

class PinSubmit extends PinConfirmationEvent {
  final String tokenSymbol;
  final String recipientAddress;
  final double amount;

  const PinSubmit({
    required this.tokenSymbol,
    required this.recipientAddress,
    required this.amount,
  });

  @override
  List<Object?> get props => [tokenSymbol, recipientAddress, amount];
}

class PinLockTimerTicked extends PinConfirmationEvent {}

// --- State ---
class PinConfirmationState extends Equatable {
  final String pin;
  final String? errorMessage;
  final bool isSubmitting;
  final bool isSuccess;
  final String? toastMessage;
  final int incorrectAttempts;
  final DateTime? lockedUntil;
  final int lockSecondsRemaining;

  const PinConfirmationState({
    this.pin = '',
    this.errorMessage,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.toastMessage,
    this.incorrectAttempts = 0,
    this.lockedUntil,
    this.lockSecondsRemaining = 0,
  });

  bool get isLocked =>
      lockSecondsRemaining > 0 ||
      (lockedUntil != null && lockedUntil!.isAfter(DateTime.now()));

  PinConfirmationState copyWith({
    String? pin,
    String? errorMessage,
    bool? isSubmitting,
    bool? isSuccess,
    String? toastMessage,
    int? incorrectAttempts,
    DateTime? lockedUntil,
    bool clearLockedUntil = false,
    int? lockSecondsRemaining,
  }) {
    return PinConfirmationState(
      pin: pin ?? this.pin,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      toastMessage: toastMessage,
      incorrectAttempts: incorrectAttempts ?? this.incorrectAttempts,
      lockedUntil: clearLockedUntil ? null : (lockedUntil ?? this.lockedUntil),
      lockSecondsRemaining: lockSecondsRemaining ?? this.lockSecondsRemaining,
    );
  }

  @override
  List<Object?> get props => [
    pin,
    errorMessage,
    isSubmitting,
    isSuccess,
    toastMessage,
    incorrectAttempts,
    lockedUntil,
    lockSecondsRemaining,
  ];
}

// --- Bloc ---
class PinConfirmationBloc
    extends Bloc<PinConfirmationEvent, PinConfirmationState> {
  final SubmitTransaction submitTransaction;
  static const String _correctPin = '1234';

  PinConfirmationBloc({required this.submitTransaction})
    : super(const PinConfirmationState()) {
    on<PinDigitEntered>((event, emit) async {
      if (state.isLocked || state.isSubmitting || state.pin.length >= 4) return;

      final newPin = '${state.pin}${event.digit}';
      emit(state.copyWith(pin: newPin, errorMessage: null, toastMessage: null));

      if (newPin.length == 4) {
        add(
          PinSubmit(
            tokenSymbol: event.tokenSymbol,
            recipientAddress: event.recipientAddress,
            amount: event.amount,
          ),
        );
      }
    });

    on<PinBackspacePressed>((event, emit) {
      if (state.isLocked || state.isSubmitting || state.pin.isEmpty) return;

      emit(
        state.copyWith(
          pin: state.pin.substring(0, state.pin.length - 1),
          errorMessage: null,
          toastMessage: null,
        ),
      );
    });

    on<PinBiometricTapped>((event, emit) {
      if (state.isLocked || state.isSubmitting) return;

      emit(
        state.copyWith(
          pin: _correctPin,
          errorMessage: null,
          toastMessage: AppStrings.biometricsVerified,
        ),
      );

      add(
        PinSubmit(
          tokenSymbol: event.tokenSymbol,
          recipientAddress: event.recipientAddress,
          amount: event.amount,
        ),
      );
    });

    on<PinSubmit>((event, emit) async {
      if (state.isLocked) return;

      if (state.pin == _correctPin) {
        emit(
          state.copyWith(
            isSubmitting: true,
            errorMessage: null,
            incorrectAttempts: 0,
            clearLockedUntil: true,
          ),
        );

        try {
          final success = await submitTransaction(
            SubmitTransactionParams(
              tokenSymbol: event.tokenSymbol,
              recipientAddress: event.recipientAddress,
              amount: event.amount,
            ),
          );

          if (success) {
            emit(state.copyWith(isSubmitting: false, isSuccess: true));
          } else {
            emit(
              state.copyWith(
                isSubmitting: false,
                errorMessage: AppStrings.transactionFailed,
                pin: '',
              ),
            );
          }
        } catch (e) {
          emit(
            state.copyWith(
              isSubmitting: false,
              errorMessage: '${AppStrings.anErrorOccurred}: ${e.toString()}',
              pin: '',
            ),
          );
        }
      } else {
        final newAttempts = state.incorrectAttempts + 1;
        if (newAttempts >= 3) {
          emit(
            state.copyWith(
              incorrectAttempts: newAttempts,
              lockedUntil: DateTime.now().add(const Duration(seconds: 30)),
              lockSecondsRemaining: 30,
              errorMessage: 'Too many incorrect attempts. Locked for 30s.',
              pin: '',
            ),
          );
        } else {
          emit(
            state.copyWith(
              incorrectAttempts: newAttempts,
              errorMessage: '${AppStrings.incorrectPin} (${3 - newAttempts} attempts left)',
              pin: '',
            ),
          );
        }
      }
    });

    on<PinLockTimerTicked>((event, emit) {
      if (state.lockedUntil == null) return;
      final diff = state.lockedUntil!.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        emit(
          state.copyWith(
            incorrectAttempts: 0,
            clearLockedUntil: true,
            lockSecondsRemaining: 0,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            lockSecondsRemaining: diff,
          ),
        );
      }
    });
  }
}
