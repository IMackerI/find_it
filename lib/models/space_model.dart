import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'item_model.dart';

class SpaceModel {
  final String id;
  Offset position = Offset.zero;
  Size size = Size.zero;
  String name;
  bool isSelected = false;
  SpaceModel? parent;
  List<SpaceModel> mySpaces;
  List<ItemModel> items;

  static List<SpaceModel> currentSpaces = [];
  static SpaceStorage? _storage;

  static void configureStorage(SpaceStorage storage) {
    _storage = storage;
  }

  static SpaceStorage get _spaceStorage {
    final storage = _storage;
    if (storage == null) {
      throw StateError('Space storage has not been configured.');
    }
    return storage;
  }

  SpaceModel({
    String? id,
    required this.name,
    this.position = Offset.zero,
    this.size = Size.zero,
    List<SpaceModel>? mySpaces,
    List<ItemModel>? items,
    this.parent,
  })  : id = id ?? const Uuid().v4(),
        mySpaces = List<SpaceModel>.from(mySpaces ?? const []),
        items = List<ItemModel>.from(items ?? const []);

  Map<dynamic, dynamic> toJson() => {
        'id': id,
        'name': name,
        'position': {
          'dx': position.dx,
          'dy': position.dy,
        },
        'size': {
          'width': size.width,
          'height': size.height,
        },
        'mySpaces': mySpaces.map((space) => space.toJson()).toList(),
        'items': items.map((item) => item.toJson()).toList(),
      };

  static SpaceModel fromJson(Map<dynamic, dynamic> json) {
    SpaceModel ret = SpaceModel(
      id: json['id'],
      name: json['name'],
      position: Offset(json['position']['dx'], json['position']['dy']),
      size: Size(json['size']['width'], json['size']['height']),
      mySpaces: json['mySpaces'] != null
          ? List<SpaceModel>.from(
              (json['mySpaces'] as List<dynamic>)
                  .map((spaceJson) => SpaceModel.fromJson(spaceJson)),
            )
          : [],
      items: json['items'] != null
          ? List<ItemModel>.from(
              (json['items'] as List<dynamic>)
                  .map((itemJson) => ItemModel.fromJson(itemJson)),
            )
          : [],
    );
    for (var space in ret.mySpaces) {
      space.parent = ret;
    }
    for (var item in ret.items) {
      item.parent = ret;
    }
    return ret;
  }

  void assignParents() {
    for (var space in mySpaces) {
      space.parent = this;
      space.assignParents();
    }
    for (var item in items) {
      item.parent = this;
    }
  }

  bool get isRoot => parent == null;
  bool get isDrawer => parent?.parent != null;
  
  void _prepareForPersistence() {
    mySpaces = List<SpaceModel>.from(mySpaces);
    items = List<ItemModel>.from(items);

    double sanitizeCoordinate(double value) {
      if (!value.isFinite) {
        return 0;
      }
      const double limit = 5000;
      if (value > limit) {
        return limit;
      }
      if (value < -limit) {
        return -limit;
      }
      return value;
    }

    double sanitizeDimension({
      required double value,
      required double fallback,
      required double min,
      required double max,
    }) {
      if (!value.isFinite || value <= 0) {
        return fallback;
      }
      if (value < min) {
        return min;
      }
      if (value > max) {
        return max;
      }
      return value;
    }

    double sanitizeRootDimension(double value) {
      if (!value.isFinite || value < 0) {
        return 0;
      }
      const double limit = 10000;
      if (value > limit) {
        return limit;
      }
      return value;
    }

    position = Offset(
      sanitizeCoordinate(position.dx),
      sanitizeCoordinate(position.dy),
    );

    if (isRoot) {
      size = Size(
        sanitizeRootDimension(size.width),
        sanitizeRootDimension(size.height),
      );
    } else {
      final bool drawer = isDrawer;
      final double fallback = drawer ? 40 : 120;
      final double minDimension = drawer ? 10 : 50;
      final double maxDimension = drawer ? 300 : 600;
      size = Size(
        sanitizeDimension(
          value: size.width,
          fallback: fallback,
          min: minDimension,
          max: maxDimension,
        ),
        sanitizeDimension(
          value: size.height,
          fallback: fallback,
          min: minDimension,
          max: maxDimension,
        ),
      );
    }

    for (final space in mySpaces) {
      space.parent = this;
      space._prepareForPersistence();
    }
    for (final item in items) {
      item.parent = this;
    }
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  static Future<bool> saveItems() async {
    try {
      currentSpaces = List<SpaceModel>.from(currentSpaces);
      for (final space in currentSpaces) {
        space._prepareForPersistence();
      }
      await _spaceStorage.saveSpaces(currentSpaces);
      debugPrint('items saved');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Failed to save items: $e\n$stackTrace');
      return false;
    }
  }

  static Future<void> loadItems() async {
    try {
      currentSpaces = await _spaceStorage.loadSpaces();
      if (currentSpaces.isEmpty) {
        final migratedSpaces = await _loadFromLegacyFile();
        if (migratedSpaces.isNotEmpty) {
          currentSpaces = migratedSpaces;
          await _spaceStorage.saveSpaces(currentSpaces);
        }
      }
      for (final space in currentSpaces) {
        space.assignParents();
      }
      debugPrint('items loaded');
    } catch (e, stackTrace) {
      debugPrint('Failed to load items: $e\n$stackTrace');
      currentSpaces = [];
    }
  }

  static Future<List<SpaceModel>> _loadFromLegacyFile() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        return [];
      }
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) {
        return [];
      }
      final dynamic jsonData = jsonDecode(contents);
      if (jsonData is! List) {
        return [];
      }
      final spaces = jsonData
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => SpaceModel.fromJson(item))
          .toList();
      for (final space in spaces) {
        space._prepareForPersistence();
      }
      debugPrint('items loaded from legacy json');
      return spaces;
    } catch (e, stackTrace) {
      debugPrint('Failed to load legacy items: $e\n$stackTrace');
      return [];
    }
  }
}

abstract class SpaceStorage {
  Future<void> saveSpaces(List<SpaceModel> spaces);
  Future<List<SpaceModel>> loadSpaces();
}
