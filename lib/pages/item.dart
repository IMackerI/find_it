import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';

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
    HapticFeedback.selectionClick();
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [palette.surfaceDim, palette.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: palette.surfaceBright,
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadow,
                          blurRadius: 24,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: _imagePath != null
                        ? Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 48, color: palette.muted),
                                const SizedBox(height: 12),
                                Text(
                                  'Add a photo',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: palette.muted),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('Name', _nameController),
            const SizedBox(height: 16),
            _buildTextField('Description', _descriptionController, maxLines: 3),
            const SizedBox(height: 16),
            _buildTextField('Location', _locationController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  widget.item.name = _nameController.text;
                  widget.item.description = _descriptionController.text;
                  widget.item.locationSpecification = _locationController.text;
                  widget.item.imagePath = _imagePath;
                });
                SpaceModel.saveItems();
                Navigator.pop(context, true);
              },
              child: const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(
        'Item details',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton.filledTonal(
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
            SpaceModel.saveItems();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      leadingWidth: 72,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton.filledTonal(
            onPressed: () {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete item'),
                    content: const Text('Do you want to delete this item?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          setState(() {
                            parentSpace?.items.remove(widget.item);
                          });
                          SpaceModel.saveItems();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ),
      ],
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
}
