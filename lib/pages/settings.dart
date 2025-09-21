import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dataLoaded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            AppHaptics.selection();
            Navigator.of(context).pop(_dataLoaded);
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const maxWidth = 640.0;
            final horizontalPadding = constraints.maxWidth > maxWidth
                ? (constraints.maxWidth - maxWidth) / 2
                : 20.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 24),
              children: [
                Text(
                  'Appearance',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<ThemeConfig>(
                  valueListenable: themeController,
                  builder: (context, activeTheme, _) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: activeTheme.palette.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.palette_rounded,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Theme',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pick a palette to customise the look and feel.',
                                    style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedForeground),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<ThemeConfig>(
                                value: activeTheme,
                                alignment: Alignment.centerLeft,
                                onChanged: (config) async {
                                  if (config == null) return;
                                  await AppHaptics.selection();
                                  themeController.value = config;
                                },
                                items: AppThemes.presets
                                    .map(
                                      (config) => DropdownMenuItem(
                                        value: config,
                                        child: Text(config.name),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Data',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: _TileIcon(icon: Icons.file_upload_outlined, palette: palette, theme: theme),
                    title: const Text('Export data'),
                    subtitle: const Text('Save a JSON backup of your spaces.'),
                    onTap: _exportData,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: _TileIcon(icon: Icons.file_download_outlined, palette: palette, theme: theme),
                    title: const Text('Import data'),
                    subtitle: const Text('Load a previously exported backup.'),
                    onTap: _importData,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    await AppHaptics.selection();
    try {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No directory selected')),
        );
        return;
      }

      final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('$directory/spaces_$formattedDate.json');
      final json = SpaceModel.currentSpaces.map((space) => space.toJson()).toList();
      await file.writeAsString(jsonEncode(json));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data exported to ${file.path}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export data: $error')),
      );
    }
  }

  Future<void> _importData() async {
    await AppHaptics.selection();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );

      if (result == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
        return;
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final List<dynamic> json = jsonDecode(content);
      SpaceModel.currentSpaces = json.map((data) => SpaceModel.fromJson(data)).toList();
      await SpaceModel.saveItems();

      if (!mounted) return;
      setState(() {
        _dataLoaded = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data loaded from ${file.path}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $error')),
      );
    }
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({
    required this.icon,
    required this.palette,
    required this.theme,
  });

  final IconData icon;
  final AppPalette palette;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: palette.surfaceTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.outlineMuted),
      ),
      child: Icon(icon, color: theme.colorScheme.primary),
    );
  }
}
