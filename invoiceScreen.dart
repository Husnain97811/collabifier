import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collabifier/controllers/addServiceController.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/reUseAbleWidgets/conts%20+%20comps.dart';
import 'package:collabifier/screens/usersScreens/chatPage.dart';
import 'package:collabifier/screens/usersScreens/homeScreen/influencers.dart';
import 'package:collabifier/session_manager/userSession.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:screenshot/screenshot.dart'; // Import screenshot package
import 'package:image_gallery_saver/image_gallery_saver.dart'; // Import image gallery saver
import 'package:path_provider/path_provider.dart'; // Import path provider
import 'package:http/http.dart' as http; // Import http package for email sending

class InvoiceScreen extends StatefulWidget {
  final String influencerName;
  final String influencerId;
  final String influencerEmail;
  final double totalPrice; // Pass the total price without 5% addition
  final String bookingId;
  final DateTime bookingDate;
  final List<Map<String, dynamic>> platformData;

  InvoiceScreen({
    required this.influencerName,
    required this.influencerId,
    required this.influencerEmail,
    required this.totalPrice,
    required this.bookingId,
    required this.bookingDate,
    required this.platformData,
  });

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _screenshotController = ScreenshotController(); // Initialize screenshot controller
  XFile? _selectedImage;
  File? _imageFile; // Store the image as a File
  String? _imageUrl; // Store the uploaded image URL
  final _storage = FirebaseStorage.instance; // Initialize Firebase Storage
  bool _isUploading = false; // Flag to track upload status
  bool _showInvoice = false; // Flag to control invoice visibility
  bool _showUploadedImage = false; // Flag to show uploaded image
  bool _invoiceSaved = false; // Flag to track if invoice is saved
  bool _showUploadButtons = true; // Flag to control upload button visibility

  // Replace these with your actual values
  final String adminEmail = "admin@example.com"; 
  final String sendGridApiKey = "YOUR_SENDGRID_API_KEY"; 

  // Function to pick an image from the gallery
  Future _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = pickedImage;
      // Convert XFile to File
      if (pickedImage != null) {
        _imageFile = File(pickedImage.path);
      }
    });
  }

  // Function to upload the image to Firebase Storage
  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a screenshot first')),
      );
      return;
    }

    setState(() {
      _isUploading = true; // Set uploading flag to true
    });

    try {
      // Create a reference to the image in Firebase Storage
      Reference ref = _storage.ref().child('bookings').child(widget.bookingId).child('screenshot.jpg'); // Use booking ID for reference

      // Upload the image
      UploadTask uploadTask = ref.putFile(_imageFile!);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded image
        _imageUrl = await ref.getDownloadURL();

        // Update the booking document with the image URL
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .update({
          'screenshotUrl': _imageUrl, // Add the screenshot URL to the booking document
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot uploaded successfully!')),
        );

        // Show the invoice details on the screen after successful upload
        setState(() {
          _showInvoice = true;
          _showUploadButtons = false; // Hide upload buttons after showing invoice
        });

        // Send email notification to admin
        await _sendEmailNotification();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading screenshot: ${e.toString()}')),
      );
      setState(() {
        _isUploading = false; // Set uploading flag to false
      });
    }
  }

  // Function to save the invoice to the gallery
  Future<void> _saveInvoiceToGallery() async {
    // Capture the screenshot 
    final image = await _screenshotController.captureFromWidget(
      Scaffold(
        appBar: AppBar(
          title: Text('Invoice'),
          backgroundColor: basecolorG,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your company logo or name here
                Center(
                  child: Text(
                    'Collabifier',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Show the invoice details on the screen (only after upload)
                if (_showInvoice)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice details
                      Text(
                        'Invoice Number: ${widget.bookingId}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(widget.bookingDate)}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      // Service details
                      Text(
                        'Service:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Influencer: ${widget.influencerName}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      // Display platform prices
                      for (var platform in widget.platformData)
                        Text(
                          'Platform: ${platform['name']}, Price: Rs ${platform['price'].toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),

                      // Total amount with 5% added
                      SizedBox(height: 3.h(context)),
                      Text(
                        'Total Price: Rs ${widget.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: basecolorG,
                        ),
                      ),
                      SizedBox(height: 4.h(context)),

                      SizedBox(height: 30),
                    ],
                  ),

                  // Button to upload payment screenshot (show only before invoice is displayed)
                  if (_showUploadButtons)
                    ElevatedButton(
                      onPressed: _getImage,
                      child: Text('Upload Transaction Screenshot'),
                    ),
                  SizedBox(height: 10),

                  // Display the selected image if available
                  if (_selectedImage != null)
                    Image.file(_imageFile!, // Use _imageFile here
                        width: 200, height: 200),

                  // Button to upload the image to Firebase Storage (show only before invoice is displayed)
                  if (_showUploadButtons && _imageFile != null)
                    ElevatedButton(
                      onPressed: _isUploading ? null : _uploadImage,
                      child: _isUploading
                          ? CircularProgressIndicator() // Show circular progress during upload
                          : Text('Upload Screenshot to Firebase'),
                    ),

                  // Show the uploaded image after successful upload
                  if (_showUploadedImage && _imageUrl != null)
                    CachedNetworkImage(
                      imageUrl: _imageUrl!,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      width: 200,
                      height: 200,
                    ),
                ],
              ),
            ),
          ),
        ),
      
    );

    if (image != null) {
      // Request storage permissions
      // var status = await Permission.storage.status;
      // if (status.isGranted) {
        // Save image to gallery if permission granted
        final result = await ImageGallerySaver.saveImage(image, quality: 85);
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invoice saved to gallery!'),
              duration: Duration(seconds: 2), // Wait for 2 seconds
            ),
          );

          // Navigate back to home screen after the snackbar closes
          await Future.delayed(Duration(seconds: 2));
          // Replace with your logic to navigate back to the home screen 
          Navigator.of(context).pop(); 

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save invoice.')),
          );
        }
      // } else if (status.isDenied) {
      //   // Handle denied permission (e.g., show a message)
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Storage permission denied.')),
      //   );
      // } else if (status.isPermanentlyDenied) {
      //   // Handle permanently denied (e.g., guide the user to app settings)
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Storage permission permanently denied.')),
      //   );
      //   await openAppSettings(); // Open app settings 
      // }
    }
  }

  // Function to send email notification to the admin
  Future<void> _sendEmailNotification() async {
    String emailBody = "New Invoice Generated:\n"
        "Invoice Number: ${widget.bookingId}\n"
        "Date: ${DateFormat('yyyy-MM-dd').format(widget.bookingDate)}\n"
        "Service: ${widget.influencerName}\n"
        "Platform Prices:\n";
    for (var platform in widget.platformData) {
      emailBody += "  ${platform['name']}: Rs ${platform['price'].toStringAsFixed(2)}\n";
    }
    emailBody += "Total Price: Rs ${widget.totalPrice.toStringAsFixed(0)}"; // Use widget.totalPrice here

    try {
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer $sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [{'email': adminEmail}],
              'subject': 'New Invoice Generated on Collabifier',
            },
          ],
          'from': {'email': 'noreply@example.com'}, // Replace with your sending email
          'content': [
            {'type': 'text/plain', 'value': emailBody},
          ],
        }),
      );

      if (response.statusCode == 202) {
        print("Email sent successfully!");
      } else {
        print("Error sending email: ${response.body}");
      }
    } catch (e) {
      print("Error sending email: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the price with 5% added
    // double priceWith5Percent = widget.totalPrice + (widget.totalPrice * 0.05);

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice'),
        backgroundColor: basecolorG,
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your company logo or name here
                Center(
                  child: Text(
                    'Collabifier',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Show the invoice details on the screen (only after upload)
                if (_showInvoice)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Invoice details
                      Text(
                        'Invoice Number: ${widget.bookingId}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(widget.bookingDate)}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      // Service details
                      Text(
                        'Service:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Influencer: ${widget.influencerName}',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      // Display platform prices
                      for (var platform in widget.platformData)
                        Text(
                          'Platform: ${platform['name']}, Price: Rs ${platform['price'].toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),

                    
                      // Total amount with 5% added
                      SizedBox(height: 3.h(context)),
                      Text(
                        'Total Price: Rs ${widget.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: basecolorG,
                        ),
                      ),
                      SizedBox(height: 4.h(context)),

                      SizedBox(height: 30),
                    ],
                  ),

                // Show the total price before uploading the screenshot
                if (_showUploadButtons)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Total amount with 5% added
                      SizedBox(height: 3.h(context)),
                      Text(
                        'Total Price: Rs ${widget.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: basecolorG,
                        ),
                      ),
                      SizedBox(height: 4.h(context)),
                        Text(
                          'Please pay to this Account # 444444444444 and upload screenshot to verify your payment',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        SizedBox(height: 3.h(context)),

                    ],
                  ),

                // Button to upload payment screenshot (show only before invoice is displayed)
                if (_showUploadButtons)
                  ElevatedButton(
                    onPressed: _getImage,
                    child: Text('Upload Transaction Screenshot'),
                  ),
                SizedBox(height: 10),

                // Display the selected image if available
                if (_selectedImage != null)
                  Image.file(_imageFile!, // Use _imageFile here
                      width: 200, height: 200),

                // Button to upload the image to Firebase Storage (show only before invoice is displayed)
                if (_showUploadButtons && _imageFile != null)
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadImage,
                    child: _isUploading
                        ? CircularProgressIndicator() // Show circular progress during upload
                        : Text('Upload Screenshot to Firebase'),
                  ),

                // Show the uploaded image after successful upload
                if (_showUploadedImage && _imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    width: 200,
                    height: 200,
                  ),

                // Save to Gallery button (show only after invoice is displayed)
                if (_showInvoice)
                  ElevatedButton(
                    onPressed: _saveInvoiceToGallery,
                    child: Text('Save to Gallery'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to navigate to influencer screen after invoice is saved
  Future<void> _navigateToInfluencerScreen() async {
    if (_invoiceSaved) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => influencerScreen()),
      );
    } else {
      // Show error message if invoice is not saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please save the invoice before proceeding.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Add a listener to the _invoiceSaved flag to navigate when it changes to true
    _invoiceSaved = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _invoiceSaved = false;
    });
  }
}