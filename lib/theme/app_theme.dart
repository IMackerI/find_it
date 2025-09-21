import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme_controller.dart';

class AppTheme {
  const AppTheme({required this.settings});

  final ThemeSettings settings;

  ThemeData light() => _themeFor(Brightness.light);

  ThemeData dark() => _themeFor(Brightness.dark);

  ThemeData _themeFor(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: settings.seedColor,
      brightness: brightness,
    );
    final extras = AppThemeColors.from(colorScheme, brightness);

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:
            brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: colorScheme.surface.withOpacity(brightness == Brightness.dark ? 0.7 : 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extras.glassBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: extras.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: extras.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            colorScheme.surface.withOpacity(brightness == Brightness.dark ? 0.95 : 0.9),
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: extras.glassBackground,
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        backgroundColor: extras.glassBackground,
        selectedColor:
            colorScheme.primaryContainer.withOpacity(brightness == Brightness.dark ? 0.8 : 1),
        side: BorderSide(color: extras.borderColor),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withOpacity(0.5),
        thickness: 1,
        space: 24,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceVariant;
        }),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: extras.glassBackground,
        iconColor: colorScheme.primary,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[
        extras,
      ],
    );
  }
}

class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.backgroundGradient,
    required this.cardGradient,
    required this.glassBackground,
    required this.borderColor,
    required this.shadowColor,
    required this.subtleText,
  });

  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final Color glassBackground;
  final Color borderColor;
  final Color shadowColor;
  final Color subtleText;

  factory AppThemeColors.from(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppThemeColors(
      backgroundGradient: LinearGradient(
        colors: [
          scheme.primaryContainer.withOpacity(isDark ? 0.2 : 0.45),
          scheme.surface.withOpacity(isDark ? 0.7 : 0.9),
          scheme.background,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      cardGradient: LinearGradient(
        colors: [
          scheme.primaryContainer.withOpacity(isDark ? 0.55 : 0.95),
          scheme.secondaryContainer.withOpacity(isDark ? 0.35 : 0.65),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      glassBackground: Color.lerp(
        scheme.surface.withOpacity(isDark ? 0.85 : 0.9),
        scheme.background.withOpacity(isDark ? 0.7 : 0.6),
        0.5,
      )!,
      borderColor: scheme.outlineVariant.withOpacity(isDark ? 0.8 : 0.5),
      shadowColor: scheme.shadow.withOpacity(isDark ? 0.5 : 0.2),
      subtleText: scheme.onSurface.withOpacity(0.7),
    );
  }

  @override
  AppThemeColors copyWith({
    LinearGradient? backgroundGradient,
    LinearGradient? cardGradient,
    Color? glassBackground,
    Color? borderColor,
    Color? shadowColor,
    Color? subtleText,
  }) {
    return AppThemeColors(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      glassBackground: glassBackground ?? this.glassBackground,
      borderColor: borderColor ?? this.borderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      subtleText: subtleText ?? this.subtleText,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }
    return AppThemeColors(
      backgroundGradient: LinearGradient.lerp(backgroundGradient, other.backgroundGradient, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
    );
  }
}
