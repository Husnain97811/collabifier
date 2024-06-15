// ignore_for_file: prefer_final_fields, unused_field, unused_local_variable, prefer_const_constructors, unused_element

import 'dart:io';

import 'package:collabifier/auth_Screens/login_Screen.dart';
import 'package:collabifier/controllers/signUpController.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/reUseAbleWidgets/conts%20+%20comps.dart';
import 'package:collabifier/state_management/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:provider/provider.dart';

class signupScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return signupScreenState();
  }
}

class signupScreenState extends State<signupScreen> {
  // Add a GlobalKey to manage the form
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController receiverId = TextEditingController();
  TextEditingController message = TextEditingController();

  //  late final File _imageFile;
  File? _imageFile;
  final picker = ImagePicker();

  ///       CHECK FIELD IS EMPTY
  ///
  bool isAnyFieldEmpty() {
    return nameController.text.isEmpty ||
        contactController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty;
  }

  var options = ['Student', 'Teacher'];
  var _currentSelectedItem = "Student";
  var rool = "Student";

  bool _obscureText = true;

  String _selectedChoice = 'Influencer'; // Default choice

  void _updateChoice(String choice) {
    setState(() {
      _selectedChoice = choice;
    
    });
  }

  // State to manage the selected platform choices
  List<Map<String, dynamic>> platformChoices = [
    {
      'name': 'YouTube',
      'url': '',
      'channelName': '',
      'price': '0', // Changed price to a String to store it
      'selected': false
    },
    {
      'name': 'Facebook',
      'url': '',
      'channelName': '',
      'price': '0', // Changed price to a String to store it
      'selected': false
    },
    {
      'name': 'Instagram',
      'url': '',
      'channelName': '',
      'price': '0', // Changed price to a String to store it
      'selected': false
    },
    {
      'name': 'Twitter',
      'url': '',
      'channelName': '',
      'price': '0', // Changed price to a String to store it
      'selected': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Create an instance of AuthService
    // final AuthService authService = AuthService();
    //   CREATE REALTIME DATABASE referrnce
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');

    final authProvider = Provider.of<AuthProvider>(context);

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Collabifier',
                style: TextStyle(color: Colors.white),
              ),
              centerTitle: true,
              backgroundColor: basecolorG,
            ),
            body: ChangeNotifierProvider(
                create: (_) => SignUpController(),
                child: Consumer<SignUpController>(
                    builder: (context, provider, child) {
                  return SingleChildScrollView(
                      child: SafeArea(
                    child: Column(
                      children: [
                        // TOP GREEN CONTAINER
                        Container(
                          decoration: BoxDecoration(
                              color: basecolorG,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.h(context)))),
                          width: double.infinity,
                          height: 21.h(context),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 3 * 4.sp(context),
                                ),
                                //    user IMAGE IN TOP
                                Image(
                                    height: 55.sp(context),
                                    width: 55.sp(context),
                                    image: const AssetImage(
                                        'assets/images/user for login.png')),
                                SizedBox(
                                  height: 68.sp(context),
                                ),
                              ]),
                        ),
                        // BOTTOM WHITE CONTAINER
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(children: [
                            SizedBox(
                              height: 20.sp(context),
                            ),

                            //FORM
                            Form(
                              key: _formKey, // Attach the form key
                              child: Column(
                                children: [
                                  //FULL NAME
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp(context)),
                                      child: TextFormField(
                                        controller: nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your name';
                                          }
                                          return null;
                                        },
                                      )),

                                  //CONTACT
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp(context)),
                                      child: TextFormField(
                                        controller: contactController,
                                        decoration: InputDecoration(
                                          labelText: 'Contact',
                                        ),
                                        keyboardType: TextInputType.phone,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your contact';
                                          }
                                          if (value.length <= 9) {
                                            return 'Please enter valid number';
                                          }
                                          return null;
                                        },
                                      )),

                                  //EMAIL TEXTFORMFIELD
                                  Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.sp(context)),
                                      child: TextFormField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          labelText: 'Email',
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      )),

                                  //PASSWORD TEXTFORMFIELD
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16.sp(context)),
                                    child: TextFormField(
                                      obscureText: _obscureText,
                                      controller: passwordController,
                                      cursorColor: Colors.black,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureText
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1.h(context),
                                  ),
                                  // SELECTION BUTTON
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ChoiceChip(
                                        label: const Text('Influencer'),
                                        selected: authProvider.selectedChoice ==
                                            'Influencer',
                                        onSelected: (isSelected) {
                                          authProvider
                                              .updateChoice('Influencer');
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      ChoiceChip(
                                        label: const Text('Investor'),
                                        selected: authProvider.selectedChoice ==
                                            'Investor',
                                        onSelected: (isSelected) {
                                          authProvider.updateChoice('Investor');
                                        },
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height: 3.h(context),
                                  ),

                                  if (authProvider.selectedChoice ==
                                      'Influencer')
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: platformChoices.map((choice) {
                                        return ChoiceChip(
                                          label: Text(choice['name']),
                                          selected: choice['selected'],
                                          onSelected: (selected) {
                                            setState(() {
                                              choice['selected'] = selected;
                                            });
                                          },
                                        );
                                      }).toList(),
                                    ),

                                  // Platform Choice Chips

                                  SizedBox(
                                    height: 3.h(context),
                                  ),
                                  // Platform Details (URL, Price)
                                  Column(
                                    children: platformChoices.map((choice) {
                                      if (choice['selected']) {
                                        return Column(
                                          children: [
                                            Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 5.sp(context),
                                                      left: 16.sp(context),
                                                      top: 16.sp(context)),
                                                  child: Text(
                                                    '${choice['name']} Details',
                                                    style: TextStyle(fontSize: 13.sp(context),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp(context)),
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    choice['url'] = value;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                    fillColor: basecolorlight,
                                                    focusColor: basecolorlight,
                                                    labelText:
                                                        '${choice['name']} URL',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(23))),
                                              ),
                                            ),
                                            SizedBox(height: 6.sp(context),),
                                             Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp(context)),
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    choice['channelName'] = value;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                    fillColor: basecolorlight,
                                                    focusColor: basecolorlight,
                                                    labelText:
                                                        'Name',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(23))),
                                              ),
                                            ),
                                            SizedBox(height: 6.sp(context),),

                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp(context)),
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                onChanged: (value) {
                                                  setState(() {
                                                    choice['followers'] = value;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                    fillColor: basecolorlight,
                                                    focusColor: basecolorlight,
                                                    labelText:
                                                        'Followers',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(23))),
                                              ),
                                            ),
                                             SizedBox(
                                              height: 1.h(context),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.sp(context)),
                                              child: TextFormField(
                                                keyboardType: TextInputType.number,
                                                onChanged: (value) {
                                                  setState(() {
                                                    choice['price'] = value;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                    fillColor: basecolorlight,
                                                    focusColor: basecolorlight,
                                                    labelText:
                                                        'Starting Price',
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(23))),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 2.h(context),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }).toList(),
                                  ),

                                  SizedBox(
                                    height: 3.h(context),
                                  ),

                                  //SignUp BUTTON
                                  authRoundBtn(
                                      text: 'SignUp',
                                      isLoading: provider.loading,
                                      onTap: () {
                                        // Validate the form before submission
                                        if (_formKey.currentState!.validate()) {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());

                                          //    ADD FORM KEY FOR VALIDATION................................................
                                          provider.signUp(
                                            context,
                                            nameController.text,
                                            emailController.text,
                                            passwordController.text,
                                            contactController.text.toString(),
                                            receiverId.text.toString(),
                                            message.text.toString(),
                                            authProvider
                                                .selectedChoice, // Pass the selected user type
                                            platformChoices, // Pass platform choices
                                          );
                                        }
                                      }),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 6.h(context), left: 2.w(context)),
                                    child: Row(
                                      children: [
                                        Text('Already have Account? '),
                                        GestureDetector(
                                          onTap: () {
                                            null;
                                          },
                                          child: GestureDetector(
                                            onTap: () {
                                              _navigateToLoginScreen(context);
                                            },
                                            child: Text(
                                              'Login here',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.underline),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8 * 3.sp(context),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        )
                      ],
                    ),
                  ));
                }))));
  }

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => loginScreen()),
        (route) => false);
  }
}