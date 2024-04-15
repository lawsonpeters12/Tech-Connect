// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:collection';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:tech_connect/components/map_dict.dart' as address_dict;

class MapPage extends StatefulWidget{
  const MapPage({super.key});

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

  bool isDarkMode = false;

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }
  
  final LatLng northEastBound = LatLng(32.534665145170706, -92.63876772509097);
  final LatLng southWestBound = LatLng(32.523864894532736, -92.6582692918401);
  late GoogleMapController mapController;
  String? _address;

  final LatLng _center = LatLng(32.52741208116641, -92.64696455825013);
  
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
  
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];

      setState(() {
      
      _address = ("${place.street}");
      print("Address: $_address");
      _address = address_dict.addresses[_address];
      print("Address: $_address");
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
    }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromRGBO(203, 102, 102, 40) : Color.fromRGBO(198, 218, 231, 1),
      appBar: AppBar( title: Text('Campus Map --- $_address'),
      backgroundColor: isDarkMode ? Color.fromRGBO(167, 43, 42, 1) : Color.fromRGBO(77, 95, 128, 100),
      toolbarHeight: 80,
      ),

      // redundant container for formatting later
      body: Container( 

      child: GoogleMap(
      polygons: _polygon,
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
     
    ),
    
    
    ),
    
    );

  }
}