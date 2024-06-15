import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/controllers/profileController.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/screens/splashScreen.dart';
import 'package:collabifier/session_manager/userSession.dart';
import 'package:collabifier/state_management/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';

class detailScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return detailScreenState();
  }
}

class detailScreenState extends State<detailScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  AuthService authService = AuthService(); // Create an instance of AuthService
  DatabaseReference ref = FirebaseDatabase.instance.ref('Users');
  final auth  = FirebaseAuth.instance;

  final userData = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'detail screen',
                style: TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    try {
                      await authService.signOut().then((value) {
                        Navigator.pop(context);
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: splashScreen(), withNavBar: false);
                      });
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to sign out: $error'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.exit_to_app,
                    size: 22,
                  ),
                )
              ],
              centerTitle: true,
              backgroundColor: basecolorG,
            ),
            body: ChangeNotifierProvider(
              create: (_) => profileController(),
              child: Consumer<profileController>(
                builder: (context, provider, child) {

    var user = FirebaseAuth.instance.currentUser?.uid.toString();

                  return
                  
                   StreamBuilder(
                    stream: userData.doc(user).snapshots(),
  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Text('Something went wrong: ${snapshot.error}');
    }

    if (!snapshot.hasData || !snapshot.data!.exists) {
      return Center(child: Text('No data available'));
    }

    var userData = snapshot.data!.data() as Map<String , dynamic>? ; // Accessing document data

    
                      return ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          
                         var name = userData?['name'] ?? 'Error fetching name';
    var email = userData?['email'] ?? 'Email not available';
    var phone = userData?['phone'] ?? 'Phone not available';
    var profile  = userData? ['profile'] ?? Icon(Icons.person);
    var Usertype = userData? ['userType'] ?? 'Error while fetching';

                          return Column(
                            children: [
                              // TOP GREEN CONTAINER
                              Container(
                                decoration: BoxDecoration(
                                  color: basecolorG,
                                  borderRadius:  BorderRadius.only(
                                    bottomLeft: Radius.circular(12.h(context)),
                                  ),
                                ),
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 23 * 4),
                                    // user IMAGE IN TOP
                                    Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        Center(
                                            child: Container(
                                                height: 100,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        width: 2,
                                                        color: Colors.white)),
                                                child: ClipRRect(
    borderRadius: BorderRadius.circular(100),
    child: provider.image == null
        ? (   profile != null && profile.isNotEmpty)
            ? Image.network(
                profile,
                height: 64.sp(context),
                width: 64.sp(context),
                fit: BoxFit.fill,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                },
              )
            : Icon(Icons.person)
            
        : Image.file(
            File(provider.image!.path).absolute,
            height: 64.sp(context),
            width: 64.sp(context),
            fit: BoxFit.fill,
          ),
  ),

                                                          )
                                                          ),
                                       
                                       
                                        GestureDetector(
                                            onTap: () {
                                              provider.pickImage(context);
                                            },
                                            child: CircleAvatar(
                                              radius: 10.sp(context),
                                              child: Icon(
                                                Icons.add,
                                                size: 15.sp(context),
                                              ),
                                            ))
                                      ],
                                    ),

                                    const SizedBox(height: 68),
                                  ],
                                ),
                              ),
                              SizedBox(height: 3.h(context),),

                              // Your UI widgets here
                              ListTile(
                                title: Text(
                                  'Name:',
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                                trailing: Text(
                                  name,
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Email:',
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                                trailing: Text(
                                  email,
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Phone:',
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                                trailing: Text(
                                  phone,
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                              ),
                               ListTile(
                                title: Text(
                                  'UserType:',
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                                trailing: Text(
                                  Usertype,
                                  style: TextStyle(fontSize: 15.sp(context)),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
               
                },
              ),
            )));
  }
}

class reUseableDetailRow extends StatelessWidget {
  final String title, value;
  final IconData iconData;

  const reUseableDetailRow(
      {super.key,
      required this.title,
      required this.value,
      required this.iconData});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: Icon(iconData),
          trailing: Text(value),
        )
      ],
    );
  }
}
