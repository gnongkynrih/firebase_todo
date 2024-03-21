import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_todo/provider/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class SelectImage extends StatefulWidget {
  const SelectImage({super.key});
  @override
  State<SelectImage> createState() => _SelectImageState();
}

class _SelectImageState extends State<SelectImage> {
  String imagePath = '';
  bool isWorking = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isWorking
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
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
      if (img == null) {
        return;
      }
      img = await CropImage(img);

      setState(() {
        isWorking = true;
      });
      //get the path
      final String fileName = path.basename(img!.path);
      //store in firebase storage
      FirebaseStorage storage = FirebaseStorage.instance;

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': img.path},
      );

      var upload = await storage
          .ref()
          .child('profile')
          .child(fileName)
          .putFile(img, metadata);
      imagePath = await upload.ref.getDownloadURL();

      //update the profile image
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      firestore.collection('profile').doc(auth.currentUser!.uid).update({
        'image': imagePath,
      });
      //update in the provider
      Provider.of<TaskProvider>(context, listen: false)
          .updateProfileData(imagePath);
      Navigator.pop(context);
    } catch (e) {
      print('gordon $e');
    } finally {
      setState(() {
        isWorking = false;
      });
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
