// import 'dart:async';
// import 'dart:ffi';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:collabifier/reUseAbleWidgets/contants.dart';
// import 'package:collabifier/screens/usersScreens/chatPage.dart';
// import 'package:collabifier/session_manager/userSession.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:mediaquery_sizer/mediaquery_sizer.dart';
// import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

// // ... (rest of your code)

// class ServiceDetailScreen extends StatefulWidget {
//   final String userId;

//   const ServiceDetailScreen({Key? key, required this.userId}) : super(key: key);

//   @override
//   State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
// }

// class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
//   final userData = FirebaseFirestore.instance.collection('users');
//   final services = FirebaseFirestore.instance.collection('services');

//   // To store fetched data
//   Map<String, dynamic>? influencerData;
//   List<dynamic>? platformData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInfluencerData();
//   }

//   Future<void> _fetchInfluencerData() async {
//     // Fetch influencer data
//     DocumentSnapshot influencerDoc = await userData.doc(widget.userId).get();
//     influencerData = influencerDoc.data() as Map<String, dynamic>?;

//     // Fetch platform data from the influencer document
//     platformData = influencerData?['platformData'];

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: basecolorG,
//         title: const Text('Influencer Details'),
//         actions: [
//           IconButton(
//             onPressed: () {
//               // Get current user ID and email
//               String? currentUserId = sessionController().userId.toString();
//               String? currentUserEmail = sessionController().email.toString();

//               if (influencerData != null &&
//                   currentUserId != null &&
//                   currentUserEmail != null) {
//                 // Navigate to chat page with receiver data
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ChatPage(
//                       receiverUserEmail: influencerData!['email'],
//                       receiverUserId: influencerData!['uid'],
//                       userId: currentUserId,
//                     ),
//                   ),
//                 );
//               }
//             },
//             icon: const Icon(Icons.message),
//           )
//         ],
//       ),
//       body: influencerData == null
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Display influencer's profile image
//                   Padding(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 6.sp(context), vertical: 3.h(context)),
//                     child: SizedBox(
//                         // height: 200,
//                         child: Container(
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: basecolorlight,
//                       ),
//                       height: 70.sp(context),
//                       width: 80.sp(context),
//                       alignment: Alignment.center,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(100),
//                         child: CachedNetworkImage(
//                           height: 80.sp(context),
//                           width: 80.sp(context),
//                           imageUrl: influencerData!['profile'] ?? '',
//                           fit: BoxFit.cover,
//                           placeholder: (context, url) =>
//                               const Center(child: CircularProgressIndicator()),
//                           errorWidget: (context, url, error) =>
//                               const Icon(Icons.person),
//                         ),
//                       ),
//                     )),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 6.sp(context)),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             const Text(
//                               'Name : ',
//                               style: TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.bold),
//                             ),
//                             Text(
//                               '${influencerData!['name']}',
//                               style: const TextStyle(
//                                   fontSize: 20, fontWeight: FontWeight.normal),
//                             ),
//                           ],
//                         ),

//                         SizedBox(height: 6.h(context)),
//                         const Text(
//                           'Active Social Media Platforms :',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.w600),
//                         ),
//                         const SizedBox(height: 10),
//                         // Display platform data
//                         if (platformData == null || platformData!.isEmpty)
//                           const Text('No platform data available')
//                         else
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: platformData!.map((platform) {
//                               return Column(
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const Text(
//                                         ' Platform :  ',
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         '${platform['name']}',
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     ],
//                                   ),

//                                   // FOLLOWERS

//                                   Row(
//                                     children: [
//                                       const Text(
//                                         ' Followers :  ',
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         '${platform['followers']}',
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     ],
//                                   ),

//                                   //  PRICE

//                                   Row(
//                                     children: [
//                                       const Text(
//                                         ' Starting Price :  ',
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text (
//                                         '${NumberFormat.compact().format(
//                                           int.tryParse(platform['price']
//                                                   .toString()) ??
//                                               0,
//                                         )}',
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
                            
//                           ),

//                         SizedBox(height: 10.h(context)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }
