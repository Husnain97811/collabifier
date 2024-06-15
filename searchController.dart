import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class UserProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> searchResults = []; // Add searchResults here

  List<Map<String, dynamic>> get users => _users;

  Future<void> fetchUsers() async {
    // Fetch all users from Firestore and update the list
    final querySnapshot = await _firestore.collection('users').get();
    _users = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    notifyListeners();
  }

  // Function to search for a user (you can reuse this in your Search Screen)
  List<Map<String, dynamic>> searchUsers(String query) {
    if (query.isEmpty) {
      return _users; // Return all users if query is empty
    }
    return _users.where((user) => user['name'].toLowerCase().contains(query.toLowerCase())).toList();
  }
}