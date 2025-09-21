import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.themeController});

  final AppThemeController themeController;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dataReloaded = false;

  ThemeMode get _currentMode => widget.themeController.themeMode;
  Color get _currentAccent => widget.themeController.seedColor;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop(_dataReloaded);
            SpaceModel.saveItems();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          Text(
            'Appearance',
            style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme mode',
                  style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.auto_awesome_outlined),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.wb_sunny_outlined),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.nightlight_round),
                    ),
                  ],
                  selected: <ThemeMode>{_currentMode},
                  onSelectionChanged: (newSelection) {
                    final mode = newSelection.first;
                    widget.themeController.updateThemeMode(mode);
                    HapticFeedback.selectionClick();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Accent color',
                  style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final color in AppThemeController.accentChoices)
                      _AccentOption(
                        color: color,
                        isSelected: color.value == _currentAccent.value,
                        onTap: () {
                          widget.themeController.updateSeedColor(color);
                          HapticFeedback.lightImpact();
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Data',
            style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.file_upload_outlined,
                  title: 'Export data',
                  subtitle: 'Save all spaces and items to a JSON file',
                  onTap: _exportData,
                ),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.file_download_outlined,
                  title: 'Import data',
                  subtitle: 'Load spaces and items from a JSON file',
                  onTap: _importData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    HapticFeedback.selectionClick();
    try {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) {
        _showMessage('No directory selected');
        return;
      }
      final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('$directory/spaces_$formattedDate.json');
      final jsonData = SpaceModel.currentSpaces.map((space) => space.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));
      _showMessage('Data exported to ${file.path}');
    } catch (error) {
      _showMessage('Failed to export data: $error');
    }
  }

  Future<void> _importData() async {
    HapticFeedback.selectionClick();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (result == null) {
        _showMessage('No file selected');
        return;
      }
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final jsonList = jsonDecode(content) as List<dynamic>;
      SpaceModel.currentSpaces =
          jsonList.map((data) => SpaceModel.fromJson(data as Map<String, dynamic>)).toList();
      await SpaceModel.saveItems();
      setState(() {
        _dataReloaded = true;
      });
      _showMessage('Data loaded from ${file.path}');
    } catch (error) {
      _showMessage('Failed to load data: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.surfaceComponent,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Feedback.forTap(context);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    colors.primary.withOpacity(0.12),
                    context.palette.surfaceComponent,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textStyles.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentOption extends StatelessWidget {
  const _AccentOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
          border: Border.all(
            color: isSelected ? colors.onPrimary : Colors.transparent,
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: isSelected
            ? Icon(Icons.check_rounded, color: colors.onPrimary, size: 24)
            : null,
      ),
    );
  }
}
