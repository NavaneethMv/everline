// lib/features/add/widgets/image_picker_widget.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shadcn_ui/shadcn_ui.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(String?)? onImageSelected;
  final String? initialImagePath;

  const ImagePickerWidget({
    super.key,
    this.onImageSelected,
    this.initialImagePath,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.initialImagePath;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      widget.onImageSelected?.call(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(File(_imagePath!), fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.camera200,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text('Add Photo', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
      ),
    );
  }
}
