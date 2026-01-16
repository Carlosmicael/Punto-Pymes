import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImageSection extends StatelessWidget {
  final double width;
  final double height;
  final File? imageFile;
  final Function(File) onImagePicked;
  final Function() onImageRemoved;

  const ImageSection({
    super.key,
    required this.width,
    required this.height,
    required this.imageFile,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final circleSize = width * 0.45; 

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: () => _showImageSourceDialog(context),
            customBorder: const CircleBorder(),
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ], 
                color: const Color.fromARGB(255, 255, 255, 255),
                border: Border.all(color: const Color.fromARGB(255, 255, 255, 255), width: 3),
                image: imageFile != null ? DecorationImage(
                  image: FileImage(imageFile!),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: imageFile == null ? 
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: const Color.fromARGB(255, 175, 170, 170),
                  size: circleSize * 0.6,
                ) : 
                const SizedBox.shrink(), 
            ),
          ),

          SizedBox(height: height * 0.05),

          if (imageFile != null)
            TextButton.icon(
              onPressed: onImageRemoved,
              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 255, 255)),
              label: const Text(
                'Quitar foto', 
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))
              ),
            ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }
}
