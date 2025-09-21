import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/item_model.dart';
import '../models/space_model.dart';
import '../theme/app_theme.dart';

class ItemDisplayPage extends StatefulWidget {
  final ItemModel item;

  ItemDisplayPage({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDisplayPageState createState() => _ItemDisplayPageState();
}

class _ItemDisplayPageState extends State<ItemDisplayPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;

  String? _imagePath;
  SpaceModel? parentSpace;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _descriptionController = TextEditingController(text: widget.item.description);
    _locationController = TextEditingController(text: widget.item.locationSpecification);
    _imagePath = widget.item.imagePath;
    parentSpace = widget.item.parent;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    final palette = context.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: palette.surfaceComponent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: _imagePath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: colors.onSurfaceVariant, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add an image',
                            style: textStyles.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Name', _nameController),
            const SizedBox(height: 20),
            _buildTextField('Description', _descriptionController, maxLines: 3),
            const SizedBox(height: 20),
            _buildTextField('Location', _locationController),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.check_rounded),
              label: const Text('Save changes'),
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  Future<void> _saveChanges() async {
    widget.item
      ..name = _nameController.text.trim()
      ..description = _descriptionController.text.trim()
      ..locationSpecification = _locationController.text.trim()
      ..imagePath = _imagePath;
    await SpaceModel.saveItems();
    HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    Feedback.forTap(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this item?'),
        content: const Text('This item will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      parentSpace?.items.remove(widget.item);
      await SpaceModel.saveItems();
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }
}
