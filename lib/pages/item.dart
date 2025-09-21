import 'dart:io';

import 'package:find_it/colors.dart';
import 'package:flutter/material.dart';
import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

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
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: _imagePath != null ? FileImage(File(_imagePath!)) : AssetImage('assets/icons/dots.svg') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: _imagePath == null
                      ? Icon(
                          Icons.add_a_photo,
                          color: Colors.black,
                          size: 50,
                        )
                      : null,
              ),
            ),
            SizedBox(height: 16),
            _buildTextField('Name', _nameController),
            SizedBox(height: 16),
            _buildTextField('Description', _descriptionController, maxLines: 3),
            SizedBox(height: 16),
            _buildTextField('Location', _locationController),
            SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  widget.item.name = _nameController.text;
                  widget.item.description = _descriptionController.text;
                  widget.item.locationSpecification = _locationController.text;
                  widget.item.imagePath = _imagePath;
                });
                SpaceModel.saveItems();
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('Submit Changes', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Item Details',
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
          Navigator.of(context).pop();
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
      actions: [
        GestureDetector(
          onTap: () async {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                title: Text('Are you sure?'),
                content: Text('Do you want to delete this object?'),
                actions: [
                  TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  ),
                  TextButton(
                  child: Text('Delete'),
                  onPressed: () {
                    setState(() {
                      parentSpace!.items.remove(widget.item);
                    });
                    SpaceModel.saveItems();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(true);
                  },
                  ),
                ],
                );
              },
            );
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.delete,
              color: AppColors.iconColor,
            ),
          ),
        ),
      ]
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}