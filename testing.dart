// // import 'package:flutter/material.dart';

// // void main() {
// //   runApp(MaterialApp(
// //     title: 'Checkbox Example',
// //     home: CheckboxExample(),
// //   ));
// // }

// // class CheckboxExample extends StatefulWidget {
// //   @override
// //   _CheckboxExampleState createState() => _CheckboxExampleState();
// // }

// // class _CheckboxExampleState extends State<CheckboxExample> {
// //   bool _showChannelInfo1 = false;
// //   bool _showChannelInfo2 = false;
// //   bool _showChannelInfo3 = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Checkbox Example'),
// //       ),
// //       body: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               children: [
// //                 Checkbox(
// //                   value: _showChannelInfo1,
// //                   onChanged: (value) {
// //                     setState(() {
// //                       _showChannelInfo1 = value!;
// //                     });
// //                   },
// //                 ),
// //                 Text('Option 1'),
// //               ],
// //             ),
// //             if (_showChannelInfo1) ...[
// //               TextFormField(
// //                 decoration: InputDecoration(labelText: 'Channel Name 1'),
// //               ),
// //               TextFormField(
// //                 decoration: InputDecoration(labelText: 'Channel URL 1'),
// //               ),
// //             ],
// //             Row(
// //               children: [
// //                 Checkbox(
// //                   value: _showChannelInfo2,
// //                   onChanged: (value) {
// //                     setState(() {
// //                       _showChannelInfo2 = value!;
// //                     });
// //                   },
// //                 ),
// //                 Text('Option 2'),
// //               ],
// //             ),
// //             if (_showChannelInfo2) ...[
// //               TextFormField(
// //                 decoration: InputDecoration(labelText: 'Channel Name 2'),
// //               ),
// //               TextFormField(
// //                 decoration: InputDecoration(labelText: 'Channel URL 2'),
// //               ),
// //             ],
// //             Row(
// //               children: [
// //                 Checkbox(
// //                   value: _showChannelInfo3,
// //                   onChanged: (value) {
// //                     setState(() {
// //                       _showChannelInfo3 = value!;
// //                     });
// //                   },
// //                 ),
// //                 Text('Option 3'),
// //               ],
// //             ),
// //             if (_showChannelInfo3) ...[
// //               TextFormField(
// //                 decoration: InputDecoration(labelText: 'Channel Name 3'),
// //               ),
// //               TextFormField(
// //                 decoration: InputDecoration(labelText: 'Channel URL 3'),
// //               ),
// //             ],
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }


// import 'package:flutter/material.dart';

// class UserDetailsScreen extends StatefulWidget {
//   @override
//   _UserDetailsScreenState createState() => _UserDetailsScreenState();
// }

// class _UserDetailsScreenState extends State<UserDetailsScreen> {
//   String _dropdownValue = 'Option 1';
//   bool _showTextField2 = false;
//   bool _showTextField3 = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('User Details'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.0),
     
//       ),
//     );
//   }
// }

// // Show this screen using showModalBottomSheet
// void showUserDetailsScreen(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     builder: (BuildContext context) {
//       return UserDetailsScreen();
//     },
//   );
// }
