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
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class chatpage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserId;
  final String? receiverName;
  const chatpage({
    super.key,
    this.receiverName,
    required this.receiverUserEmail,
    required this.receiverUserId,
    required String userId,
  });

  @override
  State<chatpage> createState() => _chatpageState();
}

class _chatpageState extends State<chatpage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Stream subscription to listen for new messages
  StreamSubscription<QuerySnapshot>? _messageStreamSubscription;

  // Function to mark messages as read
  void _markMessagesAsRead(String chatRoomId) async {
    try {
      // Get unread messages for the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('read', isEqualTo: false)
          .where('receiverId', isEqualTo: auth.currentUser!.uid)
          .get();

      // Update 'read' status to true for each unread message
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'read': true});
      });
    } catch (error) {
      print("Error marking messages as read: $error");
    }
  }

  // Function to send a message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      // Get the chat room ID
      String chatRoomId = _getChatRoomId();

      await _chatService.sendMessage(
          widget.receiverUserId, _messageController.text,
          widget.receiverName.toString(), chatRoomId);
      _messageController.clear();
    }
  }

  // Function to get the last message and timestamp
  Future<Map<String, dynamic>> _getLastMessageAndTimestamp(
      String currentUserId, String otherUserId) async {
    try {
      List<String> ids = [currentUserId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {};
      }

      Map<String, dynamic> lastMessageData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;

      String timestampText = _formatTimestamp(lastMessageData['timestamp']);

      return {
        'lastMessage': lastMessageData['message'],
        'timestampText': timestampText,
      };
    } catch (error) {
      print("Error getting last message timestamp: $error");
      return {};
    }
  }

  // Function to format the timestamp
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('h:mm a').format(dateTime.toLocal());
    return formattedTime;
  }

  @override
  void initState() {
    super.initState();

    // Listen for new messages in the chat room
    _messageStreamSubscription = _chatService.getmessages(
            widget.receiverUserId, auth.currentUser!.uid)
        .listen((snapshot) {
      // Mark all unread messages as read
      if (snapshot.docChanges.isNotEmpty) {
        _markMessagesAsRead(_getChatRoomId());
      }
    });
  }

  @override
  void dispose() {
    // Call super.dispose() at the beginning of dispose()
    super.dispose();
    // Dispose of any resources held by your state
    _messageStreamSubscription?.cancel();
    _messageController.dispose();
  }

  // Helper function to get the chat room ID
  String _getChatRoomId() {
    List<String> ids = [auth.currentUser!.uid, widget.receiverUserId];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: basecolorG,
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // _build Message List
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getmessages(
          widget.receiverUserId, auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // Get the list of documents from the snapshot
        List<DocumentSnapshot> documents = snapshot.data!.docs;

        // Sort the documents in reverse order (newest on top)
        documents.sort((a, b) {
          Timestamp timestampA = a['timestamp'] as Timestamp;
          Timestamp timestampB = b['timestamp'] as Timestamp;
          return timestampB.compareTo(timestampA);
        });

        return ListView.builder(
          reverse: true,
          itemCount: documents.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(documents[index]);
          },
        );
      },
    );
  }

    //  Build message Item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    Timestamp timestamp = data['timestamp'] as Timestamp;
    DateTime dateTime = timestamp.toDate();
    String time = DateFormat.jm().format(dateTime.toLocal()); // Format time to display in AM/PM format

    // Determine the alignment of the message bubble based on the sender
    var alignment = (data['senderId'] == auth.currentUser!.uid)
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    // Determine the color of the message bubble based on the sender
    var bubbleColor = (data['senderId'] == auth.currentUser!.uid)
        ? basecolorlight
        : Colors.grey[200];

    // Determine the position of the text based on the sender
    var textPosition = (data['senderId'] == auth.currentUser!.uid)
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    var margin = (data['senderId'] == auth.currentUser!.uid)
        ? EdgeInsets.only(left: 12.w(context), top: 1.2.h(context))
        : EdgeInsets.only(right: 12.w(context), top: 1.2.h(context));

    // Check if the message is unread
    bool isUnread = data['read'] != true; // Message is unread if `read` is false
    bool isSentByCurrentUser = data['senderId'] == auth.currentUser!.uid;
    bool isRead = data['read']; // Directly use the `read` field 

    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
         
        LayoutBuilder(
  builder: (context, constraints) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      // Use constraints to define the width and height
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth * 0.8, // Adjust maxWidth as needed
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Allow horizontal scrolling
        child: Column(
          crossAxisAlignment: textPosition,
          children: [
            // Use a ConstrainedBox to limit the width of the text
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.7), // Adjust maxWidth as needed
              child: Text(
                data['message'],
                style: TextStyle(fontSize: 16.sp(context)),
              ),
            ),
            Text(
              time.toString(),
              style: TextStyle(fontSize: 8.sp(context)),
            ),
                  // Show ticks based on message status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // Align ticks to the right
                    children: [
                      // Show grey tick for unread messages
                      if (isSentByCurrentUser && isUnread)
                        Icon(
                          Icons.check,
                          color: Colors.grey,
                          size: 16.sp(context), // Adjust size as needed
                        ),
                      // Show green tick if the message is read by the receiver
                      if (isSentByCurrentUser && isRead)
                        Icon(
                          Icons.checklist,
                          color: Colors.green,
                          size: 19.sp(context), // Adjust size as needed
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
       
       
       
         },  )
        ],
      ),
    );
  }

  //  build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: TextFormField(
            decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
            controller: _messageController,
          ),
        )),
        //send button
        IconButton(
            onPressed: sendMessage,
            icon: Container(
                height: 45.sp(context),
                width: 45.sp(context),
                decoration: BoxDecoration(
                    color: basecolorG, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.arrow_upward)))
      ],
    );
  }
}