import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // For icons
import 'package:provider/provider.dart';

class InvestorServicesScreen extends StatefulWidget {
  @override
  _InvestorServicesScreenState createState() =>
      _InvestorServicesScreenState();
}

class _InvestorServicesScreenState extends State<InvestorServicesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Map for platform icons (adjust as needed)
  final Map<String, IconData> platformIcons = {
    'Facebook': FontAwesomeIcons.facebookF,
    'Instagram': FontAwesomeIcons.instagram,
    'Youtube': FontAwesomeIcons.squareYoutube,
    'Twitter': FontAwesomeIcons.twitter,
    'LinkedIn': FontAwesomeIcons.linkedinIn, // Add LinkedIn icon
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Services"),
        backgroundColor: Colors.blue, // Example app bar color
      ),
      body: ChangeNotifierProvider(
        create: (context) => PlatformProvider(), // Create the provider
        child: Consumer<PlatformProvider>(
          builder: (context, platformProvider, child) {
            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('services')
                  .where('uid', isEqualTo: currentUserId) // Exclude current user's services
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final services = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final timestamp = service.id;
                      return Dismissible(
                        key: Key(timestamp), // Ensure a unique key for each item
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteService(timestamp);
                        },
                        child: Card(
                          margin: EdgeInsets.all(10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Or your desired background color
                              borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
                            ),
                            child: ListTile(
                              onTap: () {
                                _showEditDialog(
                                    service.data() as Map<String, dynamic>,
                                    timestamp,
                                    platformProvider); // Pass the provider to the dialog
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              ),
                              title: Text(
                                service['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black, // Or your desired text color
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.money,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'Price: \$${service['price']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black, // Or your desired text color
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Platforms:                                  '),
                                      SizedBox(width: 5),
                                      ..._getPlatformsIcons(service['platformData']), // Spread the icons
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  // Helper function to get platform icons
  List<Widget> _getPlatformsIcons(String platformData) {
    if (platformData != null && platformData.isNotEmpty) {
      List<String> platforms = platformData.split(', ');
      return platforms
          .map((platform) => Icon(
                _getPlatformIcon(platform.trim().capitalize()) ?? Icons.error,
                size: 18,
                color: Colors.blue,
              ))
          .toList();
    }
    return []; // Return an empty list if no platform data
  }

  IconData? _getPlatformIcon(String? platformName) {
    if (platformName != null) {
      return platformIcons[platformName];
    }
    return null;
  }

  // Function to show edit dialog
// ... (rest of your code) ...

Future<void> _showEditDialog(
    Map<String, dynamic> service, String timestamp, PlatformProvider platformProvider) async {
  TextEditingController nameController = TextEditingController(text: service['name']);
  TextEditingController priceController = TextEditingController(text: service['price'].toString());

  // Update selectedPlatforms based on existing platformData and notify listeners
  platformProvider.updateSelectedPlatforms(service['platformData']); 

  // Create a stateful widget for the dialog
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder( // Use StatefulBuilder for dialog state
        builder: (context, setStateDialog) { // setStateDialog is for the dialog
          return AlertDialog(
            title: Text('Edit Service'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Service Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                // Add a list of checkboxes for platforms
                Column(
                  children: platformProvider.platformNames
                      .map((platform) => CheckboxListTile(
                    title: Text(platform),
                    value: platformProvider.selectedPlatforms[platform],
                    onChanged: (bool? value) {
                      platformProvider.updateSelectedPlatform(platform, value!); // Update the provider
                      setStateDialog(() {}); // Rebuild the dialog
                    },
                  ))
                      .toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _updateService(
                      timestamp, nameController.text, double.tryParse(priceController.text) ?? 0.0, platformProvider);
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

// ... (rest of your code) ...
        

  // Function to update a service
  void _updateService(String timestamp, String name, double price, PlatformProvider platformProvider) {
    // Get the selected platforms
    List<String> selectedPlatformList = platformProvider.selectedPlatforms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Convert selected platforms to comma-separated string
    String platformData = selectedPlatformList.join(', ');

    _firestore
        .collection('services')
        .doc(timestamp)
        .update({
      'name': name,
      'price': price,
      'platformData': platformData,
    });
  }

  // Function to delete a service
  void _deleteService(String timestamp) {
    _firestore
        .collection('services')
        .doc(timestamp)
        .delete();
  }
}

// Platform Provider
class PlatformProvider extends ChangeNotifier {
  final List<String> platformNames = [
    'Facebook',
    'Instagram',
    'Youtube',
    'Twitter',
    'LinkedIn',
  ];
  Map<String, bool> selectedPlatforms = {
    'Facebook': false,
    'Instagram': false,
    'Youtube': false,
    'Twitter': false,
    'LinkedIn': false,
  };

  void updateSelectedPlatforms(String platformData) {
    selectedPlatforms = {
      for (String platform in platformNames)
        platform: platformData.split(', ').contains(platform)
    };
    notifyListeners(); // Notify listeners of changes
  }

  void updateSelectedPlatform(String platform, bool value) {
    selectedPlatforms[platform] = value;
    notifyListeners(); // Notify listeners of changes
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}