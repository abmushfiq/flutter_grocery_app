// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_project/provider/auth_provider.dart';
import 'package:flutter_project/provider/location_provider.dart';
import 'package:flutter_project/screen/map_screen.dart';
import 'package:flutter_project/screen/onboard_screen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
      static const String id = 'welcome-screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {

    final auth = Provider.of<AuthProvider>(context);

    bool _validphoneNumber = false;
    var _phoneNumberController = TextEditingController();

    void showBottomSheet (context) {
      showModalBottomSheet(
        context: context,
        builder: (context)=> StatefulBuilder(builder: (context, StateSetter myState){
          return Container(
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
                      labelText: '9 digit mobile number',
                    ),
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    controller: _phoneNumberController,
                    onChanged: (value){
                      if(value.length==9){
                        myState((){
                          _validphoneNumber = true;
                        });
                      }else{
                        myState((){
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
                                myState(){
                                  auth.loading = true;
                                }
                                String number = '+94${_phoneNumberController.text}';
                                auth.verifyphone(
                                    context: context,
                                    number: number,
                                ).then((value) {
                                  _phoneNumberController.clear();
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
          );
        }
        ),
      ).whenComplete((){
          setState(() {
            auth.loading= false;
            _phoneNumberController.clear();
          });
      });

    }

    final locationData = Provider.of<LocationProvider>(context,listen: false);


    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              right: 0.0,
              top:10.0,
              child: FlatButton(
                child: Text('SKIP', style: TextStyle(color: Theme.of(context).primaryColor),),
                onPressed: (){},
              ),
            ),
            Column(
              children: [
                Expanded(child: OnBaordScreen()) ,
                Text('Ready to order from your nearest shop?', style: TextStyle(color: Colors.grey),),
                SizedBox(height: 20,),
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  child: locationData.loading ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ): Text('SET DELIVERY LOCATION', style: TextStyle(color: Colors.white),),
                  onPressed: () async {

                        setState(() {
                          locationData.loading= true;


                        });
                       await locationData.getCurrentPosition();
                       if(locationData.permissionAllowed==true){
                         Navigator.pushReplacementNamed(context, MapScreen.id);
                         setState(() {
                           locationData.loading = false;
                         });
                       }else{
                         print('permission not allowed');
                         setState(() {
                           locationData.loading = false;
                         });
                       }
                  },
                ),
                FlatButton(

                    child:  RichText(text: TextSpan(
                        text: ' Already a Customer ? ', style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                              text: 'Login', style: TextStyle(fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor)
                          )
                        ]
                    ),

                    ),
                  onPressed: (){
                      setState(() {
                        auth.screen='Login';
                      });
                      showBottomSheet(context);
                  },
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}
