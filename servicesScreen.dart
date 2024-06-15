import 'dart:io';

import 'package:collabifier/controllers/profileController.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/session_manager/userSession.dart';
import 'package:collabifier/state_management/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:provider/provider.dart';

class serviceScreen extends StatelessWidget{
  
  AuthService authService = AuthService(); // Create an instance of AuthService
  DatabaseReference ref = FirebaseDatabase.instance.ref('Users');

  serviceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return   ChangeNotifierProvider(
              create: (_) => profileController(),
              child: Consumer<profileController>(
                builder: (context, provider, child) {
                  return StreamBuilder(
                    stream: ref
                        .child(sessionController().userId.toString())
                        .onValue,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData) {
                        Map<dynamic, dynamic> map =
                            snapshot.data.snapshot.value;
                        return



                          
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15)),
                                child: Image.network(
                                  ref.child('services').child('serviceImg').toString(),
                                  height: 85.sp(context),
                                  width: 45.w(context),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              const SizedBox(height: 10),
                               Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        map['title'],
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Icon(Icons.favorite)
                                    ],
                                  ),
                                  Text(map['description'].toString()),
                                  Text(map['price'].toString() )
                                ],
                              )
                            ],
                          );
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                  
                      } else {
                        const Center(child: Text('Something went wrong'));
                      }
                      return const Center(child: Text('Something went wrong'));
                    },
                  );
                },
              ),
            );
  
  
  }
}