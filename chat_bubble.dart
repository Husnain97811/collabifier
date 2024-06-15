import 'package:flutter/material.dart';

class chatBubble extends StatelessWidget{
  String message;
  chatBubble({ required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      
      
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Colors.blue[400]),child: Text(message, style: TextStyle(fontSize: 16),),
    );
  }

}