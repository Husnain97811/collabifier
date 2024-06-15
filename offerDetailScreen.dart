import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/controllers/messages/Message.dart';
import 'package:collabifier/controllers/messages/chatService.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/screens/usersScreens/messageUserList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserId;
  final String receiverUserEmail;

  const ChatPage({Key? key, required this.receiverUserId, required this.receiverUserEmail}) : super(key: key);

  
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  int _unreadCount = 0;
  late String currentUserId;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    currentUserId = auth.currentUser!.uid;
    chatRoomId = _calculateChatRoomId();
    _fetchUnreadCount();
    _listenForUnreadCountChanges();
  }

  // Fetch unread count from Firestore
  void _fetchUnreadCount() async {
    DocumentSnapshot snapshot = await firestore.collection('users').doc(auth.currentUser!.uid).get();
    setState(() {
      _unreadCount = (snapshot.data() as Map<String, dynamic>)['unreadCount'] ?? 0; 
    });
  }

  // Listen for changes in unread count
  void _listenForUnreadCountChanges() {
    firestore.collection('users').doc(auth.currentUser!.uid).snapshots().listen((snapshot) {
      setState(() {
        _unreadCount = (snapshot.data() as Map<String, dynamic>)['unreadCount'] ?? 0;
      });
    });
  }

  // Send a new message to Firestore
  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Get current user info
      final currentUserId = auth.currentUser!.uid;
      final currentUserEmail = auth.currentUser!.email!;
      final timestamp = Timestamp.now();

      // Add new message to Firestore under 'chatrooms' collection
      await firestore
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'receiverId': widget.receiverUserId,
        'message': _messageController.text,
        'timestamp': timestamp,
        'read': false, // Initially unread
      });

      // Update last message and timestamp in the 'users' collection
      await firestore.collection('users').doc(currentUserId).update({
        'lastmessage': _messageController.text, // Update the last message for the current user
        'lasttime': timestamp, 
      });

      // Update last message and timestamp in the 'users' collection (for the receiver)
      await firestore.collection('users').doc(widget.receiverUserId).update({
        'lastmessage': _messageController.text, // Update the last message for the receiver
        'lasttime': timestamp, 
      });

      // Clear the text field
      _messageController.clear();

      // Update the unread count for the receiver
      await firestore.collection('users').doc(widget.receiverUserId).update({
        'unreadCount': FieldValue.increment(1), 
      });
    }
  }

  // Function to mark messages as read when the user opens the chat
  void _markMessagesAsRead() async {
    // Update all messages in the chat room to 'read'
    await firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.update({'read': true});
      });
    });

    // Decrement unread count for the receiver
    await firestore.collection('users').doc(widget.receiverUserId).update({
      'unreadCount': FieldValue.increment(-_unreadCount), 
    });

    // Reset the unread count for the current user
    _unreadCount = 0; 
  }

  String _calculateChatRoomId() {
    // Construct the chat room ID for uniqueness
    List<String> ids = [auth.currentUser!.uid, widget.receiverUserId];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: basecolorG, // Use your base color
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('chatrooms') // Now fetching from 'chatrooms'
                    .doc(chatRoomId) // Assuming receiverUserId is the chat room ID 
                    .collection('messages') 
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Build the chat UI
                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification &&
                          scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
                        // User scrolled to the bottom - mark messages as read
                        _markMessagesAsRead();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        final senderId = messageData['senderId'];
                        final message = messageData['message'];
                        final timestamp = messageData['timestamp'];
                        final readStatus = messageData['read'];

                        // Format the timestamp
                        final formattedTimestamp = DateFormat('h:mm a').format(timestamp.toDate());

                        return ListTile(
                          title: Text(message),
                          // trailing: Text(formattedTimestamp),
                          leading: CircleAvatar(
                            // Display profile picture if available
                            // ... 
                          ),
                          // Align messages based on sender
                          contentPadding: senderId == auth.currentUser!.uid ? EdgeInsets.only(left: 60) : EdgeInsets.only(right: 60),
                          // Add a checkmark icon for read messages
                          trailing: readStatus ? Icon(Icons.check) : null, // Use the 'trailing' widget 
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//   String _calculateChatRoomId() {
//   // Construct the chat room ID for uniqueness
//   List<String> ids = [auth.currentUser!.uid, widget.receiverUserId];
//   ids.sort();
//   return ids.join("_");
// }
}