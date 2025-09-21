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
    'position': {'dx': position.dx, 'dy': position.dy},
    'size': {'width': size.width, 'height': size.height},
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

  void assignParents(){
    for (var space in mySpaces) {
      space.parent = this;
      space.assignParents();
    }
    for (var item in items) {
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

  static Future<void> saveItems() async {
    final file = await _localFile;
    await file.writeAsString(jsonEncode(currentSpaces.map((space) => space.toJson()).toList()));
    print(jsonEncode(currentSpaces.map((space) => space.toJson()).toList()));
    print("items saved");
  }

  static Future<void> loadItems() async {
    final file = await _localFile;
    if (!file.existsSync()) {
      return;
    }
    final contents = await file.readAsString();
    final List<dynamic> jsonData = jsonDecode(contents);
    currentSpaces = jsonData.map((item) => SpaceModel.fromJson(item)).toList();
    print(jsonData);
    print("items loaded");
  }
}