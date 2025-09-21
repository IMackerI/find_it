import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:find_it/models/item_model.dart';
import 'models/space_model.dart';

import 'pages/home.dart';
//import 'pages/search.dart';
//import 'pages/room.dart';

void main() async {
  // Ensure binding
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance!.addPostFrameCallback((_) {
    // Load data after hot restart
    SpaceModel.loadItems();
  });

  // Add lifecycle observer
  WidgetsBinding.instance!.addObserver(MyApp());

  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
    const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: HomePage(),
    );
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        // App is paused, save items
        SpaceModel.saveItems();
        break;
      default:
        break;
    }
  }
}
