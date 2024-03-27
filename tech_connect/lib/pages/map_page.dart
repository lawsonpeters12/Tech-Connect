// ignore_for_file: prefer_const_constructors

//import 'dart:developer';
//import 'dart:ffi';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'package:geofence_service/geofence_service.dart';
import 'package:flutter/services.dart';
import 'package:tech_connect/components/map_dict.dart' as address_dict;
//import 'package:location/location.dart' as locationlib;

class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool isDarkMode = false;

  Future<void> getDarkModeValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }


  //final GeocodingPlatform _geocodingPlatform;
  
  final LatLng northEastBound = LatLng(32.534665145170706, -92.63876772509097);
  final LatLng southWestBound = LatLng(32.523864894532736, -92.6582692918401);
  //final LatLngBounds cameraBounds = LatLngBounds(southwest: southWestBound, northeast: northEastBound);
  //late GeofenceService _geofenceService;
  late GoogleMapController mapController;
  String? _address;
  //late LatLng currentLocation;
  //final LatLngBounds cameraLimit = (32.52, -92.);
  final LatLng _center = LatLng(32.52741208116641, -92.64696455825013);
  //final List<Geofence> _geofences = [];
  /*
  final _geofenceService = GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC
  );

  final _geofenceList = <Geofence>[
    Geofence(
    id: 'IESB', 
    latitude: 32.52639755141901, 
    longitude: -92.64279822540782,
    radius: [GeofenceRadius(id: 'radius_100m', length: 100),
            GeofenceRadius(id: 'radius_25m', length: 25),
            GeofenceRadius(id: 'radius_250m', length: 250),
            GeofenceRadius(id: 'radius_200m', length: 200),]
    )
  ];

  Future<void> _onGeofenceStatusChanged(
    Geofence geofence,
    GeofenceRadius geofenceRadius,
    GeofenceStatus geofenceStatus,
    Location location) async {
      print('geofence: ${geofence.toJson()}');
      print('geofenceRadius: ${geofenceRadius.toJson()}');
      print('geofenceStatus: ${geofenceStatus.toString()}');
    }

    void _onLocationChanged(Location location) {
      print('location: ${location.toJson()}');
    }

    void _onError(error) {
      final errorCode = getErrorCodesFromError(error);
      if(errorCode == null) {
        print('Undefined error: $error');
        return;
      }
    }
*/
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      //print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
  
      //print('Address before calling placemarks');
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      //print('Address after calling placemarkss');
      //print('Address: ');

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
    /*
    setState(() {
      
    });
    */
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