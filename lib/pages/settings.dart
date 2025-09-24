import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:find_it/models/space_model.dart';
import 'package:find_it/theme/app_theme.dart';
import 'package:find_it/theme/theme_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    final controller = ThemeControllerProvider.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/Arrow - Left 2.svg',
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () async {
            HapticFeedback.selectionClick();
            final saved = await SpaceModel.saveItems();
            if (!mounted) return;
            if (!saved) {
              _showSaveFailure();
              return;
            }
            Navigator.of(context).pop(_loaded);
            _loaded = false;
          },
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: extras.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SettingsCard(
                icon: Icons.palette_outlined,
                title: 'Theme',
                children: [
                  Text(
                    'Choose how Find It looks and feels. Changes apply instantly.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: extras.subtleText),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded), label: Text('System')),
                      ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.wb_sunny_rounded), label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.nights_stay_rounded), label: Text('Dark')),
                    ],
                    selected: <ThemeMode>{controller.themeMode},
                    onSelectionChanged: (value) {
                      final mode = value.first;
                      HapticFeedback.selectionClick();
                      controller.updateThemeMode(mode);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Accent colour',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ThemeController.seedPalette.map((color) {
                      final bool isSelected = controller.seedColor.value == color.value;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.updateSeedColor(color);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: isSelected ? 52 : 44,
                          height: isSelected ? 52 : 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : extras.borderColor.withOpacity(0.6),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                                spreadRadius: -8,
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: theme.colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              _SettingsCard(
                icon: Icons.storage_rounded,
                title: 'Data',
                children: [
                  Text(
                    'Back up or restore your spaces. Imports replace your current data.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: extras.subtleText),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: const Text('Export spaces'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _importData,
                    icon: const Icon(Icons.file_download_outlined),
                    label: const Text('Import spaces'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    HapticFeedback.lightImpact();
    try {
      String? directory = await FilePicker.platform.getDirectoryPath();
      if (directory != null) {
        String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final file = File('$directory/spaces_$formattedDate.json');
        final json = SpaceModel.currentSpaces.map((space) => space.toJson()).toList();
        await file.writeAsString(jsonEncode(json));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to ${file.path}')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No directory selected')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export data: $e'),
          duration: const Duration(seconds: 30),
        ),
      );
    }
  }

  Future<void> _importData() async {
    HapticFeedback.lightImpact();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        List<dynamic> json = jsonDecode(content);
        final importedSpaces =
            json.map((data) => SpaceModel.fromJson(data)).toList();
        SpaceModel.updateCurrentSpaces(importedSpaces);
        final saved = await SpaceModel.saveItems();
        if (!mounted) return;
        if (!saved) {
          _showSaveFailure();
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data loaded from ${file.path}')),
        );
        setState(() {
          _loaded = true;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $e')),
      );
    }
  }

  void _showSaveFailure() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('We couldn\'t save your spaces. Please try again.'),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: extras.glassBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: extras.shadowColor,
            blurRadius: 22,
            offset: const Offset(0, 12),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
