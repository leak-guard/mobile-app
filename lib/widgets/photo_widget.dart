import 'dart:io';

import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leak_guard/models/photographable.dart';
import 'package:leak_guard/services/permissions_service.dart';
import 'package:leak_guard/utils/colors.dart';
import 'package:leak_guard/utils/custom_toast.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoWidget extends StatelessWidget {
  final Photographable item;
  final double size;
  final Function onPhotoChanged;
  final _permissionsService = PermissionsService();

  PhotoWidget({
    super.key,
    required this.item,
    this.size = 120,
    required this.onPhotoChanged,
  });

  Future<String?> _cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          activeControlsWidgetColor: Colors.blue,
          initAspectRatio: CropAspectRatioPreset.ratio5x4,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    return croppedFile?.path;
  }

  Future<void> _pickAndCropImage(BuildContext context) async {
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
                if (await _permissionsService
                    .requestPermission(Permission.camera)) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context,
                      await picker.pickImage(source: ImageSource.camera));
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  CustomToast.toast('Permission for camera is denied');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt),
                    const SizedBox(width: 8),
                    Text(
                      'Camera',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            NeumorphicButton(
              style: NeumorphicStyle(
                depth: 2,
                intensity: 0.8,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (await _permissionsService
                    .requestPermission(Permission.storage)) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context,
                      await picker.pickImage(source: ImageSource.gallery));
                } else {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  CustomToast.toast('Permission for storage is denied');
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library),
                    const SizedBox(width: 8),
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
      final croppedPath = await _cropImage(image.path);
      if (croppedPath != null) {
        item.setPhoto(croppedPath);
        onPhotoChanged();
      }
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
            onPressed: () => _pickAndCropImage(context),
            style: NeumorphicStyle(
              depth: 3,
              boxShape: NeumorphicBoxShape.roundRect(
                BorderRadius.circular(10),
              ),
            ),
            child: const Icon(
              Icons.camera_alt,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Add a photo!',
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
      child: SizedBox(
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
                    child: const Icon(
                      Icons.delete,
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeumorphicButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: () => _pickAndCropImage(context),
                    style: NeumorphicStyle(
                      depth: 3,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(
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
