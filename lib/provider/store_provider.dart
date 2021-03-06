// @dart=2.9



import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_project/screen/welcome_screen.dart';
import 'package:flutter_project/services/store_services.dart';
import 'package:flutter_project/services/user_services.dart';


class StoreProvider with ChangeNotifier{
  StoreServices _storeServices = StoreServices();
  UserServices _userServices = UserServices();
  User user = FirebaseAuth.instance.currentUser;
  var userLatitude = 0.0;
  var userLongitude = 0.0;



  Future<void>getUserLocationData(context)async{

    _userServices.getUserById(user.uid).then((result) {
      if(user != null){
        this.userLatitude = result['latitude'];
        this.userLongitude = result['longitude'];
        notifyListeners();
      }else{
        Navigator.pushReplacementNamed(context,WelcomeScreen.id);
      }
    });

  }


}