import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';
import 'package:find_it/theme/app_theme.dart';

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar(context),
      body: Container(
        decoration: BoxDecoration(gradient: extras.backgroundGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _pickImage();
                },
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: extras.glassBackground,
                    boxShadow: [
                      BoxShadow(
                        color: extras.shadowColor,
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                        spreadRadius: -16,
                      ),
                    ],
                    image: _imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                color: theme.colorScheme.primary, size: 42),
                            const SizedBox(height: 12),
                            Text(
                              'Add photo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Name', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Description', _descriptionController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Location', _locationController),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  setState(() {
                    widget.item.name = _nameController.text;
                    widget.item.description = _descriptionController.text;
                    widget.item.locationSpecification = _locationController.text;
                    widget.item.imagePath = _imagePath;
                  });
                  await SpaceModel.saveItems();
                  if (!mounted) return;
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        'Item details',
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/Arrow - Left 2.svg',
          colorFilter: ColorFilter.mode(
            theme.colorScheme.onSurface,
            BlendMode.srcIn,
          ),
        ),
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).pop();
          SpaceModel.saveItems();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
          onPressed: () async {
            HapticFeedback.selectionClick();
            final bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete item'),
                  content: const Text('Do you want to delete this object?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
            if (confirmed == true) {
              parentSpace?.items.remove(widget.item);
              await SpaceModel.saveItems();
              if (!mounted) return;
              Navigator.of(context).pop(true);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
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
