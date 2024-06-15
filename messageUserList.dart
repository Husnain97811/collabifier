import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/screens/usersScreens/chatPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:provider/provider.dart';

class MessageUserList extends StatefulWidget {
  const MessageUserList({Key? key}) : super(key: key);

  @override
  State<MessageUserList> createState() => _MessageUserListState();
}

class _MessageUserListState extends State<MessageUserList> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserListProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
          backgroundColor: basecolorG, // Use your own color
        ),
        body: Column(
          children: [
            // Search Bar in Body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<UserListProvider>(
                builder: (context, userListProvider, child) {
                  return _SearchBar(
                    searchController: userListProvider.searchController,
                    onSearchChanged: userListProvider.onSearchChanged,
                  );
                },
              ),
            ),

            Expanded(
              child: Consumer<UserListProvider>(
                builder: (context, userListProvider, child) {
                  return _buildUserList(userListProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(UserListProvider userListProvider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Text('Error while fetching data');
        }

        // Extract the user documents
        userListProvider.allUsers = snapshot.data!.docs;

        // Sort the user documents by last message timestamp
        _sortUsersByLastMessage(userListProvider.allUsers);

        // If no search term, show all users
        if (userListProvider.searchController.text.isEmpty) {
          userListProvider.filteredUsers = userListProvider.allUsers;
        }

        return ListView.builder(
          // reverse: true,
          // physics: ClampingScrollPhysics(),
          itemCount: userListProvider.filteredUsers.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(userListProvider.filteredUsers[index]);
          },
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot userDoc) {
    Map<String, dynamic> data = userDoc.data()! as Map<String, dynamic>;

    // Check if the user is not the current user
    if (auth.currentUser!.email != data['email']) {
      var userId = auth.currentUser!.uid;

      return FutureBuilder<Map<String, dynamic>>(
        future: _getLastMessageAndTimestamp(userId, data['uid']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Extract last message and formatted timestamp
            String? lastMessage = snapshot.data?['lastMessage'];
            String? timestampText = snapshot.data?['timestampText'];

            // Only show the list item if there's a last message
            if (lastMessage != null) {
              // Get the chat room ID to check for unread messages
              List<String> ids = [userId, data['uid']];
              ids.sort();
              String chatRoomId = ids.join("_");

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chatrooms')
                    .doc(chatRoomId)
                    .collection('messages')
                    .where('read', isEqualTo: false)
                    .where('receiverId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (messageSnapshot.hasError) {
                    return Text('Error: ${messageSnapshot.error}');
                  } else {
                    bool hasUnreadMessages =
                        messageSnapshot.data?.docs.isNotEmpty ?? false;

                    return ListTile(
                      subtitle: Text(lastMessage),
                      leading: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 3,
                            color: basecolorG
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(Icons.person_2_outlined),
                        ),
                      ),
                      title: Text(data['name']),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Container(child: hasUnreadMessages? Icon(Icons.circle,color: Colors.green,size: 8.sp(context),) : Icon(Icons.circle,color: Colors.white,))
                        ,Container(child:
                        timestampText != null
                          ? Text(timestampText)
                          : null
                         ,)
                      ],),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => chatpage(
                              receiverUserEmail: data['email'],
                              receiverUserId: data['uid'],
                              userId: auth.currentUser!.uid,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              );
            } else {
              return Container(); // Don't show the list item if no last message
            }
          }
        },
      );
   
   
    } else {
      return Container();
    }
  }
  

  // Function to get the last message timestamp between two users
  Future<Timestamp?> _getLastMessageTimestamp(
      String currentUserId, String otherUserId) async {
    try {
      // Get the current user's userType
      DocumentSnapshot currentUserDoc =
          await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      String currentUserType = currentUserDoc.get('userType');

      // Create the chat room ID (order doesn't matter)
      List<String> ids = [currentUserId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");

      // Fetch the last message from the chat room
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return querySnapshot.docs.first.get('timestamp');
    } catch (error) {
      print("Error getting last message timestamp: $error");
      return null;
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedTime = DateFormat('h:mm a').format(dateTime);
    return formattedTime;
  }

  Future<Map<String, dynamic>> _getLastMessageAndTimestamp(
      String currentUserId, String otherUserId) async {
    try {
      // Create the chat room ID (order doesn't matter)
      List<String> ids = [currentUserId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");
        

      // Fetch the last message from the chat room
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

  Future<void> _sortUsersByLastMessage(List<DocumentSnapshot> userDocs) async {
    Map<DocumentSnapshot, Timestamp?> userDataMap = {};

    for (var userDoc in userDocs) {
      String userId = userDoc['uid'];
      Timestamp? lastMessageTimestamp =
          await _getLastMessageTimestamp(auth.currentUser!.uid, userId);

      userDataMap[userDoc] = lastMessageTimestamp;
    }

    // Sorting logic (New users on top)
    userDocs.sort((a, b) {
      Timestamp? timestampA = userDataMap[a];
      Timestamp? timestampB = userDataMap[b];

      // Handle null timestamps correctly:
      if (timestampA == null && timestampB == null) {
        return 0; // Both have no messages, sort them the same
      } else if (timestampA == null) {
        return 1; // User with no messages goes to the bottom
      } else if (timestampB == null) {
        return -1; // User with no messages goes to the bottom
      } else {
        // Compare timestamps (Recent chats on bottom)
        return timestampA.compareTo(timestampB);
      }
    });
  }
}

// Custom widget for the search bar
class _SearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function onSearchChanged;

  const _SearchBar({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: EdgeInsets.only(left: 10.0, right: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
          prefixIcon: Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged(); // Update the filtered users
                  },
                  icon: Icon(Icons.close),
                )
              : null,
        ),
      ),
    );
  }
}

// UserListProvider class
class UserListProvider extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  List<DocumentSnapshot> allUsers = [];
  List<DocumentSnapshot> filteredUsers = [];

  void onSearchChanged() {
    String searchTerm = searchController.text.toLowerCase();
    filteredUsers = allUsers.where((user) {
      String userName = user['name'].toLowerCase();
      return userName.contains(searchTerm);
    }).toList();
    notifyListeners();
  }
}