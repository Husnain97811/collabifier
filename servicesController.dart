import 'package:collabifier/session_manager/userSession.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ServiceData extends ChangeNotifier {
  List<Service> popularServices = [];
  List<Service> services = [];

  void fetchServices() {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref().child('Users').child(sessionController().userId.toString());

    ref.once().then((snapshot) {
      if (snapshot != null && snapshot.snapshot != null && snapshot.snapshot.value != null) {
      var data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      var servicesMap = data['services'] as Map<dynamic, dynamic> ?? {};

          popularServices.clear();
          services.clear();

          // Populate popular services (up to 6)
          int count = 0;
          servicesMap.forEach((key, value) {
            if (count < 6) {
              String title = value['title'] ?? '';
              String serviceImg = value['serviceImg'] ?? '';
              popularServices.add(Service(image: serviceImg, title: title));
              count++;
            }
          });

          // Populate all services
          servicesMap.forEach((key, value) {
            String title = value['title'] ?? '';
            String serviceImg = value['serviceImg'] ?? '';
            services.add(Service(image: serviceImg, title: title));
          });

          notifyListeners();
        }
      }
    );
    }
  }





class Service {
  final String image;
  final String title;

  Service({required this.image, required this.title});
}
