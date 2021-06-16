// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_project/provider/auth_provider.dart';
import 'package:flutter_project/provider/location_provider.dart';
import 'package:flutter_project/screen/homeScreen.dart';
import 'package:provider/provider.dart';


class LoginScreen extends StatefulWidget {

  static const String id = 'login-screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _validphoneNumber = false;
  var _phoneNumberController = TextEditingController();

  @override
  Widget build (BuildContext contex) {

    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: auth.error  == 'Invalid OTP'? true:false,
                  child: Container(
                    child: Column(
                      children: [
                        Text('${auth.error} - Try again', style: TextStyle(color: Colors.red,fontSize: 12),),
                        SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
                Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Text('Enter your phone number to proceed', style: TextStyle(fontSize: 12,color: Colors.grey),),
                SizedBox(height: 20,),
                TextField(

                  decoration: InputDecoration(
                    prefixText: '+94',
                    labelText: ('9 digit mobile number'),
                  ),
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  controller: _phoneNumberController,
                  onChanged: (value){
                    if(value.length==9){
                      setState((){
                        _validphoneNumber = true;
                      });
                    }else{
                      setState((){
                        _validphoneNumber = false;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: _validphoneNumber ? false:true,
                        child: FlatButton(
                            onPressed: (){

                              setState((){
                                auth.loading = true;
                                auth.screen =  'MapScreen';
                                auth.latitude = locationData.latitude;
                                auth.longitude = locationData.longitude;
                                auth.address = locationData.selectedAddress.addressLine;

                              });
                              String number = '+94${_phoneNumberController.text}';
                              auth.verifyphone(
                                  context: context,
                                  number: number,

                              ).then((value) {
                                _phoneNumberController.clear();
                                setState(() {
                                  auth.loading=false;
                                });

                              });
                            },
                            color: _validphoneNumber ? Theme.of(context).primaryColor : Colors.grey,
                            child: auth.loading ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ): Text(_validphoneNumber ? 'CONTINUE' : 'ENTER PHONE NUMBER', style: TextStyle(color: Colors.white),)
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}