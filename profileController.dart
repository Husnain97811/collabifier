import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/session_manager/userSession.dart';
import 'package:collabifier/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;



class profileController with ChangeNotifier {


        // CREATE INSTANCE FOR DATABASE REFERENCE
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');
    
        // CREATE INSTANCE FOR FIREBASE STORAGE
    firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

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

  // FUTURE FUNCTION FOR GALLERY IMAGE

  Future pickGalleryImage(BuildContext context)async{
    final PickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70 );

    if(PickedFile != null){
      _image = File(PickedFile.path);
      uploadImage(context);
      notifyListeners();

    }
  }


  // future function for CAMERA IMAGE


    Future pickCameraImage(BuildContext context)async{
    final PickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 70 );

    if(PickedFile != null){
      _image = File(PickedFile.path);
      uploadImage(context);
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
              child:  Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                onTap: () {
                  pickCameraImage(context);
                  Navigator.pop(context);

                },
                leading: Icon(Icons.camera),title: Text('Camera'),),
              ListTile(
                onTap: () {
                  pickGalleryImage(context);
                  Navigator.pop(context);
                },
                leading: Icon(Icons.image),title: Text('Gallery'),),
            ],
          )),
        );
      },
    );
  }




          //  FUTURE FUNCTION FOR IMAGE UPLOAD
  void uploadImage(BuildContext context)async {

  final userData = FirebaseFirestore.instance.collection('users');


    setLoading(true);

    

        // CREATE ref  FOR FIREBASE STORAGE

            // here we use profile + session controoler 
            //(user id) so it will replace previous image from storage
    firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance.ref('/profile'+sessionController().userId.toString());

    firebase_storage.UploadTask uploadTask = storageRef.putFile(File(image!.path ).absolute );

    await Future.value(uploadTask);

    final newUrl = await storageRef.getDownloadURL();

    var user = FirebaseAuth.instance.currentUser?.uid.toString();


    userData.doc(user).update({
      'profile' : newUrl.toString()
    }).then((value) {
      Utils.toasstMessage(
        'Profile Updated'
      );
      _image = null;
      setLoading(false);
    }).onError((error, stackTrace) {
      setLoading(false);
      Utils.toasstMessage(e.toString());
    });

  }


}
