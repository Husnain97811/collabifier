import 'package:collabifier/auth_Screens/login_Screen.dart';
import 'package:collabifier/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class forgotController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;

  //    FOR LOADING USING PROVIDER
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void forgotPass(BuildContext context, String email) {
    setLoading(true);
    try {
      auth
          .sendPasswordResetEmail(email: email,)
          .then((value) {
            Utils.toasstMessage('Check your email to recover your password');
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> loginScreen() ), (route) => false);
          })
          .onError((error, stackTrace) {
        setLoading(false);
        Utils.toasstMessage(error.toString());
      });
    } catch (e) {
      setLoading(false);
      Utils.toasstMessage(e.toString());
    }
  }
}
