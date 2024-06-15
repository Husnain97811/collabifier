import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/screens/bottom_Navbar/bottom_navbar.dart';
import 'package:collabifier/screens/bottom_Navbar/influencerbottom_navbar.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/adminScreen.dart';
import 'package:collabifier/session_manager/userSession.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import '../auth_Screens/login_Screen.dart';

class splashScreen extends StatefulWidget {
  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen> {
  String title = "Collabifier";

  String description = "Welcome, we have something special";

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () {
        _checkLoginStatus();
      },
    );
  }

  void _checkLoginStatus() async {
    // Check if user is already signed in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // if(user.phoneNumber != null)
      //   SAVE USER ID FROM USER SESSION
      sessionController().userId = user.uid.toString();
      sessionController().email = user.email.toString();
      sessionController().name = user.displayName.toString();

      // Fetch user type from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(sessionController().userId)
          .get();
      final userType = userDoc.data()?['userType'];

      // Navigate based on user type
      if (userType == 'Influencer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => persistent_bottom_nav_bar()),
        );
      } else if (userType == 'Investor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => influencer_bottom_nav_bar()),
        );
      } else if (userType == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminBookingsScreen()),
        );
      }
    } else {
      // User is not logged in, navigate to login screen
     Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => loginScreen()),
        );
      
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Container(
      height: 105.h(context),
      
      // decoration: const BoxDecoration(
      //     gradient: LinearGradient(
      //         begin: Alignment.topCenter,
      //         end: Alignment.bottomLeft,
      //         colors: [
      //       Color.fromARGB(255, 214, 171, 168),
      //       Colors.white,
      //       Color.fromARGB(255, 176, 89, 89)
      //     ])),
      child: Image.asset('assets/images/splashScreenCollabifier.jpg',fit: BoxFit.fill,height: 100.h(context),),
    );
  }
}