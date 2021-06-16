// @dart=2.9


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/provider/auth_provider.dart';
import 'package:flutter_project/provider/location_provider.dart';
import 'package:flutter_project/provider/store_provider.dart';
import 'package:flutter_project/screen/homeScreen.dart';
import 'package:flutter_project/screen/landing_screen.dart';
import 'package:flutter_project/screen/login_screen.dart';
import 'package:flutter_project/screen/map_screen.dart';
import 'package:flutter_project/screen/welcome_screen.dart';
import 'package:provider/provider.dart';

import 'screen/splash_screen.dart';




void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

  runApp(MultiProvider(
        providers: [
      ChangeNotifierProvider(
        create: (_)=> AuthProvider(),
      ),

          ChangeNotifierProvider(
            create: (_)=> LocationProvider(),
          ),
          ChangeNotifierProvider(
            create: (_)=> StoreProvider(),
          ),
    ],
    child:MyApp(),
    ),);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1DA1F9),
        fontFamily: 'Lato'
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id:(context) => SplashScreen(),
        HomeScreen.id :(context) => HomeScreen(),
        WelcomeScreen.id:(context) => WelcomeScreen(),
        MapScreen.id:(context)=>MapScreen(),
        LoginScreen.id:(context)=>LoginScreen(),
        LandingScreen.id:(context)=>LandingScreen(),


      },
    );
  }
}



