// ignore_for_file: camel_case_types, must_be_immutable

import 'package:collabifier/reUseAbleWidgets/contants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';

// AUTHENTICATION ROUND BUTTON

class authRoundBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  bool isLoading;
  authRoundBtn(
      {required this.text, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          alignment: Alignment.center,
          height: 4.5.h(context),
          width: 42.w(context),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(23), topLeft: Radius.circular(23)),
          ),
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Text(
                  text,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp(context)),
                )),
    );
  }
}

//  SOCAIL IMAGE BUTTONS
class socailbutton extends StatelessWidget {
  final Image socialimage;
  socailbutton({required this.socialimage});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: basecolorlight,
          borderRadius: BorderRadius.circular(23.sp(context))),
      width: 45 * 2.sp(context),
      height: 5.h(context),
      child: Padding(
          padding: EdgeInsets.only(
            top: 0.8.h(context),
            bottom: 0.8.h(context),
          ),
          child: Image(
              height: 7.h(context),
              width: 7.w(context),
              image: socialimage.image)),
    );
  }
}

// TEXTFORMFIELD FOR AUTHENTICATION SCREENS
class textForm extends StatelessWidget {
  final TextEditingController textformcontroller;
  final String labeltext;
  final TextInputType keyboardType;

  textForm({
    required this.textformcontroller,
    required this.labeltext,
    required this.keyboardType,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textformcontroller,
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelText: labeltext,
      ),
    );
  }
}

//  DROP DOWN MENU

class SelectedOptionNotifier extends ChangeNotifier {
  String _selectedOption = 'Video';

  String get selectedOption => _selectedOption;

  void updateSelectedOption(String newOption) {
    _selectedOption = newOption;
    notifyListeners();
  }
}
