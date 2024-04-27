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

  List<LatLng> tacLot = [
    LatLng(32.532600, -92.660372),
    LatLng(32.532892, -92.660100),
    LatLng(32.533090, -92.659678),
    LatLng(32.532750, -92.659454),
    LatLng(32.532444, -92.659806),
    LatLng(32.532525, -92.660041),
    LatLng(32.532447, -92.660148)
  ];

  List<LatLng> tacLot2 = [
    LatLng(32.533249, -92.659727),
    LatLng(32.533312, -92.659304),
    LatLng(32.533274, -92.659291),
    LatLng(32.533188, -92.659713)
  ];

  List<LatLng> stadiumCircle = [
    LatLng(32.533520, -92.657772),
    LatLng(32.533775, -92.657131),
    LatLng(32.534001, -92.656611),
    LatLng(32.534081, -92.656131),
    LatLng(32.534020, -92.655418),
    LatLng(32.533313, -92.655644),
    LatLng(32.533329, -92.656056),
    LatLng(32.533213, -92.656419),
    LatLng(32.533119, -92.656391),
    LatLng(32.532980, -92.656745),
    LatLng(32.532713, -92.657018),
    LatLng(32.532294, -92.657154),
    LatLng(32.532005, -92.657186),
    LatLng(32.531801, -92.657092),
    LatLng(32.531362, -92.656757),
    LatLng(32.531209, -92.656411),
    LatLng(32.530915, -92.656143),
    LatLng(32.530860, -92.656303),
    LatLng(32.530933, -92.657234),
    LatLng(32.531491, -92.657237),
    LatLng(32.532121, -92.657362),
    LatLng(32.532693, -92.657474),
    LatLng(32.533054, -92.657515),
  ];

  List<LatLng> stadiumLot = [
    LatLng(32.533070, -92.655048),
    LatLng(32.533065, -92.654622),
    LatLng(32.532947, -92.654614),
    LatLng(32.532946, -92.654763),
    LatLng(32.532891, -92.654762),
    LatLng(32.532890, -92.655045),
  ];

  List<LatLng> stadiumLot2 = [
    LatLng(32.530896, -92.655430),
    LatLng(32.531147, -92.654894),
    LatLng(32.530837, -92.654678),
    LatLng(32.530704, -92.654958),
    LatLng(32.530748, -92.654987),
    LatLng(32.530728, -92.655056),
    LatLng(32.530823, -92.655123),
    LatLng(32.530735, -92.655314)
  ];

  List<LatLng> universityParkLot = [
    LatLng(32.532558, -92.651816),
    LatLng(32.532552, -92.651100),
    LatLng(32.532368, -92.651046),
    LatLng(32.532365, -92.650982),
    LatLng(32.531908, -92.650978),
    LatLng(32.531901, -92.651069),
    LatLng(32.531825, -92.651071),
    LatLng(32.531831, -92.651748),
    LatLng(32.531889, -92.651765),
    LatLng(32.531901, -92.651824),
  ];

  List<LatLng> universityParkLot2 = [
    LatLng(32.532944, -92.650639),
    LatLng(32.532939, -92.650520),
    LatLng(32.532984, -92.650515),
    LatLng(32.532984, -92.650276),
    LatLng(32.532919, -92.650276),
    LatLng(32.532918, -92.650214),
    LatLng(32.533100, -92.650215),
    LatLng(32.533101, -92.650009),
    LatLng(32.533150, -92.650010),
    LatLng(32.533148, -92.649867),
    LatLng(32.533089, -92.649867),
    LatLng(32.533083, -92.649798),
    LatLng(32.533024, -92.649797),
    LatLng(32.533019, -92.649858),
    LatLng(32.532972, -92.649858),
    LatLng(32.532964, -92.649800),
    LatLng(32.532671, -92.649810),
    LatLng(32.532640, -92.649907),
    LatLng(32.532661, -92.650445),
    LatLng(32.532703, -92.650503),
    LatLng(32.532629, -92.650536),
    LatLng(32.532540, -92.650532),
    LatLng(32.532536, -92.650496),
    LatLng(32.532588, -92.650493),
    LatLng(32.532581, -92.649948),
    LatLng(32.532536, -92.649943),
    LatLng(32.532482, -92.649850),
    LatLng(32.532391, -92.649851),
    LatLng(32.532387, -92.649793),
    LatLng(32.532001, -92.649803),
    LatLng(32.532002, -92.649858),
    LatLng(32.531870, -92.649847),
    LatLng(32.531871, -92.649921),
    LatLng(32.531896, -92.649961),
    LatLng(32.531858, -92.649984),
    LatLng(32.531860, -92.650061),
    LatLng(32.531901, -92.650061),
    LatLng(32.531912, -92.650189),
    LatLng(32.532072, -92.650181),
    LatLng(32.532083, -92.650619),
    LatLng(32.532144, -92.650618),
    LatLng(32.532153, -92.650681),
    LatLng(32.532290, -92.650681),
    LatLng(32.532293, -92.650615),
    LatLng(32.532431, -92.650616),
    LatLng(32.532439, -92.650674),
    LatLng(32.532707, -92.650677),
    LatLng(32.532708, -92.650608),
    LatLng(32.532745, -92.650567),
    LatLng(32.532841, -92.650567),
    LatLng(32.532847, -92.650634),
  ];

  List<LatLng> techDriveLot = [
    LatLng(32.530340, -92.654958),
    LatLng(32.530268, -92.653582),
    LatLng(32.530359, -92.653559),
    LatLng(32.530606, -92.652729),
    LatLng(32.530602, -92.652589),
    LatLng(32.530667, -92.652585),
    LatLng(32.530648, -92.652219),
    LatLng(32.529621, -92.652265),
    LatLng(32.529739, -92.654746),
    LatLng(32.529830, -92.654836),
    LatLng(32.530264, -92.654962)
  ];

  List<LatLng> baseballComplex = [
    LatLng(32.530864, -92.651128),
    LatLng(32.530866, -92.650551),
    LatLng(32.530698, -92.650551),
    LatLng(32.530699, -92.650777),
    LatLng(32.530750, -92.650779),
    LatLng(32.530754, -92.651129),
  ];

  List<LatLng> universityParkLot3 = [
    LatLng(32.530755, -92.650423),
    LatLng(32.530743, -92.650169),
    LatLng(32.530705, -92.650174),
    LatLng(32.530700, -92.650271),
    LatLng(32.530375, -92.650294),
    LatLng(32.530371, -92.650366),
    LatLng(32.530321, -92.650368),
    LatLng(32.530321, -92.650240),
    LatLng(32.530383, -92.650238),
    LatLng(32.530378, -92.650120),
    LatLng(32.530314, -92.650124),
    LatLng(32.530312, -92.649978),
    LatLng(32.530368, -92.649976),
    LatLng(32.530364, -92.649859),
    LatLng(32.530200, -92.649862),
    LatLng(32.530204, -92.649979),
    LatLng(32.530258, -92.649982),
    LatLng(32.530262, -92.650444),
  ];

  List<LatLng> railroadAve = [
    LatLng(32.529130, -92.653932),
    LatLng(32.529155, -92.653670),
    LatLng(32.529132, -92.653130),
    LatLng(32.529088, -92.652635),
    LatLng(32.529060, -92.652637),
    LatLng(32.529057, -92.652636),
    LatLng(32.529096, -92.653149),
    LatLng(32.529116, -92.653510),
    LatLng(32.529115, -92.653697),
    LatLng(32.529095, -92.653922),
  ];

  List<LatLng> railroadAve2 = [
    LatLng(32.529015, -92.653002),
    LatLng(32.528980, -92.652508),
    LatLng(32.528928, -92.652514),
    LatLng(32.528964, -92.653010),
  ];

  List<LatLng> railroadAve3 = [
    LatLng(32.528974, -92.654432),
    LatLng(32.528998, -92.654184),
    LatLng(32.529021, -92.653984),
    LatLng(32.529041, -92.653784),
    LatLng(32.528990, -92.653779),
    LatLng(32.528915, -92.654412),
  ];

  List<LatLng> intramuralResidentLot = [
    LatLng(32.528855, -92.653629),
    LatLng(32.528840, -92.653417),
    LatLng(32.528961, -92.653412),
    LatLng(32.528963, -92.653136),
    LatLng(32.528134, -92.653165),
    LatLng(32.528156, -92.653667),
  ];

  List<LatLng> intramuralCommuterLot = [
    LatLng(32.528780, -92.654788),
    LatLng(32.528774, -92.654646),
    LatLng(32.528101, -92.654686),
    LatLng(32.528089, -92.654836),
    LatLng(32.528199, -92.654818),
    LatLng(32.528204, -92.654876),
    LatLng(32.528505, -92.654861),
    LatLng(32.528507, -92.654798),
    LatLng(32.528641, -92.654787),
    LatLng(32.528647, -92.654850),
    LatLng(32.528729, -92.654847),
    LatLng(32.528727, -92.654782),
  ];

  List<LatLng> intramuralCommuterLot2 = [
    LatLng(32.526502, -92.654153),
    LatLng(32.526081, -92.653414),
    LatLng(32.525932, -92.653544),
    LatLng(32.525925, -92.653602),
    LatLng(32.525933, -92.653641),
    LatLng(32.525890, -92.653678),
    LatLng(32.526277, -92.654348),
  ];

  List<LatLng> memorialGymLot = [
    LatLng(32.528878, -92.651724),
    LatLng(32.528862, -92.650922),
    LatLng(32.528694, -92.650937),
    LatLng(32.528711, -92.651735),
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
      //print("Address: $_address");
      _address = address_dict.addresses[address][0];
      //print("Address: $_address");
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

    getAddressFromLatLng(value.latitude, value.longitude);

    print('somethign address');
    });
    
    //initalize polygon
    _polygon.add(
      Polygon(
        polygonId: PolygonId('1'),
        points: tolliverCommuter,
        fillColor: Colors.yellow.withOpacity(0.3),
        strokeColor: Colors.yellow,
        geodesic: true,
        strokeWidth: 2,
      )
    );

    _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: tolliverResident,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 2,
        )
      );

    _polygon.add(
        Polygon(
          polygonId: PolygonId('3'),
          points: bookstoreProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: tacLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: tacLot2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: stadiumCircle,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: stadiumLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: stadiumLot2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: universityParkLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: universityParkLot2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: techDriveLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

    _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: baseballComplex,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: universityParkLot3,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: railroadAve,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: railroadAve2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: railroadAve3,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: intramuralResidentLot,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: intramuralCommuterLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: intramuralCommuterLot2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('2'),
          points: memorialGymLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 2,
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