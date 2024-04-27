// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:tech_connect/components/map_dict.dart' as address_dict;
import 'package:tech_connect/pages/org_profile.dart';

class MapPage extends StatefulWidget{

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // created controller to display google maps 
  Completer<GoogleMapController> _controller = Completer();

  Set<Polygon> _polygon = HashSet<Polygon>();

  List<LatLng> tolliverCommuter = [
    LatLng(32.526683, -92.649363),
    LatLng(32.526752, -92.649664),
    LatLng(32.526200, -92.649879),
    LatLng(32.526149, -92.649460),
  ];

  List<LatLng> tolliverResident = [
    LatLng(32.525730, -92.649045),
    LatLng(32.525470, -92.648331),
    LatLng(32.525726, -92.647824),
    LatLng(32.525984, -92.648776),
  ];

  List<LatLng> bookstoreProfessor = [
    LatLng(32.528047, -92.649054),
    LatLng(32.527743, -92.649199),
    LatLng(32.527543, -92.648323),
    LatLng(32.527853, -92.648187),  
  ];

  bool isDarkMode = false;

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }
  
  final LatLng northEastBound = LatLng(32.534665145170706, -92.63876772509097);
  final LatLng southWestBound = LatLng(32.523864894532736, -92.6582692918401);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool buttonTextBool = false;
  bool currentEventBool = true;
  String locationImageURL = 'https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Ftechconnect.PNG?alt=media&token=ad8c3eff-3c7b-4a60-8939-693de6fd9558';
  late GoogleMapController mapController;
  late List events = [];
  String? _address;

  final LatLng _center = LatLng(32.52741208116641, -92.64696455825013);
  

  late String eventData;

 
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();

    });
    return await Geolocator.getCurrentPosition();
  }

  Future<List> queryValues() async {
  final snapshot = await firestore.collection('eventsGlobal').where('location', isEqualTo: '$_address').get();
  late List eventsQuery;
  if(snapshot.docs.isNotEmpty){
    eventsQuery = snapshot.docs.map((doc) => doc.data()).toList();
  }
  //print(eventsQuery);
  return eventsQuery;
}

  void eventGrabber() async {
    List eventsQ = await queryValues();
    setState(() {
      events = eventsQ;
    });
  }

  Future<void> checkIn() async{
    // checks user in
    //print('checkin');
    //print(getImageUrl());
  }

  Future<void> checkOut() async{
    // checks user out
    //print('checkout');
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
  
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      setState(() {
      // leave print statements for debugging
      
      String address = ("${place.street}");
      print("Address place.street: $address");
      _address = address_dict.addresses[address][0];
      print("Address _: $_address");
      locationImageURL = address_dict.addresses[address][1];
      //print('image url: $locationImageURL');
      eventGrabber();
      });
  }
  

  Future<void> getImageUrl() async {
    DocumentReference documentReference = FirebaseFirestore.instance
    .collection('map_images')
    .doc('$_address');

    await documentReference.get().then((snapshot) {
      locationImageURL = snapshot['picture'].toString();
    });
  }

  @override
  void initState() {
    super.initState();

    getDarkModeValue();

    getUserCurrentLocation().then((value) async {

    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(value.latitude, value.longitude),
      zoom: 16,);
    
    final GoogleMapController controller = mapController;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //getAddressFromLatLng(value.latitude, value.longitude);
      List<Placemark> placemarks = await placemarkFromCoordinates(value.latitude, value.longitude);
      Placemark place = placemarks[0];

      setState(() {
      // leave print statements for debugging
      
      String address = ("${place.street}");
      print("Address place.street: $address");
      _address = address_dict.addresses[address][0];
      print(_address);
      locationImageURL = address_dict.addresses[address][1];
      //print('image url: $locationImageURL');
      eventGrabber();
      });

    print('address init: $_address');
    });
    
    //initalize polygon
    _polygon.add(
      Polygon(
        polygonId: PolygonId('1'),
        points: tolliverCommuter,
        fillColor: Colors.yellow.withOpacity(0.3),
        strokeColor: Colors.yellow,
        geodesic: true,
        strokeWidth: 4,
      )
    );

    _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: tolliverResident,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 4,
        )
      );

    _polygon.add(
        Polygon(
          polygonId: PolygonId('3'),
          points: bookstoreProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );
    }
    

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromRGBO(77, 95, 128, 100),
      appBar: AppBar( title: const Text('Campus Map'),
      toolbarHeight: 80,
      ),
      drawer: Drawer(
        child: Center(
          child: (_address == null) ? CircularProgressIndicator() : Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(30.0),
              child: Text('$_address', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))
              ),
              const SizedBox(height: 30.0),
              Image.network(locationImageURL),
              const SizedBox(height: 30.0),
              (events.isNotEmpty) ? Column(

              children: [Text(events[0]['organization'] + 'is hosting: '),
              Text(events[0]['event']),
              const SizedBox(height: 30.0),
              currentEventBool ?
              ElevatedButton(
                style: ButtonStyle(backgroundColor: buttonTextBool ? const MaterialStatePropertyAll<Color>(Colors.red) : const MaterialStatePropertyAll<Color>(Colors.green)),
                child: buttonTextBool ? const Text("Check-Out") : const Text("Check-In"),
                onPressed: () {
                  setState(() {
                    buttonTextBool ? checkOut() : checkIn();
                    buttonTextBool = !buttonTextBool;
                  });
                }
              ) : const SizedBox()
            ]) : Text('Currently no events at $_address')
          ],
            ),
        )
        ),
      body: GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
      },

      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 16.0,
      ),
      mapType: MapType.satellite,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      cameraTargetBounds: CameraTargetBounds(LatLngBounds(northeast: northEastBound, southwest: southWestBound)),
      polygons: _polygon,
    ),
    );
  }
}