// @dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/screen/homeScreen.dart';
import 'package:flutter_project/services/user_services.dart';

class AuthProvider with ChangeNotifier{

  FirebaseAuth _auth = FirebaseAuth.instance;
  String smsOtp;
  String verificationId;
  String error = '';
  UserServices _userServices = UserServices();

  Future<void>verifyphone(BuildContext context, String number)async {

      final PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential credential) async{
        await _auth.signInWithCredential(credential);
      };

      final PhoneVerificationFailed verificationFailed = (FirebaseAuthException e){
        print(e.code);
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
                        PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsOtp);

                        final User user = (await _auth.signInWithCredential(
                            credential)).user;


                        //create user data in fireStore after user successfully registered,


                          _createUser(id: user.uid, number: user.phoneNumber);

                        //navigate to Home page after login.

                        if (user != null) {
                          Navigator.of(context).pop();

                          //don't want come back to welcome screen after logged in
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => HomeScreen(),
                              ));
                        } else {
                          print('Login Failed');
                        }
                      } catch (e) {
                        this.error = 'Invalid OTP';
                        print(e.toString());
                        Navigator.of(context).pop();
                      }
                    },

                    child: Text('DONE'))
              ],
            );
          }
      );
  }

    void _createUser({String id,  String number}) {
      _userServices.createUserData({
        'id': id,
        'number': number,
      });
    }

}