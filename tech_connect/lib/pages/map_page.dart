// ignore_for_file: prefer_const_constructors


import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
late GoogleMapController mapController;
  LatLng _center = LatLng(32.52741208116641, -92.64696455825013);
  final Set<Marker> _markers = {};

  Future<void> _getKeyLocations() async {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('Wyly Tower'),
        position: LatLng(32.528210757177895, -92.64712045575439),
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('IESB'),
        position: LatLng(32.52641779650523, -92.64318310694401),
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('Woodard Hall'),
        position: LatLng(32.52714109333242, -92.65028315561175),
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('Love Park'),
        position: LatLng(32.52982745931875, -92.65115222527899),
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('Lambright Sports Center'),
        position: LatLng(32.53324377130569, -92.65079593688885),
      )
      );
    });
  }


  // get rid of this if possible to simplify code.
  @override
  void initState() {
    super.initState();
    _getKeyLocations();
  }

  @override
  Widget build(BuildContext context) {
    // wrap this in a container
    return Scaffold(
      backgroundColor: Color.fromRGBO(198, 218, 231, 100),
      appBar: AppBar( title: Text('Campus Map'),
      ),
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
      // Change this to be a camera box that you cant leave
      //minMaxZoomPreference: MinMaxZoomPreference(100, 999),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      buildingsEnabled: true,
      mapToolbarEnabled: true,
      markers: _markers,
    )
    )
    );
  }
}