// @dart=2.9


import 'package:flutter/material.dart';
import 'package:flutter_project/provider/location_provider.dart';
import 'package:flutter_project/screen/map_screen.dart';



class LandingScreen extends StatefulWidget {
  static const String id ='landing-screen';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LocationProvider _locationProvider = LocationProvider();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text( 'Delivery Address not set' , style: TextStyle(fontWeight: FontWeight.bold ),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text( 'please update your Delivery Location to find nearest Stores for you ',
              textAlign: TextAlign.center,style: TextStyle(color: Colors.grey) ,
              ),
            ),
            CircularProgressIndicator(),
            Container(
                width:600,
                child: Image.asset('images/city.png',fit: BoxFit.fill,color: Colors.black12,),),

            _loading ? CircularProgressIndicator() : FlatButton(
                color: Theme.of(context).primaryColor,
                onPressed: ()async{
                  setState(() {
                    _loading = true;
                  });

                  await _locationProvider.getCurrentPosition();
                  if(_locationProvider.selectedAddress!=null){
                    Navigator.pushReplacementNamed(context, MapScreen.id);
                  }else{
                    Future.delayed(Duration (seconds: 4),(){
                      if (_locationProvider.permissionAllowed==false){
                        print('Permission not allowed');
                        setState(() {
                          _loading=false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please allow permission to find nearest stores for you'),
                        ));
                      }

                    });
                  }

                },
                child: Text('Confirm Your Location',style: TextStyle(color: Colors.white),)
            ),
          ],
        ),
      ),
    );
  }
}
