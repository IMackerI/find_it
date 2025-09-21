import 'package:flutter/material.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController({ThemeMode initialMode = ThemeMode.system, Color? seedColor})
      : _themeMode = initialMode,
        _seedColor = seedColor ?? const Color(0xFF5662F6);

  ThemeMode _themeMode;
  Color _seedColor;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  static const List<Color> accentChoices = <Color>[
    Color(0xFF5662F6),
    Color(0xFF6C63FF),
    Color(0xFF00BFA5),
    Color(0xFFFF6F61),
    Color(0xFFFB8C00),
    Color(0xFF00ACC1),
  ];

  void updateThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void updateSeedColor(Color color) {
    if (_seedColor == color) return;
    _seedColor = color;
    notifyListeners();
  }

  ThemeData get lightTheme => _buildTheme(Brightness.light);
  ThemeData get darkTheme => _buildTheme(Brightness.dark);

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final palette = AppPalette.from(colorScheme);

    return theme.copyWith(
      extensions: <ThemeExtension<dynamic>>[palette],
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: palette.surfaceElevated,
        margin: EdgeInsets.zero,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceComponent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: BorderSide(color: palette.outlineSoft),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: palette.surfaceComponent,
        selectedTileColor: Color.alphaBlend(
          colorScheme.primary.withOpacity(0.12),
          palette.surfaceComponent,
        ),
        iconColor: colorScheme.primary,
      ),
      dividerTheme: DividerThemeData(
        color: palette.outlineSoft,
        thickness: 1,
        space: 24,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surfaceElevated,
        indicatorColor: Color.alphaBlend(
          colorScheme.primary.withOpacity(0.2),
          palette.surfaceElevated,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => theme.textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.surfaceElevated,
        contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      chipTheme: theme.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        side: BorderSide(color: palette.outlineSoft),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surfaceElevated,
        surfaceTintColor: palette.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.surfaceComponent,
    required this.surfaceElevated,
    required this.outlineSoft,
  });

  final Color surfaceComponent;
  final Color surfaceElevated;
  final Color outlineSoft;

  factory AppPalette.from(ColorScheme scheme) {
    final componentBase = Color.alphaBlend(
      scheme.primary.withOpacity(scheme.brightness == Brightness.dark ? 0.18 : 0.08),
      scheme.surface,
    );
    final elevatedBase = Color.alphaBlend(
      scheme.primary.withOpacity(scheme.brightness == Brightness.dark ? 0.16 : 0.06),
      scheme.surface,
    );
    return AppPalette(
      surfaceComponent: componentBase,
      surfaceElevated: elevatedBase,
      outlineSoft: scheme.outlineVariant,
    );
  }

  @override
  ThemeExtension<AppPalette> copyWith({
    Color? surfaceComponent,
    Color? surfaceElevated,
    Color? outlineSoft,
  }) {
    return AppPalette(
      surfaceComponent: surfaceComponent ?? this.surfaceComponent,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      outlineSoft: outlineSoft ?? this.outlineSoft,
    );
  }

  @override
  ThemeExtension<AppPalette> lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    return AppPalette(
      surfaceComponent: Color.lerp(surfaceComponent, other.surfaceComponent, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      outlineSoft: Color.lerp(outlineSoft, other.outlineSoft, t)!,
    );
  }
}

extension ThemeContextX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
}
