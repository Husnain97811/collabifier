import 'package:collabifier/controllers/forgotController.dart';
import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:collabifier/reUseAbleWidgets/conts%20+%20comps.dart';
import 'package:flutter/material.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';
import 'package:provider/provider.dart';

class forgotScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return forgotScreenState();
  }
}

class forgotScreenState extends State<forgotScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {

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
          body: ChangeNotifierProvider(create: (_) => forgotController(),
          child: Consumer<forgotController>(builder: (context, provider, child) {
            return     
        SingleChildScrollView(
          child: Column(
            children: [
              // TOP GREEN CONTAINER
              Container(
                decoration: BoxDecoration(
                    color: basecolorG,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.h(context)))),
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 23 * 4.sp(context),
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
                    height: 40.sp(context),
                  ),
                  //EMAIL TEXTFORMFIELD
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.sp(context)),
                      child: textForm(
                        textformcontroller: emailController,
                        labeltext: 'Enter Email',
                        keyboardType: TextInputType.emailAddress,
                      )),

                  SizedBox(
                    height: 1.h(context),
                  ),
                  // SELECTION BUTTON
                 
                 

                  //LOGIN BUTTON

                  authRoundBtn(
                    text: 'Search User',
                    isLoading: provider.loading,
                    onTap: () {
                     provider.forgotPass(context, emailController.text);
                    }, 
                  ),
                ]),
              )
            ],
          ),
        );
    
          }, ),
          )),
    );
  }
}
