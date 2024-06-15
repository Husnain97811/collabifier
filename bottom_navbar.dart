
import 'package:collabifier/screens/UseScreen/userScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/inflencerUpdateScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/investorScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class persistent_bottom_nav_bar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return persistent_bottom_nav_barState();
  }
}

class persistent_bottom_nav_barState extends State<persistent_bottom_nav_bar> {
  User? user = FirebaseAuth.instance.currentUser;

  final tabController = PersistentTabController(initialIndex: 0);
  List<Widget> _buildScreens() {
    return [
      const investorScreen(),
      InfluencerDetailsScreen(
        influencerId: user!.uid.toString(),
      ),
      accountScreen()
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItem() {
    return [
      PersistentBottomNavBarItem(icon: const Icon(Icons.home)),
      PersistentBottomNavBarItem(icon: const Icon(Icons.history_edu_outlined)),
      PersistentBottomNavBarItem(icon: const Icon(Icons.person))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(context,
        // hideNavigationBar: true,
        navBarHeight: 8.h(context),
        padding: NavBarPadding.symmetric(horizontal: 1.w(context)),
        screens: _buildScreens(),
        controller: tabController,
        items: _navBarItem());
  }
}
