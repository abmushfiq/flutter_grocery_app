// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/provider/location_provider.dart';
import 'package:flutter_project/screen/homeScreen.dart';
import 'package:flutter_project/screen/landing_screen.dart';
import 'package:flutter_project/screen/map_screen.dart';
import 'package:flutter_project/services/user_services.dart';


class AuthProvider with ChangeNotifier{

  FirebaseAuth _auth = FirebaseAuth.instance;
  String smsOtp;
  String verificationId;
  String error = '';
  UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();
  String screen;
  double latitude;
  double longitude;
  String address;
  String location;

  Future<void>verifyphone({BuildContext context, String number})async {

    this.loading = true;
    notifyListeners();

      final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async{
        this.loading = false;
        notifyListeners();
        await _auth.signInWithCredential(credential);
      };

      final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e){
        this.loading = false;
        print(e.code);
        this.error = e.toString();
        notifyListeners();
      };

      final PhoneCodeSent smsOtpSend = (String verId , int resendToken) async {
              this.verificationId = verId;



              //open dialog to enter received otp sms

        smsOtpDialog(context,number);
      };
    try{
      _auth.verifyPhoneNumber(
          phoneNumber: number,
          verificationCompleted: verificationCompleted,
          verificationFailed:verificationFailed,
          codeSent: smsOtpSend,
          codeAutoRetrievalTimeout: (String verId){
              this.verificationId = verId;
          },
      );
    }catch(e){
      this.error = e.toString();
      this.loading=false;
      notifyListeners();
      print(e);
    }
  }

  Future<bool>smsOtpDialog(BuildContext context, String number) {

      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Column(
                children: [
                  Text('verification Code'),
                  SizedBox(height: 6,),
                  Text('Enter 6 digit otp recieved as SMS',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              content: Container(
                height: 85,
                child: TextField(
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (value) {
                    this.smsOtp = value;
                  },
                ),
              ),
              actions: [
                FlatButton(
                    onPressed: () async {
                      try {
                        PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsOtp);

                        final User user = (await _auth.signInWithCredential(
                            phoneAuthCredential)).user;

                        if(user!=null){
                          this.loading = false;
                          notifyListeners();


                          _userServices.getUserById(user.uid).then((snapShot){
                            if(snapShot.exists){
                              //user data already exist.
                              if(this.screen == 'Login'){
                                //need to check user data already exist in db or not.
                                // if its "login" no new data, so no need to update
                                if(snapShot['address']!=null){
                                  Navigator.pushReplacementNamed(context, HomeScreen.id);
                                }
                                Navigator.pushReplacementNamed(context, LandingScreen.id );
                              }else{
                                //need to update new selected address
                                updateUser(id: user.uid, number: user.phoneNumber);
                                Navigator.pushReplacementNamed(context, HomeScreen.id );
                              }
                            }else{
                              //user Data does not exists
                              //will create new data in db
                              _createUser(id: user.uid, number: user.phoneNumber);
                              Navigator.pushReplacementNamed(context, LandingScreen.id);
                            }
                          });

                        }else{
                          print('Login failed');
                        }


                      } catch (e) {
                        this.error = 'Invalid OTP';
                        notifyListeners();
                        print(e.toString());
                        Navigator.of(context).pop();
                      }
                    },

                    child: Text('DONE',style: TextStyle(color: Theme.of(context).primaryColor))
                )
              ],
            );
          }
      ).whenComplete(() {
        this.loading=false;
        notifyListeners();
      });
  }

    void _createUser({String id,  String number}) {
      _userServices.createUserData({
        'id': id,
        'number': number,
        'latitude':this.latitude,
        'longitude':this.longitude,
        'address':this.address,
      });
      this.loading=false;
      notifyListeners();
    }

  Future<bool> updateUser({String id,  String number}) async {
   try{
     _userServices.updateUserData({
       'id': id,
       'number': number,
       'latitude':this.latitude,
       'longitude':this.longitude,
       'address':this.address,
       'location' : this.location,
     });
     this.loading=false;
     notifyListeners();
     return true;
   }catch(e){
      print('Error $e');
      return false;
   }
  }

}