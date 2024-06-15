import 'package:collabifier/controllers/addServiceController.dart';
import 'package:collabifier/controllers/searchController.dart';
import 'package:collabifier/controllers/signUpController.dart';
import 'package:collabifier/screens/searchScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/inflencerUpdateScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/influencers.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/investorScreen.dart';
import 'package:collabifier/state_management/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'reUseAbleWidgets/contants.dart';
import 'screens/splashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SearchOptions()),
        ChangeNotifierProvider(create: (_) => SignUpController()), 
        ChangeNotifierProvider(create: (_) => addServiceController()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_)=> OfferFilterProvider()),
        ChangeNotifierProvider(create: (_)=> InfluencerDetailsProvider()),

        // ChangeNotifierProvider(create: (_)=> ChatProvider()),

        // ChangeNotifierProvider(create: (_)=> UnreadMessageProvider(_hasUnreadMessages=values) 



      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed( seedColor: basecolorG),
          useMaterial3: true,
        ),
        home: splashScreen(),
      ),
    );
  }
}