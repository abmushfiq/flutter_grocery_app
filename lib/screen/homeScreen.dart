// @dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/widgets/near_by_store.dart';
import 'package:flutter_project/widgets/top_pick_store.dart';
import 'package:flutter_project/widgets/image_slider.dart';
import 'package:flutter_project/widgets/my_appbar.dart';


class HomeScreen extends StatefulWidget {

  static const String id = 'Home-Screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {



  @override
  Widget build(BuildContext context){


    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(112),
        child: myAppBar(),
      ),
      body: ListView(


          children: [
            ImageSlider(),
            Container(
                // color: Colors.red,
                height: 200,
                child: TopPickStore()),
            NearByStore(),




          ],

      ),
    );
  }
}