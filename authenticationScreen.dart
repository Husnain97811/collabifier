import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  void _checkCurrentUser() {
    _auth.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  void _signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      setState(() {
        _user = userCredential.user;
      });
    } catch (e) {
      print('Failed to sign in anonymously: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Authentication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _user == null
                ? ElevatedButton(
                    onPressed: _signInAnonymously,
                    child: Text('Sign In Anonymously'),
                  )
                : Column(
                    children: [
                      Text('Signed in as: ${_user!.uid}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _auth.signOut();
                        },
                        child: Text('Sign Out'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
