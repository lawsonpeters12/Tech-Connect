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
  late LatLng _current;

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR"+error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }
  
  Future<void> _getKeyLocations() async {
    //final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
        //_current = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
        markerId: MarkerId('Wyly Tower'),
        position: LatLng(32.528210757177895, -92.64712045575439),
        infoWindow: InfoWindow(
          title: 'Wyly Tower'
        )
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('IESB'),
        position: LatLng(32.52633128747083, -92.6435751327031),
        infoWindow: InfoWindow(
          title: 'IESB'
        )
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('Woodard Hall'),
        position: LatLng(32.52714109333242, -92.65028315561175),
        infoWindow: InfoWindow(
          title: 'Woodard Hall'
        )
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('Love Park'),
        position: LatLng(32.52982745931875, -92.65115222527899),
        infoWindow: InfoWindow(
          title: 'Love Park'
        )
      )
      );

      _markers.add(Marker(
        markerId: MarkerId('Lambright Sports Center'),
        position: LatLng(32.53324377130569, -92.65079593688885),
        infoWindow: InfoWindow(
          title: 'Lambright Sports Center'
        )
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

    return Scaffold(
      backgroundColor: Color.fromRGBO(77, 95, 128, 100),
      appBar: AppBar( title: Text('Campus Map'),
      toolbarHeight: 80,
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
      //liteModeEnabled: true,
      //mapType: MapType.satellite,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      //buildingsEnabled: true,
      //mapToolbarEnabled: true,
      markers: _markers,
    )
    ),
    floatingActionButton: FloatingActionButton(
        onPressed: () async{
          getUserCurrentLocation().then((value) async {
            print(value.latitude.toString() +" "+value.longitude.toString());
 
            // marker added for current users location
            _markers.add(
                Marker(
                  markerId: MarkerId("2"),
                  position: LatLng(value.latitude, value.longitude),
                  infoWindow: InfoWindow(
                    title: 'My Current Location',
                  ),
                )
            );
 
            // specified current users location
            CameraPosition cameraPosition = new CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 14,
            );
 
            final GoogleMapController controller = await mapController;
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {
            });
          });
        },
        child: Icon(Icons.local_activity),
      ),
    );

  }
}