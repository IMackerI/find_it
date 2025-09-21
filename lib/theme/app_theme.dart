import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primaryGradient,
    required this.surfaceTint,
    required this.outlineMuted,
    required this.elevatedSurface,
    required this.mutedForeground,
  });

  final LinearGradient primaryGradient;
  final Color surfaceTint;
  final Color outlineMuted;
  final Color elevatedSurface;
  final Color mutedForeground;

  @override
  AppPalette copyWith({
    LinearGradient? primaryGradient,
    Color? surfaceTint,
    Color? outlineMuted,
    Color? elevatedSurface,
    Color? mutedForeground,
  }) {
    return AppPalette(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      surfaceTint: surfaceTint ?? this.surfaceTint,
      outlineMuted: outlineMuted ?? this.outlineMuted,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      mutedForeground: mutedForeground ?? this.mutedForeground,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t) ?? primaryGradient,
      surfaceTint: Color.lerp(surfaceTint, other.surfaceTint, t) ?? surfaceTint,
      outlineMuted: Color.lerp(outlineMuted, other.outlineMuted, t) ?? outlineMuted,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t) ?? elevatedSurface,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t) ?? mutedForeground,
    );
  }
}

class ThemeConfig {
  const ThemeConfig({
    required this.name,
    required this.colorScheme,
    required this.palette,
  });

  final String name;
  final ColorScheme colorScheme;
  final AppPalette palette;

  ThemeData toThemeData() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: ThemeData(brightness: colorScheme.brightness).textTheme.apply(
            fontFamily: 'Poppins',
            bodyColor: colorScheme.onBackground,
            displayColor: colorScheme.onBackground,
          ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: colorScheme.onSurface,
        ),
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardTheme(
        color: palette.elevatedSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceTint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.outlineMuted, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: palette.outlineMuted, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        labelStyle: TextStyle(color: palette.mutedForeground),
        hintStyle: TextStyle(color: palette.mutedForeground),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontFamily: 'Poppins',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: palette.elevatedSurface,
        iconColor: colorScheme.primary,
        textColor: colorScheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      dividerTheme: DividerThemeData(color: palette.outlineMuted, space: 0),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceTint,
        selectedColor: colorScheme.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        side: BorderSide(color: palette.outlineMuted),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      extensions: <ThemeExtension<dynamic>>[palette],
    );

    return base;
  }
}

class AppThemes {
  AppThemes._();

  static final ThemeConfig sunrise = ThemeConfig(
    name: 'Sunrise Glow',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF8F7FF),
      background: const Color(0xFFF2F4FF),
      secondary: const Color(0xFF6E8FFF),
      tertiary: const Color(0xFFEA5C79),
    ),
    palette: const AppPalette(
      primaryGradient: LinearGradient(
        colors: [Color(0xFF7A74F7), Color(0xFF6CCBFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      surfaceTint: Color(0xFFFFFFFF),
      outlineMuted: Color(0xFFE2E6FF),
      elevatedSurface: Color(0xFFFFFFFF),
      mutedForeground: Color(0xFF6E7191),
    ),
  );

  static final ThemeConfig evergreen = ThemeConfig(
    name: 'Evergreen Calm',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0B8A6B),
      brightness: Brightness.light,
    ).copyWith(
      surface: const Color(0xFFF3FBF8),
      background: const Color(0xFFEFF7F4),
      secondary: const Color(0xFF54B397),
      tertiary: const Color(0xFF3F7CAC),
    ),
    palette: const AppPalette(
      primaryGradient: LinearGradient(
        colors: [Color(0xFF1FA678), Color(0xFF6ADBC7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      surfaceTint: Color(0xFFFFFFFF),
      outlineMuted: Color(0xFFCFE7DE),
      elevatedSurface: Color(0xFFFFFFFF),
      mutedForeground: Color(0xFF4F6F6B),
    ),
  );

  static final List<ThemeConfig> presets = [sunrise, evergreen];
}

final ValueNotifier<ThemeConfig> themeController = ValueNotifier<ThemeConfig>(AppThemes.sunrise);
