import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllMessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Messages'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('messages').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          // Process snapshot data and display messages
          final messages = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final data = message.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['text']),
                subtitle: Text('From: ${data['senderId']}'),
              );
            },
          );
        },
      ),
    );
  }
}
