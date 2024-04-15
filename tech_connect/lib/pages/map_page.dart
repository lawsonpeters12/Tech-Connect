import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tech_connect/components/map_dict.dart' as address_dict;
import 'package:tech_connect/pages/org_profile.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MapPage extends StatefulWidget{
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final LatLng northEastBound = const LatLng(32.534665145170706, -92.63876772509097);
  final LatLng southWestBound = const LatLng(32.523864894532736, -92.6582692918401);

  bool buttonTextBool = false;
  // TODO make this change on if there is an event or not
  bool currentEventBool = true;
  String locationImageURL = '';
  late GoogleMapController mapController;
  late List events = [];
  String? _address;
  //late String locationImageURL = 'https://firebasestorage.googleapis.com/v0/b/techconnect-42543.appspot.com/o/images%2Fltp012%40email.latech.edu-2024-02-26T22%3A03%3A04.720577Z.jpg?alt=media&token=133169be-e402-4d99-b7c1-f051a8155a6c';

  late String eventData;

  final LatLng _center = const LatLng(32.52741208116641, -92.64696455825013);
 
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
  print(eventsQuery);
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
    print(getImageUrl());
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
      print("Address: $_address");
      locationImageURL = address_dict.addresses[address][1];
      print('image url: $locationImageURL');
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

    getUserCurrentLocation().then((value) async {

    CameraPosition cameraPosition = CameraPosition(
      target: LatLng(value.latitude, value.longitude),
      zoom: 16,);
    
    final GoogleMapController controller = mapController;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    getAddressFromLatLng(value.latitude, value.longitude);

    print('somethign address');
    });
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
    ),
    );
  }
}