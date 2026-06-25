import 'package:bloc/bloc.dart';
import 'package:bepay_interview/core/usecases/usecase.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/get_recent_recipients.dart';
import 'package:bepay_interview/features/send_flow/domain/entities/recipient.dart';
import 'package:equatable/equatable.dart';

// --- Events ---
abstract class RecipientEntryEvent extends Equatable {
  const RecipientEntryEvent();
  @override
  List<Object?> get props => [];
}

class LoadRecentRecipients extends RecipientEntryEvent {}

class RecipientInputChanged extends RecipientEntryEvent {
  final String input;
  const RecipientInputChanged(this.input);
  @override
  List<Object?> get props => [input];
}

class SelectRecentRecipient extends RecipientEntryEvent {
  final Recipient recipient;
  const SelectRecentRecipient(this.recipient);
  @override
  List<Object?> get props => [recipient];
}

class RecipientTabChanged extends RecipientEntryEvent {
  final int selectedTab;
  const RecipientTabChanged(this.selectedTab);
  @override
  List<Object?> get props => [selectedTab];
}

// --- State ---
class RecipientEntryState extends Equatable {
  final String inputString;
  final Recipient? recipient;
  final bool isValid;
  final String? errorMessage;
  final int selectedTab; // 0: bepay ID, 1: Wallet Address
  final List<Recipient> recentRecipients;
  final bool isLoadingRecipients;

  const RecipientEntryState({
    this.inputString = '',
    this.recipient,
    this.isValid = false,
    this.errorMessage,
    this.selectedTab = 0,
    required this.recentRecipients,
    this.isLoadingRecipients = false,
  });

  RecipientEntryState copyWith({
    String? inputString,
    Recipient? recipient,
    bool? isValid,
    String? errorMessage,
    int? selectedTab,
    List<Recipient>? recentRecipients,
    bool? isLoadingRecipients,
  }) {
    return RecipientEntryState(
      inputString: inputString ?? this.inputString,
      recipient: recipient ?? this.recipient,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage, // We pass null to clear it
      selectedTab: selectedTab ?? this.selectedTab,
      recentRecipients: recentRecipients ?? this.recentRecipients,
      isLoadingRecipients: isLoadingRecipients ?? this.isLoadingRecipients,
    );
  }

  @override
  List<Object?> get props => [
    inputString,
    recipient,
    isValid,
    errorMessage,
    selectedTab,
    recentRecipients,
    isLoadingRecipients,
  ];
}

// --- Bloc ---
class RecipientEntryBloc
    extends Bloc<RecipientEntryEvent, RecipientEntryState> {
  final GetRecentRecipients getRecentRecipients;

  // Regex patterns for validation
  static final RegExp _bepayIdRegex = RegExp(r'^[a-zA-Z0-9_]{3,15}@bepay$');
  static final RegExp _evmAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  RecipientEntryBloc({required this.getRecentRecipients})
    : super(const RecipientEntryState(recentRecipients: [], isLoadingRecipients: true)) {
    // Load recent recipients
    on<LoadRecentRecipients>((event, emit) async {
      emit(state.copyWith(isLoadingRecipients: true));
      try {
        final recipients = await getRecentRecipients(NoParams());
        emit(state.copyWith(
          recentRecipients: recipients,
          isLoadingRecipients: false,
        ));
      } catch (_) {
        emit(state.copyWith(isLoadingRecipients: false));
      }
    });

    // Tab selection changed
    on<RecipientTabChanged>((event, emit) {
      // Switch tab and reset input states
      emit(
        state.copyWith(
          selectedTab: event.selectedTab,
          inputString: '',
          recipient: null,
          isValid: false,
          errorMessage: null,
        ),
      );
    });

    // Input changed
    on<RecipientInputChanged>((event, emit) {
      final input = event.input.trim();
      if (input.isEmpty) {
        emit(
          state.copyWith(
            inputString: '',
            recipient: null,
            isValid: false,
            errorMessage: null,
          ),
        );
        return;
      }

      // Check validation based on currently active tab (0: BepayID, 1: Wallet Address)
      switch (state.selectedTab) {
        case 0: // Bepay ID tab (supports Bepay ID, Email, Phone)
          if (_bepayIdRegex.hasMatch(input)) {
            final username = input.split('@bepay')[0];
            final recipient = Recipient(
              id: 'bepay_id_$username',
              name: 'Bepay User ($input)',
              address: input,
              type: RecipientType.bepayId,
              isExternal: false,
            );
            emit(
              state.copyWith(
                inputString: input,
                recipient: recipient,
                isValid: true,
                errorMessage: null,
              ),
            );
          } else if (_emailRegex.hasMatch(input)) {
            final name = input.split('@')[0];
            final recipient = Recipient(
              id: 'email_$name',
              name: 'Bepay User ($input)',
              address: input,
              type: RecipientType.email,
              isExternal: false,
            );
            emit(
              state.copyWith(
                inputString: input,
                recipient: recipient,
                isValid: true,
                errorMessage: null,
              ),
            );
          } else if (_phoneRegex.hasMatch(input)) {
            final recipient = Recipient(
              id: 'phone_$input',
              name: 'Bepay User ($input)',
              address: input,
              type: RecipientType.phone,
              isExternal: false,
            );
            emit(
              state.copyWith(
                inputString: input,
                recipient: recipient,
                isValid: true,
                errorMessage: null,
              ),
            );
          } else if (_evmAddressRegex.hasMatch(input)) {
            emit(
              state.copyWith(
                inputString: input,
                recipient: null,
                isValid: false,
                errorMessage:
                    'This is a wallet address. Please switch to the Wallet Address tab.',
              ),
            );
          } else {
            emit(
              state.copyWith(
                inputString: input,
                recipient: null,
                isValid: false,
                errorMessage:
                    'Invalid format. Use username@bepay, email, or phone number.',
              ),
            );
          }
          break;

        case 1: // Wallet Address (0x...)
          if (_evmAddressRegex.hasMatch(input)) {
            final recipient = Recipient(
              id: 'evm_addr_${input.substring(2, 6)}',
              name: 'External Blockchain Address',
              address: input,
              type: RecipientType.address,
              isExternal: true,
            );
            emit(
              state.copyWith(
                inputString: input,
                recipient: recipient,
                isValid: true,
                errorMessage: null,
              ),
            );
          } else if (_bepayIdRegex.hasMatch(input) ||
              _emailRegex.hasMatch(input) ||
              _phoneRegex.hasMatch(input)) {
            emit(
              state.copyWith(
                inputString: input,
                recipient: null,
                isValid: false,
                errorMessage:
                    'This is a Bepay identifier. Please switch to the Bepay ID tab.',
              ),
            );
          } else {
            emit(
              state.copyWith(
                inputString: input,
                recipient: null,
                isValid: false,
                errorMessage:
                    'Invalid wallet address format. Must be 42 characters hex starting with 0x.',
              ),
            );
          }
          break;
      }
    });

    on<SelectRecentRecipient>((event, emit) {
      // Auto-validate and select a recent recipient
      int tabIndex = 0;
      switch (event.recipient.type) {
        case RecipientType.bepayId:
        case RecipientType.email:
        case RecipientType.phone:
          tabIndex = 0;
          break;
        case RecipientType.address:
          tabIndex = 1;
          break;
      }

      emit(
        state.copyWith(
          selectedTab: tabIndex,
          inputString: event.recipient.address,
          recipient: event.recipient,
          isValid: true,
          errorMessage: null,
        ),
      );
    });

    // Auto-load contacts upon instantiation
    add(LoadRecentRecipients());
  }
}
