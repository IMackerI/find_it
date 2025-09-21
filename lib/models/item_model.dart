import 'package:flutter/material.dart';
import 'space_model.dart';

class ItemModel {
  String name;
  String description;
  String? locationSpecification;
  List<String>? tags;
  String? imagePath;

  SpaceModel? parent;
  static const List<IconData> defaultIcons = [
    Icons.key,
    Icons.toys_outlined,
    Icons.restaurant,
    Icons.work_outline,
    Icons.apple,
    Icons.plumbing,
    Icons.electrical_services,
    Icons.blur_circular,
    Icons.interests,
    Icons.vpn_key,
    Icons.bed_outlined,
    Icons.dining_outlined,
    Icons.kitchen,
    Icons.tv,
    Icons.computer,
    Icons.watch_outlined,
    Icons.headset,
    Icons.speaker_outlined,
    Icons.lightbulb_outline,
    Icons.ac_unit,
    Icons.local_florist,
    Icons.local_pharmacy,
    Icons.local_fire_department,
    Icons.local_atm,
    Icons.local_grocery_store,
    Icons.local_hospital,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.local_movies,
    Icons.local_offer,
    Icons.local_mall,
    Icons.local_library,
  ];

  ItemModel({
    required this.name,
    required this.description,
    this.locationSpecification,
    this.tags,
    this.imagePath,
    this.parent,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      name: json['name'],
      description: json['description'],
      locationSpecification: json['locationSpecification'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'locationSpecification': locationSpecification,
      'tags': tags,
      'imagePath': imagePath,
    };
  }
}