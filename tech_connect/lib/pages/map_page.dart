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

  Color background = Colors.white;

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
  bool buttonTextBool = false;
  

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
   
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      buttonTextBool = prefs.getBool('buttonTextBool') ?? false;
    });
    
  }


  final LatLng northEastBound = LatLng(32.534665145170706, -92.63876772509097);
  final LatLng southWestBound = LatLng(32.523864894532736, -92.6582692918401);
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  bool currentEventBool = true;
  String locationImageURL = 'https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Ftechconnect.PNG?alt=media&token=ad8c3eff-3c7b-4a60-8939-693de6fd9558';
  late GoogleMapController mapController;
  late List events = [];
  late List<bool> _selectedEvents = [];
  late String _address = 'Fetching User Location...';

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
  final snapshot = await firestore.collection('eventsGlobal').where('location', isEqualTo: _address).get();
  late List eventsQuery;
  //print(snapshot.docs.isNotEmpty);
  if(snapshot.docs.isNotEmpty){
    eventsQuery = snapshot.docs.map((doc) => doc.data()['eventName']).toList();
    
  }
  print(eventsQuery);
  //print(snapshot.size);
  return eventsQuery;
}

  void eventGrabber() async {
    List eventsQ = await queryValues();
    setState(() {
      events = eventsQ;
      _selectedEvents = List.filled((eventsQ.length), false);
      print('address: $_address');
    });
  }

  Future<void> checkIn(selectedEvents) async{
    //checks user in
    final prefs = await SharedPreferences.getInstance();
    setState((){
      prefs.setBool('buttonTextBool', buttonTextBool);
    });
    //print('checkin');
    //print(getImageUrl());
  }

  Future<void> checkOut(selectedEvents) async{
    // checks user out
    final prefs = await SharedPreferences.getInstance();
    setState((){
      prefs.setBool('buttonTextBool', buttonTextBool);
    });
    print(selectedEvents);
    //print('checkout');
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
  
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      print('address: ${place.street}');
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
    isDarkMode ? background = Colors.red : background = Colors.white;
    

    getUserCurrentLocation().then((value) async {

    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(value.latitude, value.longitude),
      zoom: 16,);
    
    final GoogleMapController controller = mapController;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //getAddressFromLatLng(value.latitude, value.longitude);
      List<Placemark> placemarks = await placemarkFromCoordinates(value.latitude, value.longitude);
      Placemark place = placemarks[0];
      // leave print statements for debugging
      String address = ("${place.street}");
      setState(() {
        _address = address_dict.addresses[address][0];
        locationImageURL = address_dict.addresses[address][1];
      });
      _address = address_dict.addresses[address][0];
      locationImageURL = address_dict.addresses[address][1];
      //print('image url: $locationImageURL');
      eventGrabber();
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
      appBar: AppBar( title: const Text('Campus Map'),
      toolbarHeight: 80,
      backgroundColor: isDarkMode
        ? Color.fromRGBO(203, 102, 102, 1)
        : Color.fromRGBO(198, 218, 231, 1),
      ),
      drawer: Drawer(
          backgroundColor: isDarkMode
      ? Color.fromRGBO(203, 102, 102, 1)
      : Color.fromRGBO(198, 218, 231, 1),
        child: Center(
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            
              Container(alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(30.0),
              child: Row(children: [Icon(Icons.location_history_rounded) ,Text('$_address', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0))])
              ),
              const SizedBox(height: 30.0),
              (_address == 'Fetching User Location...') ? CircularProgressIndicator() 
              : Container(
                padding: EdgeInsets.all(10.0),
                child: Container(padding: EdgeInsets.all(3) ,color: Colors.black ,child:Image.network(fit: BoxFit.cover ,locationImageURL))),
              const SizedBox(height: 30.0),
              (_address == 'Fetching User Location...') ? Text('') : (events.isNotEmpty) ? Column(
              children: [ToggleButtons(direction: Axis.vertical, 
              onPressed: (int index) {
                setState(() {
                  for (int i = 0; i < _selectedEvents.length; i++){
                    _selectedEvents[i] = i == index;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              borderColor: Colors.black38,
              selectedBorderColor: Colors.red[700],
              selectedColor: Colors.blue,
              color: Colors.red[400],
              constraints: const BoxConstraints(maxHeight: 50.0, minHeight: 40.0), 
              isSelected: _selectedEvents,
              children: events.map((str) => Row( mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Padding(padding: const EdgeInsets.all(10.0), 
              child:Text(str, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),))],)).toList(),
              ),
              SizedBox(height: 30.0,),
              (events.isNotEmpty) ? ElevatedButton(
                style: ButtonStyle(backgroundColor: buttonTextBool ? const MaterialStatePropertyAll<Color>(Colors.red) : const MaterialStatePropertyAll<Color>(Colors.green)),
                child: buttonTextBool ? const Text("Check-Out", style: TextStyle(color: Colors.black),) : const Text("Check-In", style: TextStyle(color: Colors.black),),
                onPressed: () {
                  setState(() {
                    buttonTextBool = !buttonTextBool;
                    buttonTextBool ? checkIn(_selectedEvents) : checkOut(_selectedEvents);
                  });
                }
              ) : const SizedBox()
            ]):
              const SizedBox(height: 30.0),
              (events.isEmpty) ? Text('Currently no events at your location') : Text('')
            ]
            )
            ),
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