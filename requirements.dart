import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mediaquery_sizer/mediaquery_sizer.dart';

class requirements extends StatefulWidget{
  @override
  State<requirements> createState() => _requirementsState();
}

class _requirementsState extends State<requirements> {
  final users = FirebaseFirestore.instance.collection('users');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(body:StreamBuilder(stream: users.snapshots(), builder: (context,AsyncSnapshot<QuerySnapshot> snapshot) {
      var data = snapshot.data?.docs;
      return 
     ListView.builder(
      itemCount: data!.length,
  itemBuilder: (context, index) {
    var data = snapshot.data!.docs; 
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            children: [
              ListTile(
                title: Text('',
                  // 'Name ${data['name']} ',
                  style: TextStyle(
                    fontSize: 15.sp(context),
                  ),
                ),
                trailing: Text(
                      data[index]['name'],
                  style: TextStyle(
                    fontSize: 15.sp(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  },
);

    },  ) ,);
  }

 
}