// @dart=2.9



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/provider/store_provider.dart';
import 'package:flutter_project/screen/welcome_screen.dart';
import 'package:flutter_project/services/store_services.dart';
import 'package:flutter_project/services/user_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class TopPickStore extends StatefulWidget {

  @override
  _TopPickStoreState createState() => _TopPickStoreState();
}

class _TopPickStoreState extends State<TopPickStore> {
  StoreServices _storeServices = StoreServices();



  @override
  Widget build(BuildContext context) {
    final _storeData = Provider.of<StoreProvider>(context);
    _storeData.getUserLocationData(context);


    String getDistance(location){
      var distance = Geolocator.distanceBetween(_storeData.userLatitude,_storeData.userLongitude, location.latitude, location.longitude);
      var distanceInKm = distance/1000;
      return distanceInKm.toStringAsFixed(2);

    }

    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: _storeServices.getTopPickedStore(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapShot){
          if(!snapShot.hasData)return CircularProgressIndicator();
          // now we nned to show store only with in 20km distance
          //need to confirm even no shop near by not
          List shopDistance = [];
          for (int i = 0; i <= snapShot.data.docs.length-1; i++){
            var distance = Geolocator.distanceBetween(
                _storeData.userLatitude, _storeData.userLongitude,
                snapShot.data.docs[i]['location'].latitude,snapShot.data.docs[i]['location'].longitude);
                var distanceInKm = distance/1000;
                shopDistance.add(distanceInKm);
          }
          shopDistance.sort(); // this will sort with nearest distance. if nearest distance is more than 10, that means no shop near by;
          if(shopDistance[0]>10){
            return Container();
          }
          return Padding(
            padding: const EdgeInsets.only(left: 8,right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10,top: 20),
                  child: Row(
                    children: [
                      SizedBox(
                          height: 30,
                          child: Image.asset('images/like.gif')),
                      Text('Top Picked Stores For You',style: TextStyle(fontWeight: FontWeight.w900,fontSize: 18,color: Colors.black87),),
                    ],
                  ),
                ),
                Container(
                  child: Flexible(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: snapShot.data.docs.map((DocumentSnapshot document){

                        if(double.parse(getDistance(document['location']))<=10){
                          //show the store only with in 10km
                          //u can increase or decrease the distance
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Container(
                              width: 80,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [

                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: Image.network(document['imageUrl'],fit: BoxFit.cover, width: 70,
                                      height: 70,),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 35,
                                    child: Text(document['shopName'],style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.bold,

                                    ),maxLines: 2,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                                  ),
                                  Text('${getDistance(document['location'])}Km', style: TextStyle(color: Colors.grey,fontSize: 10),)
                                ],
                              ),
                            ),
                          );
                        }else {
                          return Container();
                        }

                      }).toList(),
                    ),
                  ),
                )

              ],
            ),
          );
        },
      ),
    );
  }
}
