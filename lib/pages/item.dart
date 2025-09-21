import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item_model.dart';
import '../models/space_model.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';

class ItemDisplayPage extends StatefulWidget {
  const ItemDisplayPage({super.key, required this.item});

  final ItemModel item;

  @override
  State<ItemDisplayPage> createState() => _ItemDisplayPageState();
}

class _ItemDisplayPageState extends State<ItemDisplayPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  String? _imagePath;
  SpaceModel? _parentSpace;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description);
    _locationController = TextEditingController(text: widget.item.locationSpecification);
    _imagePath = widget.item.imagePath;
    _parentSpace = widget.item.parent;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _hasImage => _imagePath != null && _imagePath!.isNotEmpty;

  Future<void> _pickImage() async {
    await AppHaptics.selection();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            await AppHaptics.selection();
            if (!mounted) return;
            Navigator.of(context).pop();
            await SpaceModel.saveItems();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const maxWidth = 620.0;
            final horizontalPadding = constraints.maxWidth > maxWidth
                ? (constraints.maxWidth - maxWidth) / 2
                : 20.0;

            return ListView(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 32),
              children: [
                _ImagePicker(
                  hasImage: _hasImage,
                  imagePath: _imagePath,
                  onTap: _pickImage,
                  theme: theme,
                  palette: palette,
                ),
                const SizedBox(height: 24),
                _buildTextField('Name', _nameController, theme),
                const SizedBox(height: 16),
                _buildTextField('Description', _descriptionController, theme, maxLines: 3),
                const SizedBox(height: 16),
                _buildTextField('Location notes', _locationController, theme),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _saveChanges,
                  child: const Text('Save changes'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    ThemeData theme, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textInputAction: maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _saveChanges() async {
    await AppHaptics.selection();
    setState(() {
      widget.item.name = _nameController.text.trim();
      widget.item.description = _descriptionController.text.trim();
      widget.item.locationSpecification = _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim();
      widget.item.imagePath = _imagePath;
    });
    await SpaceModel.saveItems();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    await AppHaptics.selection();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                AppHaptics.heavyImpact();
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _parentSpace?.items.remove(widget.item);
      });
      await SpaceModel.saveItems();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }
}

class _ImagePicker extends StatelessWidget {
  const _ImagePicker({
    required this.hasImage,
    required this.imagePath,
    required this.onTap,
    required this.theme,
    required this.palette,
  });

  final bool hasImage;
  final String? imagePath;
  final VoidCallback onTap;
  final ThemeData theme;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: hasImage
              ? null
              : palette.primaryGradient,
          color: hasImage ? null : theme.colorScheme.surfaceVariant,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_a_photo_rounded, size: 42, color: theme.colorScheme.onPrimary),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to add a photo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Make it easier to recognise this item.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
