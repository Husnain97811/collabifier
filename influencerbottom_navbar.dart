import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/screens/UseScreen/detailScreen.dart';
import 'package:collabifier/screens/UseScreen/userScreen.dart';
import 'package:collabifier/screens/investorServiceScreen.dart';
import 'package:collabifier/screens/searchScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/adminScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/investorScreen.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/influencers.dart';
import 'package:collabifier/screens/usersScreens/messageUserList.dart';
import 'package:collabifier/screens/usersScreens/requirements.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart'; // Import Provider package

class influencer_bottom_nav_bar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => influencer_bottom_nav_barState();
}

class influencer_bottom_nav_barState extends State<influencer_bottom_nav_bar> {
  User? user = FirebaseAuth.instance.currentUser;
  final tabController = PersistentTabController(initialIndex: 0);
  final userData = FirebaseFirestore.instance.collection('users');

  bool _hasUnreadMessages = false;

  @override
  void initState() {
    super.initState();
    _listenForUnreadMessages();
  }

  void _listenForUnreadMessages() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    userData.snapshots().listen((snapshot) async {
      for (var userDoc in snapshot.docs) {
        final otherUserId = userDoc.id;
        if (otherUserId == userId) continue;

        List<String> sortedIds = [userId, otherUserId];
        sortedIds.sort();
        String chatRoomId = sortedIds.join("_");

        final messagesSnapshot = await FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(chatRoomId)
            .collection('messages')
            .where('receiverId', isEqualTo: userId)
            .where('read', isEqualTo: false)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          setState(() {
            _hasUnreadMessages = true;
          });
          return;
        }
      }

      // If no unread messages were found for any user
      setState(() {
        _hasUnreadMessages = false;
      });
    });
  }

  List<Widget> _buildScreens() {
    return [influencerScreen(), InvestorServicesScreen(), accountScreen()];
  }

  List<PersistentBottomNavBarItem> _navBarItem() {
    return [
      PersistentBottomNavBarItem(
          icon: Icon(Icons.home), activeColorPrimary: Colors.white),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.supervised_user_circle_sharp),
        activeColorPrimary: Colors.white,
        // inactiveColorPrimary: Colors.white
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person),
        activeColorPrimary: Colors.white,
        // inactiveColorPrimary: Colors.white
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: UnreadMessageProvider(_hasUnreadMessages), // Share state
      child: PersistentTabView(
        context,
        // hideNavigationBar: true,
        backgroundColor: basecolorG,
        navBarHeight: 8.h(context),
        padding: NavBarPadding.symmetric(horizontal: 1.w(context)),
        screens: _buildScreens(),
        controller: tabController,
        items: _navBarItem(),
      ),
    );
  }
}

class UnreadMessageProvider extends ChangeNotifier {
  bool _hasUnreadMessages;

  UnreadMessageProvider(this._hasUnreadMessages);

  bool get hasUnreadMessages => _hasUnreadMessages;

  set hasUnreadMessages(bool value) {
    _hasUnreadMessages = value;
    notifyListeners();
  }
}
