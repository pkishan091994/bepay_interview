import 'package:bloc/bloc.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/estimate_fee.dart';
import 'package:bepay_interview/features/wallet/domain/entities/token_balance.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class SendFlowEvent extends Equatable {
  const SendFlowEvent();
  @override
  List<Object?> get props => [];
}

class SelectToken extends SendFlowEvent {
  final TokenBalance token;
  const SelectToken(this.token);
  @override
  List<Object?> get props => [token];
}

class SetRecipient extends SendFlowEvent {
  final Recipient recipient;
  const SetRecipient(this.recipient);
  @override
  List<Object?> get props => [recipient];
}

class SetAmountAndNote extends SendFlowEvent {
  final double amount;
  final String note;
  const SetAmountAndNote({required this.amount, required this.note});
  @override
  List<Object?> get props => [amount, note];
}

class UpdateNote extends SendFlowEvent {
  final String note;
  const UpdateNote(this.note);
  @override
  List<Object?> get props => [note];
}

class ResetFlow extends SendFlowEvent {}

// --- State ---
class SendFlowState extends Equatable {
  final TokenBalance? selectedToken;
  final Recipient? recipient;
  final double amount;
  final String note;
  final int
  currentStepIndex; // 0: Recipient Entry, 1: Amount Entry, 2: Review, 3: PIN Confirmation, 4: Result
  final double? estimatedFee;
  final bool isLoadingFee;

  const SendFlowState({
    this.selectedToken,
    this.recipient,
    this.amount = 0.0,
    this.note = '',
    this.currentStepIndex = 0,
    this.estimatedFee,
    this.isLoadingFee = false,
  });

  SendFlowState copyWith({
    TokenBalance? selectedToken,
    Recipient? recipient,
    double? amount,
    String? note,
    int? currentStepIndex,
    double? estimatedFee,
    bool? isLoadingFee,
  }) {
    return SendFlowState(
      selectedToken: selectedToken ?? this.selectedToken,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      isLoadingFee: isLoadingFee ?? this.isLoadingFee,
    );
  }

  @override
  List<Object?> get props => [
    selectedToken,
    recipient,
    amount,
    note,
    currentStepIndex,
    estimatedFee,
    isLoadingFee,
  ];
}

// --- Bloc ---
class SendFlowBloc extends Bloc<SendFlowEvent, SendFlowState> {
  final EstimateFee estimateFee;

  SendFlowBloc({required this.estimateFee}) : super(const SendFlowState()) {
    on<SelectToken>((event, emit) {
      emit(
        state.copyWith(
          selectedToken: event.token,
          currentStepIndex:
              0, // Reset to first step of send flow (recipient entry)
        ),
      );
    });

    on<SetRecipient>((event, emit) {
      emit(
        state.copyWith(
          recipient: event.recipient,
          currentStepIndex: 1, // Advance to amount entry
        ),
      );
    });

    on<SetAmountAndNote>((event, emit) async {
      emit(
        state.copyWith(
          amount: event.amount,
          note: event.note,
          currentStepIndex: 2, // Advance to review
          isLoadingFee: true,
          estimatedFee: null, // Clear previous fee estimate
        ),
      );

      try {
        final token = state.selectedToken;
        final fee = await estimateFee(
          EstimateFeeParams(
            tokenSymbol: token?.symbol ?? 'USDC',
            network: token?.network ?? 'Polygon',
          ),
        );
        emit(state.copyWith(isLoadingFee: false, estimatedFee: fee));
      } catch (_) {
        emit(
          state.copyWith(
            isLoadingFee: false,
            estimatedFee: 0.02, // Fallback fee
          ),
        );
      }
    });

    on<UpdateNote>((event, emit) {
      emit(state.copyWith(note: event.note));
    });

    on<ResetFlow>((event, emit) {
      emit(const SendFlowState()); // Reset completely
    });
  }
}
