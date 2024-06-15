// ignore_for_file: unused_field

import 'package:collabifier/auth_Screens/forgot_Pass.dart';
import 'package:collabifier/auth_Screens/signUp_Screen.dart';
import 'package:collabifier/controllers/loginController.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/reUseAbleWidgets/conts%20+%20comps.dart';
import 'package:collabifier/session_manager/userSession.dart';
import 'package:collabifier/state_management/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:provider/provider.dart';

class loginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return loginScreenState();
  }
}

class loginScreenState extends State<loginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;

  bool isLoading = false;

  //     CHECK TEXTFORMFIELDS IS NOT EMPTY

  bool isAnyFieldEmpty() {
    return emailController.text.isEmpty || passwordController.text.isEmpty;
  }

  String _selectedChoice = 'Influencer'; // Default choice

  void _updateChoice(String choice) {
    setState(() {
      _selectedChoice = choice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
          backgroundColor: basecolorG,
          body: ChangeNotifierProvider(
            create: (_) => loginController(),
            child: Consumer<loginController>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // TOP GREEN CONTAINER
                      Container(
                        decoration: BoxDecoration(
                            // color: basecolorG,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12.h(context)))),
                        width: double.infinity,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // SizedBox(
                              //   height: 23 * 4.sp(context),
                              // ),
                              SizedBox(
                                height: 68.sp(context),
                              ),
                              Text(
                                'Collabifier',
                                style: GoogleFonts.lobster(
                                    fontSize: 60.sp(context),
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 28.sp(context),
                              ),
                              Text(
                                'Welcome!',
                                style: GoogleFonts.lobster(
                                    fontSize: 60.sp(context),
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 8.sp(context),
                              ),
                              Text(
                                'Sign into Your Account',
                                style: GoogleFonts.lobster(
                                    fontSize: 32.sp(context),
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 32.sp(context),
                              ),
                            ]),
                      ),
                      // BOTTOM WHITE CONTAINER
                      Container(
                        decoration: const BoxDecoration(
                            // color: Colors.white,
                            ),
                        child: Column(children: [
                          SizedBox(
                            height: 40.sp(context),
                          ),
                          //EMAIL TEXTFORMFIELD
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.sp(context)),
                              child: textForm(
                                textformcontroller: emailController,
                                labeltext: 'Email',
                                keyboardType: TextInputType.emailAddress,
                              )),
                          //PASSWORD TEXTFORMFIELD

                          Padding(
                            padding: EdgeInsets.all(16.sp(context)),
                            child: TextField(
                                obscureText: _obscureText,
                                controller: passwordController,
                                cursorColor: Colors.black,
                                keyboardType: TextInputType.visiblePassword,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12)),
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
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _navigateToForgotScreen(context);
                                  },
                                  child: Text('Forgot Password?',
                                      style: GoogleFonts.faustina(
                                          color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 4.h(context),
                          ),
                          // SELECTION BUTTON

                          SizedBox(
                            height: 3.h(context),
                          ),

                          //LOGIN BUTTON

                          authRoundBtn(
                              text: 'Sign In',
                              isLoading: provider.loading,
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                provider.login(context, emailController.text,
                                    passwordController.text);
                              }),
                          Padding(
                            padding:  EdgeInsets.all(18.sp(context)),
                            child: Text('OR'),
                          ),
                          Container(child: Icon(Icons.facebook),decoration: BoxDecoration(color: Coloere),)

                          Padding(
                            padding: EdgeInsets.all(4.h(context)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Don^t have Account? ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _navigateToSignupScreen(context);
                                      },
                                      child: const Text(
                                        'SignUp here',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20 * 2.sp(context),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //    GOOGLE PLAY LINK
                              // GestureDetector(
                              //   onTap: () {
                              //     loginController().signInWithGoogle(context, sessionController().name.toString());
                              //   },
                              //   child: socailbutton(
                              //       socialimage: const Image(
                              //           image: AssetImage(
                              //               'assets/images/google G.png'))),
                              // ),
                              // SizedBox(
                              //   width: 13.sp(context),
                              // ),

                              //   MAIL BUTTON LINK
                            ],
                          ),
                        ]),
                      )
                    ],
                  ),
                );
              },
            ),
          )),
    );
  }

  void _navigateToSignupScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => signupScreen()),
        (route) => false);
  }

  void _navigateToForgotScreen(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => forgotScreen()));
  }
}
