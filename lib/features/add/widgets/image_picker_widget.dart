import 'package:dotted_border/dotted_border.dart';
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
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(
        source: source,
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
  }

  void _clearImage() {
    setState(() {
      _imagePath = null;
    });
    widget.onImageSelected?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(25),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              strokeWidth: 2,
              dashPattern: const [6, 4],
              padding: EdgeInsets.zero,
            ),
            child: Container(
              width: 120,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(25),
              ),
              child: _imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.camera300,
                          size: 40,
                          color: ShadTheme.of(
                            context,
                          ).colorScheme.mutedForeground,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: ShadTheme.of(context).textTheme.small.copyWith(
                            color: ShadTheme.of(
                              context,
                            ).colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (_imagePath != null)
          Positioned(
            top: -6,
            right: -10,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _clearImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
