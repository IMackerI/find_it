import 'dart:async';

import 'package:flutter/material.dart';

import 'data/local_database.dart';
import 'data/remote/remote_api_client.dart';
import 'data/spaces_repository.dart';
import 'data/sync_service.dart';
import 'models/space_model.dart';
import 'pages/home.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = LocalDatabase();
  final repository = SpacesRepository(database: database);
  SpaceModel.configureStorage(repository);
  await SpaceModel.loadItems();

  const syncBaseUrl = String.fromEnvironment(
    'FIND_IT_SYNC_URL',
    defaultValue: '',
  );
  SyncService? syncService;
  if (syncBaseUrl.isNotEmpty) {
    final remoteApiClient = createHttpRemoteApiClient(baseUrl: syncBaseUrl);
    syncService = SyncService(
      database: database,
      apiClient: remoteApiClient,
    );
  }

  final themeController = ThemeController();
  runApp(
    FindItApp(
      themeController: themeController,
      syncService: syncService,
    ),
  );
}

class FindItApp extends StatefulWidget {
  const FindItApp({
    super.key,
    required this.themeController,
    this.syncService,
  });

  final ThemeController themeController;
  final SyncService? syncService;

  @override
  State<FindItApp> createState() => _FindItAppState();
}

class _FindItAppState extends State<FindItApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.syncService?.start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.syncService?.dispose();
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
