import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Utils{
  static void fieldFocus(BuildContext context, FocusNode currentNode, FocusNode nextFocus){
    currentNode.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  static toasstMessage(String message){
    Fluttertoast.showToast(
      timeInSecForIosWeb: 5,
      msg:message,
      fontSize:16
    );
  }

}
