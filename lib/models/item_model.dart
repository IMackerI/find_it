import 'package:find_it/colors.dart';
import 'package:flutter/material.dart';
import 'space_model.dart';

class ItemModel {
  String name;
  String description;
  String? locationSpecification;
  List<String>? tags;
  String? imagePath;

  SpaceModel? parent;
  static const List<Icon> defaultIcons = [
    Icon(Icons.key, color: AppColors.iconColor),
    Icon(Icons.toys, color: AppColors.iconColor),
    Icon(Icons.restaurant, color: AppColors.iconColor),
    Icon(Icons.work, color: AppColors.iconColor),
    Icon(Icons.apple, color: AppColors.iconColor),
    Icon(Icons.plumbing, color: AppColors.iconColor),
    Icon(Icons.electrical_services, color: AppColors.iconColor),
    Icon(Icons.blur_circular, color: AppColors.iconColor),
    Icon(Icons.interests, color: AppColors.iconColor),
    Icon(Icons.vpn_key, color: AppColors.iconColor),
    Icon(Icons.bed, color: AppColors.iconColor),
    Icon(Icons.dining, color: AppColors.iconColor),
    Icon(Icons.kitchen, color: AppColors.iconColor),
    Icon(Icons.tv, color: AppColors.iconColor),
    Icon(Icons.computer, color: AppColors.iconColor),
    Icon(Icons.watch, color: AppColors.iconColor),
    Icon(Icons.headset, color: AppColors.iconColor),
    Icon(Icons.speaker, color: AppColors.iconColor),
    Icon(Icons.lightbulb, color: AppColors.iconColor),
    Icon(Icons.ac_unit, color: AppColors.iconColor),
    Icon(Icons.local_florist, color: AppColors.iconColor),
    Icon(Icons.local_pharmacy, color: AppColors.iconColor),
    Icon(Icons.local_fire_department, color: AppColors.iconColor),
    Icon(Icons.local_atm, color: AppColors.iconColor),
    Icon(Icons.local_grocery_store, color: AppColors.iconColor),
    Icon(Icons.local_hospital, color: AppColors.iconColor),
    Icon(Icons.local_cafe, color: AppColors.iconColor),
    Icon(Icons.local_bar, color: AppColors.iconColor),
    Icon(Icons.local_movies, color: AppColors.iconColor),
    Icon(Icons.local_offer, color: AppColors.iconColor),
    Icon(Icons.local_mall, color: AppColors.iconColor),
    Icon(Icons.local_library, color: AppColors.iconColor),
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