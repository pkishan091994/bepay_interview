# Bepay - Crypto Send Flow Take-Home Assignment

A production-grade, focused Flutter mobile application implementing a custom **Crypto Send Flow** with an **in-app numeric keyboard** instead of the native system keyboard. Built following Clean Architecture principles, the BLoC state management pattern, and high usability guidelines matching the Bepay visual design specifications.

---

## 1. Setup Instructions

### Prerequisites
* Flutter SDK (Version **3.10.0** or newer)
* Dart SDK (Version matches Flutter SDK)
* Android Studio / Xcode configured for Android/iOS emulation

### Getting Started
1. **Clone the Repository** and navigate to the project directory:
   ```bash
   cd bepay_interview
   ```
2. **Fetch Dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run Static Code Analysis**:
   ```bash
   flutter analyze
   ```
4. **Run the Application**:
   * Launch your mobile emulator or connect a physical device.
   * Run the app in debug mode:
     ```bash
     flutter run
     ```

---

## 2. Flutter Version Used
* **Flutter SDK**: `^3.10.0`
* **Dart SDK**: `>=3.0.0 <4.0.0`

---

## 3. Architecture Overview

The application is structured following **Clean Architecture** patterns separated into three core layers:

```
lib/
├── core/                  # Shared configurations, constants, theme, and utility functions
│   ├── constants/         # AppStrings, mock constants, routes
│   ├── theme/             # Design Tokens (AppTheme, font scaling, gradients, color palettes)
│   ├── usecases/          # Base contract class for UseCases
│   └── utils/             # NumberFormatter and other formatting helpers
├── features/              # Feature slices
│   ├── wallet/            # Wallet Feature (Balances, Token Select Bottom Sheet)
│   └── send_flow/         # Send Flow Feature (Recipient, Amount Entry, Review, PIN Confirmation, Result)
└── main.dart              # Global overrides setup, DI initializations, and MaterialApp launch
```

### Clean Architecture Layers
1. **Data Layer**: Defines models and handles local/remote data retrieval (`WalletLocalDataSourceImpl`).
2. **Domain Layer**: Contains the pure business logic core, defining entities (`TokenBalance`, `Recipient`) and clean UseCases (`GetBalances`, `SubmitTransaction`, `EstimateFee`).
3. **Presentation Layer**: Consists of UI Screens, custom reusable widgets, and screen-specific BLoC state management logic.

---

## 4. State Management Approach

### Coordinator Pattern (SendFlowBloc)
* A central, global `SendFlowBloc` acts as a coordinator, managing the progress of the entire transactional sequence (selected token, recipient, amount, fee estimation, note, etc.) and handling intermediate values across screens.

### Isolated Screen Blocs
* Individual presentation stages feature isolated, scoped BLoCs (`RecipientEntryBloc`, `AmountEntryBloc`, `PinConfirmationBloc`) to handle local interactive states, user inputs, digit keypad entries, and form validation reactively.
* Localizing states in this way prevents full-screen rebuilds, keeping widget tree updates isolated to the leaf components (e.g., updating only the input balance indicator or PIN dot indicators during type interactions).

---

## 5. Assumptions and Trade-offs

* **Mock Services**: No real blockchain operations are executed. All service methods (`estimateFee`, `submitTransaction`) use simulated asynchronous delays via `Future.delayed` to resemble real network responses.
* **Persistent Storage**: State is persisted securely using `flutter_secure_storage` rather than shared preferences, as it involves financial context (e.g. recent recipients, user preferences).
* **Biometrics**: The fingerprint validation is simulated using mockup logic, representing how a platform biometric plugin callback would resolve into state transitions.

---

## 6. Completed and Incomplete Features

### Completed Features
* **Wallet Balance Screen**: Shows total calculated balances, list of tokens with networks, and redirects to the send flow.
* **Recipient Entry Screen**: Support for BepayID, Wallet Address, Email, and Phone tabs. Displays mock recent recipients, input validations, and external wallet caution notifications.
* **Amount Entry Screen with Custom Keyboard**: Custom numeric keypad supporting decimal inputs, backspaces, and a `Use Max` button. Enforces validation rules (greater than zero, balance limits, and decimals/decimals-limit check). Shows dynamic fiat rate estimations.
* **Review Transaction Screen**: Displays sending details, dynamic network fee, optional notes, and external wallet address caution banners.
* **Mock PIN Confirmation Screen**: Keypad for entering a 4-digit PIN, verified against mock PIN `1234`. Includes a 30-second lockout after 3 failed attempts.
* **Transaction Result Screen**: Shows transaction success/failure states, transfer amounts, network names, and mock transaction IDs.

### Completed Optional Enhancements
* QR scanner placeholder for wallet address input (Mocked bottom sheet).
* Contact picker mock (Mocked bottom sheet with search).
* Token/network selector bottom sheet.
* Dark mode (Full adaptive theming across the flow).
* Local persistence using `flutter_secure_storage`.
* Unit tests for amount input validation and widget tests for the send flow.
* Biometric confirmation mock.
* Flex gas message ("Network fee paid using USDC").
* Polished animations and micro-interactions using `flutter_animate`.

### Incomplete / Excluded Features
* Real blockchain integration and Wallet connection (intentionally excluded).
* Real KYC/KYB, fiat on/off-ramps, push notifications, and backend logic (intentionally excluded).
* Transaction history screen (not implemented to focus on the core send flow).

---

## 7. Testing Instructions

The codebase is backed by robust unit and widget testing suites covering all state validation edge cases, layout components, and mock flows.

### Running Tests
To run all unit and widget tests:
```bash
flutter test
```

### Key Tests Included
1. **PIN Confirmation Bloc Tests** (`pin_confirmation_bloc_test.dart`): Verifies successful submission transitions, incorrect entry validations, and correct triggering of the 30-second lockout state.
2. **Amount Entry Bloc Tests** (`amount_entry_bloc_test.dart`): Tests keypad inputs, decimal precision boundaries, balance excess checks, and token updates.
3. **Recipient Entry Bloc Tests** (`recipient_entry_bloc_test.dart`): Verifies BepayID formats, EVM address validation rules, and tab warning feedbacks.
4. **UI Widget Tests** (`widget_test.dart` & `send_flow_screens_test.dart`): Simulates complete user keyboard clicks, pin entries, list renderings, and page navigation structures.
