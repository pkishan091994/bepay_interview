import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Sleek Modern Bepay Style
  static const Color background = Color(
    0xFFF8FAFC,
  ); // Soft off-white (Slate 50)
  static const Color surface = Color(0xFFFFFFFF); // Pure white for cards
  static const Color primary = Color(
    0xFF0F172A,
  ); // Deep Slate/Black (Active/Primary actions)
  static const Color accent = Color(0xFF0F172A); // Deep Slate/Black

  // Neutral Greys for Unselected/Inactive states
  static const Color inactiveBg = Color(0xFFF1F5F9); // Light grey (Slate 100)
  static const Color borderColor = Color(
    0xFFE2E8F0,
  ); // Very subtle divider (Slate 200)

  // Semantic Colors
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Amber/Orange
  static const Color success = Color(0xFF10B981); // Emerald green

  // Text Colors
  static const Color textPrimary = Color(
    0xFF0F172A,
  ); // Deep slate (almost black)
  static const Color textSecondary = Color(0xFF475569); // Medium slate grey
  static const Color textMuted = Color(0xFF94A3B8); // Light slate grey

  // Brand / Prototype Specific Colors
  static const Color royalBlue = Color(
    0xFF2563EB,
  ); // Royal blue logo and primary buttons
  static const Color softBlueBg = Color(
    0xFFEFF6FF,
  ); // Soft blue card/pill background
  static const Color softBlueBorder = Color(
    0xFFBFDBFE,
  ); // Soft blue card border
  static const Color darkBlue = Color(0xFF1E40AF); // Darker blue text/pills
  static const Color indigo = Color(0xFF6366F1); // Indigo for gradient start
  static const Color darkIndigo = Color(
    0xFF4F46E5,
  ); // Dark Indigo for gradient center
  static const Color violet = Color(0xFF7C3AED); // Violet for gradient end
  static const Color polygonPurple = Color(
    0xFF8B5CF6,
  ); // Purple representing Polygon
  static const Color slate300 = Color(0xFFCBD5E1); // Border/dot grey

  // Additional Token & Border Colors
  static const Color errorRed = Color(0xFFDC2626); // Red error border/text
  static const Color usdcBlue = Color(0xFF3B82F6); // USDC blue icon color
  static const Color ethGrey = Color(0xFF64748B); // ETH grey icon color
  static const Color solPurpleBg = Color(
    0xFFFAF5FF,
  ); // SOL soft purple background
  static const Color solPurple = Color(0xFFA855F7); // SOL purple icon color
  static const Color usdtGreenBg = Color(
    0xFFECFDF5,
  ); // USDT soft green background
  static const Color usdtGreen = Color(0xFF10B981); // USDT green icon color
  static const Color btcOrange = Color(
    0xFFF59E0B,
  ); // BTC/default orange icon color

  // Semantic Extensions
  static const Color errorLight = Color(
    0xFFFEF2F2,
  ); // Light red alert container background
  static const Color errorBorder = Color(
    0xFFFEE2E2,
  ); // Light red alert container border
  static const Color errorTextDark = Color(0xFF991B1B); // Dark red alert text
  static const Color warningLight = Color(
    0xFFFFFBEB,
  ); // Light amber container background
  static const Color warningBorder = Color(
    0xFFFDE68A,
  ); // Light amber container border
  static const Color warningIcon = Color(0xFFD97706); // Warning icon color
  static const Color warningTextDark = Color(0xFF92400E); // Warning text dark
  static const Color successLight = Color(
    0xFFECFDF5,
  ); // Light emerald success background
  static const Color successBorder = Color(
    0xFFA7F3D0,
  ); // Light emerald success border
  static const Color successIcon = Color(0xFF059669); // Success icon color
  static const Color successTextDark = Color(
    0xFF065F46,
  ); // Dark emerald success text

  // Subtle Border
  static Border subtleBorder = Border.all(color: borderColor, width: 1.w);

  // Card Decoration matching the screenshots (Soft shadow, rounded corners, white background)
  static BoxDecoration cardDecoration({
    Color color = surface,
    double borderRadius = 24, // Screenshots feature highly rounded corners
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius.r),
      border: Border.all(color: borderColor, width: 1.w),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Active / Selected Button Style (Solid Dark)
  static ButtonStyle activeButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
    textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
  );

  // Inactive / Unselected Button Style (Light Grey, dark text)
  static ButtonStyle inactiveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: inactiveBg,
    foregroundColor: textPrimary,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
    textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
  );

  // Outlined Button Style (Subtle Border)
  static ButtonStyle outlinedButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: textPrimary,
    side: const BorderSide(color: borderColor, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
    padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
    textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
  );

  // Dark mode background/surface constants
  static const Color darkBackground = Color(0xFF0F1117); // Very dark navy
  static const Color darkSurface = Color(0xFF1A1D27);   // Dark card surface
  static const Color darkBorder = Color(0xFF2A2D3A);    // Subtle dark border
  static const Color darkTextPrimary = Color(0xFFF1F5F9); // Near white
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkInactiveBg = Color(0xFF1E2230); // Dark inactive bg

  // Main light theme definition
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: royalBlue,
        secondary: accent,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          displayLarge: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          bodyLarge: TextStyle(fontSize: 16.sp, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14.sp, color: textSecondary),
          labelLarge: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      useMaterial3: true,
    );
  }

  // Dark theme definition
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: royalBlue,
      colorScheme: const ColorScheme.dark(
        primary: royalBlue,
        secondary: violet,
        surface: darkSurface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          headlineLarge: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          titleLarge: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
          bodyLarge: TextStyle(fontSize: 16.sp, color: darkTextPrimary),
          bodyMedium: TextStyle(fontSize: 14.sp, color: darkTextSecondary),
          labelLarge: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: darkTextPrimary,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.inter(
          color: darkTextPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkSurface,
      ),
      dividerColor: darkBorder,
      useMaterial3: true,
    );
  }

  // Parameterized text style helpers
  static TextStyle outfit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
