import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/controllers/searchController.dart'; // Assuming this is where you have UserProvider
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late SearchOptions _searchOptions;

  @override
  void initState() {
    super.initState();
    _searchOptions = Provider.of<SearchOptions>(context, listen: false);
  }


    @override
  void dispose() {
    _searchController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context); 
    _searchOptions = Provider.of<SearchOptions>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: basecolorG,
        title: Text('Services'),
      ),
      body: Column(
        children: [
         
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(23)),
                hintText: 'Search Services',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _performSearch(value, userProvider);
              },
            ),
          ),
          // Use Consumer to listen for changes in searchResults from UserProvider
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return Expanded(
                child: ListView.builder(
                  itemCount: userProvider.searchResults.length,
                  itemBuilder: (context, index) {
                    final result = userProvider.searchResults[index];
                    return ListTile(
                      title: Text(result['title']),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper function to build a selection button
  Widget _buildSelectionButton(String label, bool isSelected, Function onPressed) {
    return ElevatedButton(
      onPressed: onPressed as void Function()?,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Function to perform search
  Future<void> _performSearch(String query, UserProvider userProvider) async {
    if (query.isEmpty) {
      userProvider.searchResults = [];
      userProvider.notifyListeners();
      return;
    }

    final db = FirebaseFirestore.instance;
    userProvider.searchResults = [];

    final QuerySnapshot servicesSnapshot = await db
        .collection('services')
        .where('title', isGreaterThanOrEqualTo: query.toLowerCase())
        .get();
    userProvider.searchResults.addAll(
        servicesSnapshot.docs.map((doc) => {'title': doc['title']}).toList());

    userProvider.notifyListeners();
  }
}

class SearchOptions with ChangeNotifier {
  bool showServices = true; 

  // Constructor (optional)
  SearchOptions({this.showServices = true});

  void toggleServices() {
    showServices = !showServices;
  }
}