import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/screens/bottom_Navbar/bottom_navbar.dart';
import 'package:collabifier/screens/bottom_Navbar/influencerbottom_navbar.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/adminScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/influencers.dart';
import 'package:collabifier/session_manager/userSession.dart';
import 'package:collabifier/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class loginController with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref('Users');

  //    FOR LOADING USING PROVIDER
  bool _loading = false;
  bool get loading => _loading;

  setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void signInWithGoogle(BuildContext context, String name) async {
    setLoading(true);
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      GoogleSignInAuthentication? googleAuth =
          await googleUser!.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential user = await auth.signInWithCredential(credential);
      print(credential.accessToken);
      await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => persistent_bottom_nav_bar()),
          (route) => false);

      sessionController().name = sessionController().name.toString();

      ref.child(sessionController().userId.toString()).set({
        'accessToken': credential.accessToken.toString(),
        'idToken': credential.token.toString(),
        'email': sessionController().email.toString()
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(e.toString()),
          );
        },
      );
    }
  }

  void login(BuildContext context, String email, String password) async {
    setLoading(true);
    try {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        sessionController().email = value.user!.email.toString();
        sessionController().userId = value.user!.uid.toString();
        sessionController().name = value.user!.displayName.toString();
        sessionController().photoURL = value.user!.photoURL.toString();

        // Fetch user type from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(sessionController().userId)
            .get();
        final userType = userDoc.data()?['userType'];

        // Navigate based on user type
        if (userType == 'Influencer') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => persistent_bottom_nav_bar()),
            (route) => false,
          );
        } else if (userType == 'Investor') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => influencer_bottom_nav_bar()),
            (route) => false,
          );
        } 
         else if (userType == 'Admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminBookingsScreen()),
            (route) => false,
          );
        } 
        else {
          setLoading(false);
          // Handle other cases or default to persistent_bottom_nav_bar
          showDialog(context: context, builder: (context) {
            return AlertDialog(title: Text('Your account is not properly working kindly sent a detailed mail to our company',style: TextStyle(fontSize: 12),),);
            
          },
          
          );
        }
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