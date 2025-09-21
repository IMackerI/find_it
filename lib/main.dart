import 'package:flutter/material.dart';

import 'models/space_model.dart';
import 'pages/home.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(themeController: AppThemeController()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SpaceModel.loadItems();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeController,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: widget.themeController.lightTheme,
        darkTheme: widget.themeController.darkTheme,
        themeMode: widget.themeController.themeMode,
        home: HomePage(themeController: widget.themeController),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      SpaceModel.saveItems();
    }
  }
}
