import 'package:collabifier/auth_Screens/login_Screen.dart';
// ignore: unused_import
import 'package:collabifier/session_manager/userSession.dart';
import 'package:collabifier/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';

class SignUpController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;

  //    FOR LOADING USING PROVIDER
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void signUp(
      BuildContext context,
      String name,
      String email,
      String password,
      String phone,
      String receiverId,
      String message,
      String selectedChoice,
      List<Map<String, dynamic>> platformChoices) {
    setLoading(true);
    try {
      auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((credential) async {
        // Now you can safely access userUid
        final userUid = credential.user?.uid;
        if (userUid != null) {
          final userData = FirebaseFirestore.instance
              .collection('users')
              .doc(userUid);

          final timestamp = Timestamp.now();
          // Get current user info AFTER sign-up
          final currentUser = await auth.currentUser; // Use await to get current user
          final currentUserId = currentUser?.uid;
          final currentUserEmail = currentUser?.email;

          if (currentUserId != null && currentUserEmail != null) {
            // Prepare platform data to store in Firestore (only if Influencer)
            List<Map<String, dynamic>> platformData = [];
            if (selectedChoice == 'Influencer') {
              for (Map<String, dynamic> choice in platformChoices) {
                if (choice['selected']) {
                  platformData.add({
                    'name': choice['name'],
                    'url': choice['url'],
                    'price': choice['price'],
                    'channelName': choice['channelName'],
                    'followers': choice['followers']
                  });
                }
              }
            }

            userData.set({
              'uid': userUid,
              'name': name,
              'email': email,
              'phone': phone,
              'profile': '',
              'from': currentUserId,
              'to': receiverId,
              'lastmessage': message,
              'lasttime': timestamp,
              'userType': selectedChoice,
              'platformData': platformData // Store the platform choices if Influencer
              // Add other user data here
            }).then((_) {
              setLoading(false);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => loginScreen()),
                  (route) => false);
              Utils.toasstMessage('Account Created Successfully');
            }).catchError((error) {
              setLoading(false);
              Utils.toasstMessage(error.toString());
            });
          } else {
            setLoading(false);
            Utils.toasstMessage(
                'Failed to get current user info after signup');
          }
        } else {
          setLoading(false);
          Utils.toasstMessage('User creation failed');
        }
      }).catchError((error) {
        setLoading(false);
        Utils.toasstMessage(error.toString());
      });
    } catch (e) {
      setLoading(false);
      Utils.toasstMessage(e.toString());
    }
  }
}
