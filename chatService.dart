
// chatservice
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/controllers/messages/Message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatService extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // send message
  Future<void> sendMessage(String receiverId, String message, String receiverName, String chatRoomId) async {
    // Get user info
    final String currentUserId = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Construct chat room ID for uniqueness
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    // Add new message to the 'messages' collection within the chat room
    await firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'read': false, // Initially unread
    });

    // Update sender's last message and timestamp in the 'users' collection
    await firestore.collection('users').doc(currentUserId).update({
      'lastmessage': message,
      'lasttime': timestamp,
    });
    // await firestore.collection('users').doc(currentUserId).set({
    //   'read': false
    // });
  }

  Stream<QuerySnapshot> getmessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];

    ids.sort();
    String chatRoomId = ids.join("_");

    return firestore
        .collection('chatrooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}