import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:collabifier/session_manager/userSession.dart';
import 'package:collabifier/utils/utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';

class Service {
  final String image;
  final String title;

  Service({required this.image, required this.title});
}
class addServiceController with ChangeNotifier {
  // CREATE INSTANCE FOR DATABASE REFERENCE
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');

  // CREATE INSTANCE FOR FIREBASE STORAGE
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  //  image picker for pick image from camera and gallery
  final picker = ImagePicker();
  File? _image;
  File? get image => _image;

  bool _showMediaInputFields = false;
  bool get showMediaInputFields => _showMediaInputFields;

  // State for selected media platforms
  List<String> _selectedMedia = [];
  List<String> get selectedMedia => _selectedMedia;

  // Notifier for selected media
  ValueNotifier<List<String>> _selectedMediaNotifier =
      ValueNotifier<List<String>>([]);
  ValueNotifier<List<String>> get selectedMediaNotifier =>
      _selectedMediaNotifier;

  // Controllers for followers and price (single for entire offer)
  final TextEditingController followersController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void toggleMediaInputFields(bool selected, String media) {
    if (selected) {
      _selectedMedia.add(media);
    } else {
      _selectedMedia.remove(media);
      // Clear controllers ONLY when deselected
      followersController.clear();
      priceController.clear();
    }

    _selectedMediaNotifier.value = List.from(_selectedMedia); // Update the notifier
    notifyListeners();
  }

  // Future function for GALLERY IMAGE
  Future pickGalleryImage(BuildContext context) async {
    final PickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    if (PickedFile != null) {
      _image = File(PickedFile.path);
      // uploadImage( context);
      notifyListeners();
    }
  }

  // future function for CAMERA IMAGE
  Future pickCameraImage(BuildContext context) async {
    final PickedFile = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    if (PickedFile != null) {
      _image = File(PickedFile.path);
      // uploadImage(context);
      notifyListeners();
    }
  }

  void pickImage(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
              height: 14.h(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                    onTap: () {
                      pickCameraImage(context);
                      Navigator.pop(context);
                    },
                    leading: Icon(Icons.camera),
                    title: Text('Camera'),
                  ),
                  ListTile(
                    onTap: () {
                      pickGalleryImage(context);
                      Navigator.pop(context);
                    },
                    leading: Icon(Icons.image),
                    title: Text('Gallery'),
                  ),
                ],
              )),
        );
      },
    );
  }

  //         //  FUTURE FUNCTION FOR IMAGE UPLOAD
  Future<String?> uploadImage(BuildContext context) async {
    setLoading(true);

    try {
      // CREATE ref  FOR FIREBASE STORAGE
      // here we use profile + session controller
      // (user id) so it will replace previous image from storage
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref(sessionController().userId.toString())
          .child('services')
          .child(DateTime.now().millisecond.toString());
      firebase_storage.Reference existingImageRef = firebase_storage
          .FirebaseStorage.instance
          .ref(sessionController().userId.toString());

      //    TO DELETE PREVIOUS IMAGE
      try {
        await existingImageRef.delete();
      } catch (e) {
        print('Failed to delete existing image: $e');
      }

      firebase_storage.UploadTask uploadTask =
          storageRef.putFile(File(image!.path).absolute);

      await Future.value(uploadTask);

      final newUrl = await storageRef.getDownloadURL();

      Utils.toasstMessage('image uploaded');

      _image = null;

      notifyListeners();

      // Return the new URL
      return newUrl;
    } catch (error) {
      print('Error uploading image: $error');
      // Handle errors if necessary
      return null;
    }
  }

  void uploadAndHandleImage(BuildContext context) async {
    String? imageUrl = await uploadImage(context);
    if (imageUrl != null) {
      // Do something with the imageUrl, for example, display it
      print('Uploaded image URL: $imageUrl');
      // Now you can use the imageUrl in your home screen
    } else {
      // Handle if imageUrl is null
      print('Error uploading image');
    }
  }
}