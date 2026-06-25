import 'dart:io';

import 'package:bepay_interview/core/routes/app_router.dart';
import 'package:bepay_interview/core/theme/app_theme.dart';
import 'package:bepay_interview/core/theme/theme_notifier.dart';
import 'package:bepay_interview/features/send_flow/presentation/bloc/send_flow_bloc.dart';
import 'package:bepay_interview/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:bepay_interview/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set HTTP overrides for SSL/TLS handshakes
  HttpOverrides.global = MyHttpOverrides();

  // Enable maximum frame rate (120Hz/ProMotion) on supported Android devices
  try {
    await FlutterDisplayMode.setHighRefreshRate();
  } catch (_) {
    // Unsupported or API unavailable
  }

  await di.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return GestureDetector(
      // To dismiss the keyboard
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ScreenUtilInit(
        designSize: const Size(
          390,
          844,
        ), // Responsive scaling base size matching prototype
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<WalletBloc>(
                create: (context) => di.sl<WalletBloc>(),
              ),
              BlocProvider<SendFlowBloc>(
                create: (context) => di.sl<SendFlowBloc>(),
              ),
            ],
            child: MaterialApp.router(
              title: AppStrings.bepayLogo,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeNotifier.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              routerConfig: appRouter,
            ),
          );
        },
      ),
    );
  }
}
