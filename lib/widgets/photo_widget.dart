import 'dart:io';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leak_guard/models/photographable.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoWidget extends StatelessWidget {
  final Photographable item;
  final double size;
  final Function onPhotoChanged;

  const PhotoWidget({
    Key? key,
    required this.item,
    this.size = 120,
    required this.onPhotoChanged,
  }) : super(key: key);

  Future<void> _checkAndRequestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;
      if (status.isDenied) {
        final result = await Permission.camera.request();
        if (result.isPermanentlyDenied) {
          // Przekieruj użytkownika do ustawień
          openAppSettings();
          return;
        }
        if (result.isDenied) {
          return;
        }
      }
    } else {
      if (Platform.isAndroid && await Permission.storage.status.isDenied) {
        final result = await Permission.storage.request();
        if (result.isPermanentlyDenied) {
          openAppSettings();
          return;
        }
        if (result.isDenied) {
          return;
        }
      }
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Choose source',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeumorphicButton(
              style: NeumorphicStyle(
                depth: 2,
                intensity: 0.8,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await _checkAndRequestPermissions(ImageSource.camera);
                Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.camera));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text(
                      'Camera',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            NeumorphicButton(
              style: NeumorphicStyle(
                depth: 2,
                intensity: 0.8,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
              ),
              onPressed: () async {
                await _checkAndRequestPermissions(ImageSource.gallery);
                Navigator.pop(context,
                    await picker.pickImage(source: ImageSource.gallery));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text(
                      'Gallery',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (image != null) {
      item.setPhoto(image.path);
      onPhotoChanged();
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: MyColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Delete photo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete this photo? This action cannot be undone.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        actions: [
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          NeumorphicButton(
            style: NeumorphicStyle(
              depth: 2,
              intensity: 0.8,
              color: Colors.red[300],
              boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto();
            },
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (item.getPhoto() == null) {
      return Row(
        children: [
          NeumorphicButton(
            padding: const EdgeInsets.all(8),
            onPressed: () => _pickImage(context),
            style: NeumorphicStyle(
              depth: 3,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(10),
              ),
            ),
            child: Icon(
              Icons.camera_alt,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Take a photo!',
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      );
    }

    return Neumorphic(
      style: NeumorphicStyle(
        depth: 8,
        intensity: 0.65,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
      ),
      child: Container(
        width: size,
        height: size * 0.8,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(item.getPhoto()!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Row(
                children: [
                  NeumorphicButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: () => _showDeleteConfirmationDialog(context),
                    style: NeumorphicStyle(
                      depth: 3,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.delete,
                    ),
                  ),
                  SizedBox(width: 8),
                  NeumorphicButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: () => _pickImage(context),
                    style: NeumorphicStyle(
                      depth: 3,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deletePhoto() {
    item.setPhoto(null);
    onPhotoChanged();
  }
}
