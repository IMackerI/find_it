import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:find_it/models/item_model.dart';
import 'package:path_provider/path_provider.dart';

class SpaceModel {
  Offset position = Offset.zero;
  Size size = Size.zero;
  String name;
  bool isSelected = false;
  SpaceModel? parent;
  List<SpaceModel> mySpaces;
  List<ItemModel> items;

  static List<SpaceModel> currentSpaces = [];

  SpaceModel({
    required this.name,
    this.position = Offset.zero,
    this.size = Size.zero,
    List<SpaceModel>? mySpaces,
    List<ItemModel>? items,
    this.parent,
  })  : mySpaces = List<SpaceModel>.from(mySpaces ?? const []),
        items = List<ItemModel>.from(items ?? const []);

  Map<dynamic, dynamic> toJson() => {
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

  void _prepareForPersistence() {
    mySpaces = List<SpaceModel>.from(mySpaces);
    items = List<ItemModel>.from(items);

    bool get isRoot => parent == null;
    bool get isDrawer => parent?.parent != null;

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
      final file = await _localFile;
      final payload =
          jsonEncode(currentSpaces.map((space) => space.toJson()).toList());
      await file.writeAsString(payload);
      debugPrint('items saved');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Failed to save items: $e\n$stackTrace');
      return false;
    }
  }

  static Future<void> loadItems() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        currentSpaces = [];
        return;
      }
      final contents = await file.readAsString();
      if (contents.trim().isEmpty) {
        currentSpaces = [];
        return;
      }
      final dynamic jsonData = jsonDecode(contents);
      if (jsonData is! List) {
        currentSpaces = [];
        return;
      }
      currentSpaces = jsonData
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => SpaceModel.fromJson(item))
          .toList();
      for (final space in currentSpaces) {
        space._prepareForPersistence();
      }
      debugPrint('items loaded');
    } catch (e, stackTrace) {
      debugPrint('Failed to load items: $e\n$stackTrace');
      currentSpaces = [];
    }
  }
}