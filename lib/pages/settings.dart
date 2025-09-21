import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:find_it/models/space_model.dart';
import 'package:find_it/colors.dart';
import 'package:flutter_svg/svg.dart';

class SettingsPage extends StatelessWidget {
  bool loaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  String? directory = await FilePicker.platform.getDirectoryPath();
                  if (directory != null) {
                    String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
                    final file = File('$directory/spaces_$formattedDate.json');
                    final json = SpaceModel.currentSpaces.map((space) => space.toJson()).toList();
                    await file.writeAsString(jsonEncode(json));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data exported to ${file.path}')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No directory selected')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to export data: $e'), duration: Duration(seconds: 30),),
                  );
                }
              },
              child: Text('Export Data'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    String content = await file.readAsString();
                    List<dynamic> json = jsonDecode(content);
                    SpaceModel.currentSpaces = json.map((data) => SpaceModel.fromJson(data)).toList();
                    await SpaceModel.saveItems();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data loaded from ${file.path}')),
                    );
                    loaded = true;
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No file selected')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load data: $e')),
                  );
                }
              },
              child: Text('Load Data'),
            ),
          ],
        ),
      ),
    );
  }
  
  
  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Settings',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      leading: GestureDetector(
      onTap: () {
        Navigator.of(context).pop(loaded);
        loaded = false;
        SpaceModel.saveItems();
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        width: 40,
        decoration: BoxDecoration(
          color: AppColors.iconBackground,
          borderRadius: BorderRadius.circular(10)
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset('assets/icons/Arrow - Left 2.svg'),
        ),
      ),
    ),
    );
  }
}