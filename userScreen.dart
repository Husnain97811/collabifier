import 'dart:async';

import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/screens/UseScreen/detailScreen.dart';
import 'package:collabifier/screens/splashScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

class accountScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return accountScreenState();
  }
}

class accountScreenState extends State<accountScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
 final currentuser= FirebaseAuth.instance.currentUser;
  bool? loading;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: (){
                setState(() {
                  loading = true;
                });
                Timer(Duration(seconds: 3), () { 

                auth.signOut()
               .then((value) {
                setState(() {
                  loading = false;
                });
                Navigator.pop(context);
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: splashScreen(), withNavBar: false);
              }).onError((error, stackTrace) {
                showDialog(context: context, builder: (context) {
                  return
                  AlertDialog(title: Text(error.toString()),);
                }, );
              });
                });
  })
          ],
          backgroundColor:basecolorG,
          centerTitle: true,
          title: const Text('Account'),
        ),
        body: 
        loading == true?
        Center(child: CircularProgressIndicator()):
        
          
             Stack(
               children: [
                
                 SettingsList(
      sections: [
        SettingsSection(
                            title: Text('Account'),

          tiles:<SettingsTile> [
                    SettingsTile.navigation(
                      
                      leading: Icon(Icons.account_circle_outlined,size: 40.sp(context),),
                      title: Text(currentuser!.email.toString(),style: TextStyle(fontSize: 19.sp(context),color: Colors.deepPurple.shade300),),
                    ),
        ]),
        SettingsSection(
          
                  
                  tiles: <SettingsTile>[
                    
                    SettingsTile.navigation(
                       onPressed: (context) {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> detailScreen() ) );
                    },
                      leading: Icon(Icons.person_2),
                      title: Text('Account Details'),
                      
                      trailing: Icon(Icons.chevron_right_sharp,size: 3.h(context),)
                    ),SettingsTile.navigation(
                      leading: Icon(Icons.logout),
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            loading = true;
                          });
                          Timer(Duration(seconds: 2), () {
                          auth.signOut().then((value){
                            setState(() {
                              loading = false;
                            });
                            Timer(Duration(seconds: 2), () {

                            PersistentNavBarNavigator.pushNewScreen(context,
                            screen: splashScreen(), withNavBar: false);
                             });
                          }).onError((error, stackTrace) {
                            Text(error.toString());
                          });
                        SnackBar(content: Text('Sign out'));
                           });
                        },
                        child: Text('Signout')),
                      trailing: Icon(Icons.chevron_right_sharp,size: 3.h(context),)


                    ),
                    
                  ],
        ),
        SettingsSection(
                  title: Text('Common'),
                  tiles: <SettingsTile>[
                    SettingsTile.navigation(
                      onPressed: (context) {
                        showDialog(context: context, builder: (context) {

                           return AlertDialog(title: Text('English'),);
                          }, );
                      },
                      leading: Icon(Icons.language),
                      trailing: Icon(Icons.chevron_right_sharp,size: 3.h(context),),
                      title: Text('Language'),
                     
                      value: Text('English'),
                    ),
                    
                    SettingsTile.navigation(
                      onPressed: (context) {
                        showDialog(context: context, builder: (context) {

                           return AlertDialog(title: Text('Default'),);
                          }, );
                      },
                      leading: Icon(Icons.mobile_friendly),
                      title: Text('Platform'),
                      
                      
                      trailing: Icon(Icons.mobile_friendly,size: 3.h(context),),
                      value: Text('Android'),
                    ),
                    SettingsTile.navigation(
                      onPressed: (context) {
                        showDialog(context: context, builder: (context) {

                           return AlertDialog(title: Text('AutoSelected White'),);
                          }, );
                      },
                      leading: Icon(Icons.mobile_friendly),
                     
                      
                      value: Text('White'), title: Text('Theme'),
                    ),
                  ],
        ),


        
        SettingsSection(
                  title: Text('Contact'),
          
          
                  
                  tiles: <SettingsTile>[
                    
                  SettingsTile.navigation(
                    onPressed: (context) {
                      showDialog(context: context, builder: (context)=> AlertDialog(
                        title: Text('will be added ondemand')
                      ));
                    },
                      leading: Icon(Icons.email),
                      title: Text('Support'),
                     
                      trailing: Icon(Icons.chevron_right_sharp,size: 3.h(context),)


                    ),
                    
                  ],
        ),
      
      
      ],
    ),
               ],
             ),
           
         
        );
  }
}
