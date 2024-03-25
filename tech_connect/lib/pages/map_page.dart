// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  
  final LatLng northEastBound = LatLng(32.534665145170706, -92.63876772509097);
  final LatLng southWestBound = LatLng(32.523864894532736, -92.6582692918401);
  //final LatLngBounds cameraBounds = LatLngBounds(southwest: southWestBound, northeast: northEastBound);

  late GoogleMapController mapController;
  //final LatLngBounds cameraLimit = (32.52, -92.);
  final LatLng _center = LatLng(32.52741208116641, -92.64696455825013);
  final Set<Polygon> _geofences = {};
  
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      //print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getKeyLocations() async {
    //final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      log('ryan');
        //_current = LatLng(position.latitude, position.longitude);
        _geofences.add(Polygon(polygonId: PolygonId('IESB'),
        points: const [
          LatLng(32.52686957807876, -92.64404631669886), 
          LatLng(32.525993264184095, -92.64414494032368),
          LatLng(32.52589731688815, -92.64160348537621),
          LatLng(32.52677363171867, -92.6415655532128),
        ],
        strokeColor: Color.fromARGB(0, 0, 0, 0),
        fillColor: Color.fromARGB(0, 0, 0, 0)));

      
  });
  }

  // get rid of this if possible to simplify code.
  @override
  void initState() {
    super.initState();
    _getKeyLocations();
    getUserCurrentLocation().then((value) async {
    // specified current users location
    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(value.latitude, value.longitude),
      zoom: 16,);

    final GoogleMapController controller = mapController;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color.fromRGBO(77, 95, 128, 100),
      appBar: AppBar( title: Text('Campus Map'),
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
      polygons: _geofences,
    )
    ),
    );

  }
}