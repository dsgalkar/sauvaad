import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: depend_on_referenced_packages
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'constants/app_colors.dart';
import 'screens/splash_screen.dart';

/// Global navigator key required by ZegoUIKit for overlay / incoming call notification dialogs
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark system UI overlay
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize ZegoUIKit navigation key for incoming call popups
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  // Initialize log
  await ZegoUIKit().initLog();

  runApp(const SauvaadApp());
}

class SauvaadApp extends StatelessWidget {
  const SauvaadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sauvaad - ZEGOCLOUD Calling',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.cyan,
          secondary: AppColors.violet,
          surface: AppColors.surface,
          error: AppColors.callRed,
          onPrimary: Colors.black,
          onSurface: AppColors.textPrimary,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
