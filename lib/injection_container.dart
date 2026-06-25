import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Wallet imports
import 'package:bepay_interview/features/wallet/data/datasources/wallet_local_data_source.dart';
import 'package:bepay_interview/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:bepay_interview/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:bepay_interview/features/wallet/domain/usecases/get_balances.dart';
import 'package:bepay_interview/features/wallet/presentation/bloc/wallet_bloc.dart';

// Send flow imports
import 'package:bepay_interview/features/send_flow/data/datasources/send_local_data_source.dart';
import 'package:bepay_interview/features/send_flow/data/repositories/send_repository_impl.dart';
import 'package:bepay_interview/features/send_flow/domain/repositories/send_repository.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/get_recent_recipients.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/estimate_fee.dart';
import 'package:bepay_interview/features/send_flow/domain/usecases/submit_transaction.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/recipient_entry/recipient_entry_bloc.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/pin_confirmation/pin_confirmation_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  // Presentation (BLoCs)
  sl.registerFactory(() => WalletBloc(getBalances: sl()));
  sl.registerFactory(() => SendFlowBloc(estimateFee: sl()));
  sl.registerFactory(() => RecipientEntryBloc(getRecentRecipients: sl()));
  sl.registerFactory(() => PinConfirmationBloc(submitTransaction: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetBalances(repository: sl()));
  sl.registerLazySingleton(() => GetRecentRecipients(repository: sl()));
  sl.registerLazySingleton(() => EstimateFee(repository: sl()));
  sl.registerLazySingleton(() => SubmitTransaction(repository: sl()));

  // Repositories
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<SendRepository>(
    () => SendRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<WalletLocalDataSource>(
    () => WalletLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<SendLocalDataSource>(
    () => SendLocalDataSourceImpl(),
  );

  //! Core
  // Navigation / Router

  //! External
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => secureStorage);
}
