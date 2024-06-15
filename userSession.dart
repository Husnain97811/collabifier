class sessionController {
  static final sessionController _session = sessionController._internal();

  String? userId;
  String? email;
  String? name;
  String? photoURL;
  String? accessToken;
  String? idToken;
  String? phoneNumber;

  factory sessionController(){
    return _session;
  }

  sessionController._internal(){

  }


   void setName(String newName) {
    name = newName;
  }

  // Add a method to update the phone number
  void setPhoneNumber(String newPhoneNumber) {
    phoneNumber = newPhoneNumber;
  }
}