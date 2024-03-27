// ignore_for_file: prefer_const_constructors

//import 'dart:developer';
//import 'dart:ffi';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
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

  //final GeocodingPlatform _geocodingPlatform;
  
  final LatLng northEastBound = LatLng(32.534665145170706, -92.63876772509097);
  final LatLng southWestBound = LatLng(32.523864894532736, -92.6582692918401);
  //final LatLngBounds cameraBounds = LatLngBounds(southwest: southWestBound, northeast: northEastBound);
  //late GeofenceService _geofenceService;
  late GoogleMapController mapController;
  late String _address;
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
    //const double latitude = 32.52629966078266;
    //const double longitude = -92.6433865400934;
    //print('holy shit');
    //try {
      print('Address before calling placemarks');
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemarks[0];
      print('Address after calling placemarkss');
      //print('Address: ');

      setState(() {
      
      _address = ("${place.street}");
      print("Address: $_address");
      _address = address_dict.addresses[_address];
      print("Address: $_address");
      //print('Address: $_address');
      //, ${place.postalCode}, ${place.locality}, ${place.administrativeArea}, ${place.country}");
      });
    //} catch (e) {
    //  print(e);
    //}
  }

  Future<void> _getKeyLocations() async {
    //final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //GeocodingPlatform _geocodingPlatform;
    setState(() {
 
  });
  }

  // get rid of this if possible to simplify code.
  @override
  void initState() {
    super.initState();
    //print('this is a fucking debug statement');
    //_getKeyLocations();
    //getAddressFromLatLng();
    
    //_getKeyLocations();

    getUserCurrentLocation().then((value) async {
    // specified current users location
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(value.latitude, value.longitude),
      zoom: 16,);
    
    final GoogleMapController controller = mapController;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    getAddressFromLatLng(value.latitude, value.longitude);
    //print("Address: $_address");
    });
    /*
    //_geofenceService.addGeofenceList(_geofences);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      //_geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      //_geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    }
    );
    */
    //_geofenceService.addGeofenceList(_geofences);
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color.fromRGBO(77, 95, 128, 100),
      appBar: AppBar( title: Text('Campus Map --- $_address'),
      toolbarHeight: 80,
      ),

      // redundant container for formatting later
      body: Container( 
      //padding: EdgeInsets.all(20.0),
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
      //polygons: _geofences,
    ),
    
    
    ),
    
    );

  }
}