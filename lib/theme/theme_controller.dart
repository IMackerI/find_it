import 'package:flutter/material.dart';

const Color _defaultSeedColor = Color(0xFF5663FF);

class ThemeSettings {
  const ThemeSettings({
    this.themeMode = ThemeMode.system,
    this.seedColor = _defaultSeedColor,
  });

  final ThemeMode themeMode;
  final Color seedColor;

  ThemeSettings copyWith({ThemeMode? themeMode, Color? seedColor}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

class ThemeController extends ChangeNotifier {
  ThemeController({ThemeSettings? settings})
      : _settings = settings ?? const ThemeSettings();

  ThemeSettings _settings;

  ThemeSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  Color get seedColor => _settings.seedColor;

  void updateThemeMode(ThemeMode mode) {
    if (_settings.themeMode == mode) return;
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
  }

  void updateSeedColor(Color color) {
    if (_settings.seedColor.value == color.value) return;
    _settings = _settings.copyWith(seedColor: color);
    notifyListeners();
  }

  static const List<Color> seedPalette = <Color>[
    Color(0xFF5663FF),
    Color(0xFF2CB1BC),
    Color(0xFFEF8354),
    Color(0xFF8E7DFF),
    Color(0xFF4CAF50),
    Color(0xFFFFB400),
  ];
}

class ThemeControllerProvider extends InheritedNotifier<ThemeController> {
  const ThemeControllerProvider({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final ThemeControllerProvider? provider =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    assert(provider != null, 'No ThemeControllerProvider found in context');
    return provider!.notifier!;
  }
}
