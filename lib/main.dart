import 'dart:async';

import 'package:flutter/material.dart';

import 'data/spaces_repository.dart';
import 'models/space_model.dart';
import 'pages/home.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SpaceModel.configureStorage(SpacesRepository());
  await SpaceModel.loadItems();

  final themeController = ThemeController();
  runApp(FindItApp(themeController: themeController));
}

class FindItApp extends StatefulWidget {
  const FindItApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<FindItApp> createState() => _FindItAppState();
}

class _FindItAppState extends State<FindItApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(SpaceModel.saveItems());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeController,
      builder: (context, _) {
        final appTheme = AppTheme(settings: widget.themeController.settings);
        return ThemeControllerProvider(
          controller: widget.themeController,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme.light(),
            darkTheme: appTheme.dark(),
            themeMode: widget.themeController.themeMode,
            home: const HomePage(),
          ),
        );
      },
    );
  }
}
