import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SelectImage extends StatefulWidget {
  const SelectImage({super.key});
  @override
  State<SelectImage> createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  String imagePath = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const SizedBox(
          height: 20,
        ),
        const Text(
          'Upload Profile Picture',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 20,
        ),
        imagePath != ''
            ? SizedBox(
                height: 40,
                child: Image.network(imagePath),
              )
            : const SizedBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                takePhoto(ImageSource.camera);
              },
              child: const Row(children: [
                Icon(Icons.camera_alt),
                Text("Take Photo"),
              ]),
            ),
            ElevatedButton(
              onPressed: () {
                takePhoto(ImageSource.gallery);
              },
              child: const Row(children: [
                Icon(Icons.image),
                Text("Select Image"),
              ]),
            ),
          ],
        )
      ]),
    );
  }

  void takePhoto(ImageSource source) async {
    try {
      final ImagePicker imgPicker = ImagePicker();
      final XFile? photo =
          await imgPicker.pickImage(source: source, imageQuality: 75);
      if (photo == null) {
        return;
      }
      File? img = File(photo.path);

      img = await CropImage(img);
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }
  }

  Future<File?> CropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if (croppedFile == null) {
      return null;
    }
    return File(croppedFile.path);
  }
}
