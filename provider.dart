import 'package:collabifier/session_manager/userSession.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthProvider extends ChangeNotifier {
  String _selectedChoice = 'Influencer'; // Default choice

  String get selectedChoice => _selectedChoice;

  void updateChoice(String choice) {
    _selectedChoice = choice;
    notifyListeners(); // Notify listeners when the state changes
  }
}


class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      final FirebaseDatabase _database = FirebaseDatabase.instance;
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');



  // Future<void> signInWithEmailAndPassword(String email, String password) async {
  //   try {
  //     _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     ).then((value) {
  //       sessionController().email= value.user!.email.toString();
  //       sessionController().userId = value.user!.uid.toString();
        

  //     });
      
      
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  


  //      CREATE ACCOUNT AND THEN STORED DATA IN REAL TIME DATABASE

  // Future<void> signUpWithEmailAndPassword(String email,String name,String password) async {
  //   try {
  //      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
       
  //     );

  //     // NOW STORING DATA IN REALTIME

  //     // Get the user ID of the newly created user
  //     String userId = userCredential.user!.uid;
      
      

  //     // Create a reference to the 'Users' node in the Realtime Database
  //     DatabaseReference userRef = _database.ref().child('Users').child(userId);
      

  //     // Create a map containing user data
  //     // Map<String, dynamic> userData = {
  //     //   'email': email,
        
  //     //   // Add other user data as needed
  //     // };

  //     // Upload user data to the Realtime Database
  //     await userRef.set({
  //       'email': email,
  //       'name': name,
        
  //     });

 
      
  //   } catch (error) {
  //     throw error;
  //   }
  // }

          //  LOGOUT

          Future<void> signOut() async {
    try {
      await _auth.signOut().then((value){
        sessionController().userId= '';
      });
    } catch (error) {
      throw error;
    }
  }


  //     STORE USER DATA

  Future<void> updateProfile(String displayName, String photoURL) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': displayName,
          'photoURL': photoURL,
          // Add more fields as needed
        });
      }
    } catch (error) {
      throw error;
    }
  }


  /////         RETRIEVE  USER DATA

//   Future<UserProfile?> getUserProfile(String uid) async {
//     try {
//       DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore.collection('users').doc(uid).get();
//       if (snapshot.exists) {
//         return UserProfile(
//           uid: uid,
//           email: snapshot.data()!['email'],
//           displayName: snapshot.data()!['displayName'],
//           photoURL: snapshot.data()!['photoURL'],
//         );
//       }
//       return null;
//     } catch (error) {
//       throw error;
//     }
//   }
// }

// class UserProfile {
//   final String uid;
//   final String email;
//   final String displayName;
//   final String photoURL;

//   UserProfile({
//     required this.uid,
//     required this.email,
//     required this.displayName,
//     required this.photoURL,
//   });

Future<Map<String, dynamic>> getUserData(String userId) async {
  try {
    // Create a reference to the user's data in the Realtime Database
    DatabaseReference userRef = _database.ref().child('Users').child(userId);

    // Retrieve user data from the Realtime Database
    DataSnapshot dataSnapshot = (await userRef.once()) as DataSnapshot;

    // Check if data exists
    if (dataSnapshot.value != null) {
      // Convert dataSnapshot to a Map and return user data
      Map<dynamic, dynamic>? dataMap = dataSnapshot.value as Map<dynamic, dynamic>?;
      if (dataMap != null) {
        return Map<String, dynamic>.from(dataMap);
      } else {
        throw 'Data snapshot is not in the correct format';
      }
    } else {
      // Return null if no data found
      return {};
    }
  } catch (error) {
    throw error;
  }
}

}
