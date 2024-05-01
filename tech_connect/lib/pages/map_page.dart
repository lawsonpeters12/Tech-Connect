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

  List<LatLng> TechPoint2Parking =[
    LatLng(32.524725, -92.644148),
    LatLng(32.524658, -92.642953),
    LatLng(32.525691, -92.642309),
    LatLng(32.525857, -92.643128),
    LatLng(32.525349, -92.643166),
    LatLng(32.525351, -92.643484),
    LatLng(32.524978, -92.643472),
    LatLng(32.525018, -92.644116)
  ];

  List<LatLng> TechPoint2ParkingStaff= [
    LatLng(32.525817, -92.643232),
    LatLng(32.525811, -92.643388),
    LatLng(32.525497, -92.643444),
    LatLng(32.525472, -92.643235)
  ];

  List<LatLng> IESBGravelCommuterLot= [
    LatLng(32.526757, -92.642510),
    LatLng(32.526336, -92.642559),
    LatLng(32.526336, -92.642559),
    LatLng(32.526313, -92.642191),
    LatLng(32.526147, -92.642225),
    LatLng(32.526133, -92.642126),
    LatLng(32.526079, -92.642115),
    LatLng(32.526075, -92.641911),
    LatLng(32.526120, -92.641911),
    LatLng(32.526326, -92.641688),
    LatLng(32.526613, -92.641662),
    LatLng(32.526636, -92.641664),
    LatLng(32.526617, -92.641495),
    LatLng(32.526584, -92.641498),
    LatLng(32.526595, -92.641554),
    LatLng(32.526303, -92.641563),
    LatLng(32.526290, -92.641508),
    LatLng(32.526009, -92.641508),
    LatLng(32.526016, -92.641199),
    LatLng(32.526667, -92.641165),
  ];

  List <LatLng> IESBGravelCommuterLot2 = [
    LatLng(32.526105, -92.642554),
    LatLng(32.526082, -92.642251),
    LatLng(32.526179, -92.642240),
    LatLng(32.526204, -92.642573),
  ];

  List <LatLng> IESBGravelProfessor = [
    LatLng(32.526297, -92.642235),
    LatLng(32.526313, -92.642444),
    LatLng(32.526199, -92.642449),
    LatLng(32.526195, -92.642240)
  ];

  List <LatLng> IESBCOBCommuterLot = [
    LatLng(32.527017, -92.642819),
    LatLng(32.527062, -92.642814),
    LatLng(32.527061, -92.642756),
    LatLng(32.527150, -92.642751),
    LatLng(32.527153, -92.642808),
    LatLng(32.527193, -92.642803),
    LatLng(32.527190, -92.642743),
    LatLng(32.527281, -92.642740),
    LatLng(32.527293, -92.642794),
    LatLng(32.527338, -92.642795),
    LatLng(32.527369, -92.643375),
    LatLng(32.527320, -92.643373),
    LatLng(32.527337, -92.643514),
    LatLng(32.527374, -92.643527),
    LatLng(32.527399, -92.643897),
    LatLng(32.527353, -92.643903),
    LatLng(32.527352, -92.643956),
    LatLng(32.527257, -92.643962),
    LatLng(32.527249, -92.643903),
    LatLng(32.527220, -92.643907),
    LatLng(32.527214, -92.643967),
    LatLng(32.527122, -92.643968),
    LatLng(32.527118, -92.643915),
    LatLng(32.527077, -92.643915),
    LatLng(32.527045, -92.643436),
    LatLng(32.527093, -92.643431),
    LatLng(32.527084, -92.643294),
    LatLng(32.527041, -92.643295),
  ];

  List <LatLng> IESBCOBProfessorLot = [
    LatLng(32.527424, -92.643501),
    LatLng(32.527701, -92.643491),
    LatLng(32.527722, -92.643878),
    LatLng(32.527674, -92.643874),
    LatLng(32.527669, -92.643934),
    LatLng(32.527457, -92.643940),
    LatLng(32.527449, -92.643915),
    LatLng(32.527435, -92.643917),
  ];

  List <LatLng> KeeneyCircle = [
    LatLng(32.527973, -92.645458),
    LatLng(32.527979, -92.645598),
    LatLng(32.527967, -92.645683),
    LatLng(32.527915, -92.645786),
    LatLng(32.527856, -92.645848),
    LatLng(32.527795, -92.645887),
    LatLng(32.527704, -92.645918),
    LatLng(32.527552, -92.645964),
    LatLng(32.527581, -92.645916),
    LatLng(32.527691, -92.645887),
    LatLng(32.527792, -92.645844),
    LatLng(32.527851, -92.645802),
    LatLng(32.527922, -92.645718),
    LatLng(32.527944, -92.645637),
    LatLng(32.527950, -92.645511),
    LatLng(32.527937, -92.645413),
  ];

  List <LatLng> KeeneyCircle2 = [
    LatLng(32.527883, -92.645179),
    LatLng(32.527909, -92.645581),
    LatLng(32.527902, -92.645640),
    LatLng(32.527874, -92.645712),
    LatLng(32.527811, -92.645780),
    LatLng(32.527766, -92.645810),
    LatLng(32.527680, -92.645844),
    LatLng(32.527633, -92.645861),
    LatLng(32.527559, -92.645875),
    LatLng(32.527494, -92.645881),
    LatLng(32.527490, -92.645849),
    LatLng(32.527626, -92.645832),
    LatLng(32.527701, -92.645807),
    LatLng(32.527767, -92.645777),
    LatLng(32.527813, -92.645743),
    LatLng(32.527839, -92.645714),
    LatLng(32.527864, -92.645680),
    LatLng(32.527882, -92.645631),
    LatLng(32.527882, -92.645543),
    LatLng(32.527854, -92.645182),
  ];

  List <LatLng> KeeneyCircle3 = [
    LatLng(32.527166, -92.645828),
    LatLng(32.527137, -92.645808),
    LatLng(32.527116, -92.645786),
    LatLng(32.527093, -92.645756),
    LatLng(32.527078, -92.645721),
    LatLng(32.527059, -92.645671),
    LatLng(32.527055, -92.645629),
    LatLng(32.527050, -92.645561),
    LatLng(32.527044, -92.645460),
    LatLng(32.527040, -92.645348),
    LatLng(32.527034, -92.645272),
    LatLng(32.527033, -92.645211),
    LatLng(32.527059, -92.645217),
    LatLng(32.527076, -92.645582),
    LatLng(32.527081, -92.645633),
    LatLng(32.527090, -92.645668),
    LatLng(32.527104, -92.645718),
    LatLng(32.527125, -92.645749),
    LatLng(32.527144, -92.645779),
    LatLng(32.527176, -92.645801),
  ];

    List <LatLng> KeeneyCircle4 = [
      LatLng(32.527161, -92.645878),
      LatLng(32.527108, -92.645843),
      LatLng(32.527076, -92.645797),
      LatLng(32.527032, -92.645710),
      LatLng(32.527013, -92.645604),
      LatLng(32.527003, -92.645454),
      LatLng(32.526997, -92.645224),
      LatLng(32.526964, -92.645202),
      LatLng(32.526984, -92.645664),
      LatLng(32.527004, -92.645749),
      LatLng(32.527035, -92.645806),
      LatLng(32.527078, -92.645862),
      LatLng(32.527128, -92.645904),
    ];

    List <LatLng> COBParallel = [
      LatLng(32.527052, -92.644871),
      LatLng(32.527035, -92.644890),
      LatLng(32.527018, -92.644517),
      LatLng(32.527033, -92.644537),
    ];

    List <LatLng> COBParallel2 = [
      LatLng(32.526967, -92.644863),
      LatLng(32.526961, -92.644758),
      LatLng(32.526957, -92.644851),
      LatLng(32.526951, -92.644773),
    ];

    List <LatLng> COBParallel3 = [
      LatLng(32.526962, -92.644715),
      LatLng(32.526946, -92.644690),
      LatLng(32.526932, -92.644535),
      LatLng(32.526950, -92.644516),
    ];

    List <LatLng> COBParallel4 = [
      LatLng(32.526941, -92.644299),
      LatLng(32.526945, -92.644436),
      LatLng(32.526931, -92.644420),
      LatLng(32.526924, -92.644323),
    ];

    List <LatLng> COBParallel5 = [
      LatLng(32.527191, -92.644178),
      LatLng(32.527177, -92.644163),
      LatLng(32.527634, -92.644131),
      LatLng(32.527622, -92.644153),
    ];

    List <LatLng> COBParallel6 = [
      LatLng(32.527211, -92.644079),
      LatLng(32.527207, -92.644061),
      LatLng(32.527615, -92.644036),
      LatLng(32.527624, -92.644058),
    ];

    List <LatLng> COBParallel7 = [
      LatLng(32.527819, -92.644256),
      LatLng(32.527803, -92.644276),
      LatLng(32.527840, -92.644871),
      LatLng(32.527856, -92.644882),
    ];

    List <LatLng> COBParallel8 = [
      LatLng(32.527920, -92.644874),
      LatLng(32.527936, -92.644849),
      LatLng(32.527896, -92.644291),
      LatLng(32.527882, -92.644285),
    ];

    List <LatLng> UniversityHallCommuter = [
      LatLng(32.528536, -92.645229),
      LatLng(32.528559, -92.645604),
      LatLng(32.528506, -92.645611),
      LatLng(32.528515, -92.645649),
      LatLng(32.528557, -92.645653),
      LatLng(32.528574, -92.646140),
      LatLng(32.528406, -92.646153),
      LatLng(32.528388, -92.645654),
      LatLng(32.528507, -92.645649),
      LatLng(32.528491, -92.645229),
    ];

    List <LatLng> UniversityHallProfessor = [
      LatLng(32.528432, -92.645506),
      LatLng(32.528319, -92.645509),
      LatLng(32.528318, -92.645339),
      LatLng(32.528428, -92.645338),
    ];

    List <LatLng> UniversityHallProfessor2 = [
      LatLng(32.528251, -92.645370),
      LatLng(32.528196, -92.645374),
      LatLng(32.528198, -92.645246),
      LatLng(32.528243, -92.645238),
    ];

    List <LatLng> RailroadParallel = [
      LatLng(32.528690, -92.646126),
      LatLng(32.528671, -92.646126),
      LatLng(32.528632, -92.645339),
      LatLng(32.528653, -92.645340),
    ];

    List <LatLng> Wyly = [
      LatLng(32.528686, -92.647826),
      LatLng(32.528243, -92.647968),
      LatLng(32.528230, -92.647915),
      LatLng(32.528182, -92.647933),
      LatLng(32.528106, -92.647619),
      LatLng(32.528665, -92.647433),
      LatLng(32.528641, -92.647590),
      LatLng(32.528632, -92.647610),
      LatLng(32.528630, -92.647643),
      LatLng(32.528648, -92.647674),
      LatLng(32.528674, -92.647768),
    ];

    List <LatLng> IESBParallel = [
      LatLng(32.526267, -92.644230),
      LatLng(32.526284, -92.644245),
      LatLng(32.526530, -92.644229),
      LatLng(32.526547, -92.644212)
    ];

    List <LatLng> IESBParallel2 = [
      LatLng(32.526629, -92.644095),
      LatLng(32.526632, -92.644117),
      LatLng(32.526222, -92.644144),
      LatLng(32.526222, -92.644129)
    ];

    List <LatLng> NethkenParallel = [
      LatLng(32.525500, -92.644284),
      LatLng(32.525531, -92.644299),
      LatLng(32.525800, -92.644277),
      LatLng(32.525829, -92.644257)
    ];

    List <LatLng> NethkenParallel2 = [
      LatLng(32.525758, -92.644190),
      LatLng(32.525726, -92.644175),
      LatLng(32.525454, -92.644194),
      LatLng(32.525433, -92.644209)
    ];

    List <LatLng> NethkenProfessor = [
      LatLng(32.525449, -92.644432),
      LatLng(32.525503, -92.645172),
      LatLng(32.525474, -92.645184),
      LatLng(32.525427, -92.644433),
    ];

    List <LatLng> NethkenCommuter = [
      LatLng(32.525403, -92.645196),
      LatLng(32.525300, -92.645204),
      LatLng(32.525259, -92.644372),
      LatLng(32.525367, -92.644368),
    ];

    List <LatLng> GrahamSideCommuter  = [
      LatLng(32.524673, -92.645281),
      LatLng(32.524652, -92.644947),
      LatLng(32.524798, -92.644943),
      LatLng(32.524760, -92.644878),
      LatLng(32.525140, -92.644844),
      LatLng(32.525163, -92.645236),
    ];

    List <LatLng> BoghardProfessor = [
      LatLng(32.526122, -92.645335),
      LatLng(32.526083, -92.645305),
      LatLng(32.526126, -92.646099),
      LatLng(32.526160, -92.646127)
    ];

    List <LatLng> BoghardAdamsProfessor = [
      LatLng(32.526215, -92.646295),
      LatLng(32.526248, -92.646257),
      LatLng(32.526602, -92.646230),
      LatLng(32.526534, -92.646272),
    ];

    List <LatLng> BoghardAdamsProfessor2 = [
      LatLng(32.526688, -92.646456),
      LatLng(32.526665, -92.646498),
      LatLng(32.526343, -92.646527),
      LatLng(32.526371, -92.646485),
    ];

    List <LatLng> BoghardAdamsProfessor3 = [
      LatLng(32.526253, -92.646368),
      LatLng(32.526256, -92.646343),
      LatLng(32.526797, -92.646300),
      LatLng(32.526797, -92.646326),
    ];

    List <LatLng> BoghardAdamsProfessor4 = [
      LatLng(32.526797, -92.646381),
      LatLng(32.526796, -92.646402),
      LatLng(32.526311, -92.646441),
      LatLng(32.526306, -92.646416),
    ];
    
    List <LatLng> AdamsCommuter = [
      LatLng(32.525124, -92.646620),
      LatLng(32.525154, -92.646576),
      LatLng(32.524457, -92.646626),
      LatLng(32.524430, -92.646665)
    ];
    
    List <LatLng> AdamsCommuter2 = [
      LatLng(32.524228, -92.646574),
      LatLng(32.524233, -92.646600),
      LatLng(32.525080, -92.646534),
      LatLng(32.525078, -92.646507)
    ];

    List <LatLng> AdamsCommuter3 = [
      LatLng(32.524226, -92.646523),
      LatLng(32.524224, -92.646497),
      LatLng(32.525067, -92.646432),
      LatLng(32.525073, -92.646458)
    ];

    List <LatLng> AdamsCommuter4 = [
      LatLng(32.524411, -92.646419),
      LatLng(32.524412, -92.646397),
      LatLng(32.524180, -92.646412),
      LatLng(32.524184, -92.646439)
    ];

    List <LatLng> AdamsCommuter5 = [
      LatLng(32.524778, -92.646367),
      LatLng(32.524746, -92.646409),
      LatLng(32.524604, -92.646419),
      LatLng(32.524633, -92.646379)
    ];

    List <LatLng> AdamsCommuter6 = [
      LatLng(32.525021, -92.646390),
      LatLng(32.525054, -92.646344),
      LatLng(32.524987, -92.646345),
      LatLng(32.524955, -92.646394)
    ];

    List <LatLng> AdamsCommuter7 = [
      LatLng(32.524889, -92.646401),
      LatLng(32.524914, -92.646354),
      LatLng(32.524846, -92.646359),
      LatLng(32.524812, -92.646404)
    ];

    List <LatLng> AdamsCommuter8 = [
      LatLng(32.525229, -92.646608),
      LatLng(32.525260, -92.646567),
      LatLng(32.525993, -92.646516),
      LatLng(32.525963, -92.646555)
    ];

    List <LatLng> CarsonTaylorProfessor = [
      LatLng(32.525871, -92.646284),
      LatLng(32.525834, -92.646333),
      LatLng(32.525273, -92.646369),
      LatLng(32.525303, -92.646327)
    ];

    List <LatLng> GrahamCommuter = [
      LatLng(32.524384, -92.646207),
      LatLng(32.524335, -92.645512),
      LatLng(32.524421, -92.645540),
      LatLng(32.524473, -92.646209),
    ];

    List <LatLng> GrahamCommuter2 = [
      LatLng(32.524512, -92.646158),
      LatLng(32.524492, -92.645588),
      LatLng(32.524576, -92.645593),
      LatLng(32.524600, -92.646155)
    ];
    
    List <LatLng> DudleyHallResident = [
      LatLng(32.525137, -92.647755),
      LatLng(32.525147, -92.647897),
      LatLng(32.524608, -92.647949),
      LatLng(32.524600, -92.647804)
    ];

    List <LatLng> DavisonCommuter = [
      LatLng(32.524675, -92.649050),
      LatLng(32.524672, -92.648929),
      LatLng(32.524424, -92.648923),
      LatLng(32.524427, -92.649046)
    ];

    List <LatLng> DavisonCommuter2 = [
      LatLng(32.524262, -92.648724),
      LatLng(32.524227, -92.648197),
      LatLng(32.524326, -92.648147),
      LatLng(32.524342, -92.648682)
    ];

    List <LatLng> DavisonGravelCommuter = [
      LatLng(32.524359, -92.648794),
      LatLng(32.524353, -92.648974),
      LatLng(32.524312, -92.648973),
      LatLng(32.524315, -92.650047),
      LatLng(32.524073, -92.649970),
      LatLng(32.523785, -92.649973),
      LatLng(32.523771, -92.649602),
      LatLng(32.523568, -92.649383),
      LatLng(32.523850, -92.648866),
      LatLng(32.524203, -92.648879),
      LatLng(32.524218, -92.648788),
    ];

    List <LatLng> DavisonProfessor = [
      LatLng(32.524732, -92.648781),
      LatLng(32.524477, -92.648795),
      LatLng(32.524736, -92.648834),
      LatLng(32.524476, -92.648832)
    ];

    List <LatLng> BioMedProfessor = [
      LatLng(32.524739, -92.649143),
      LatLng(32.524744, -92.649200),
      LatLng(32.524444, -92.649188),
      LatLng(32.524444, -92.649145)
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

      _polygon.add(
        Polygon(
          polygonId: PolygonId('4'),
          points: TechPoint2Parking,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('5'),
          points: TechPoint2ParkingStaff,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('6'),
          points: IESBGravelCommuterLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('7'),
          points: IESBGravelCommuterLot2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('8'),
          points: IESBGravelProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('9'),
          points: IESBCOBCommuterLot,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('10'),
          points: IESBCOBProfessorLot,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('11'),
          points: KeeneyCircle,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('12'),
          points: KeeneyCircle2,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('13'),
          points: KeeneyCircle3,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('14'),
          points: KeeneyCircle4,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('15'),
          points: COBParallel,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('16'),
          points: COBParallel2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('17'),
          points: COBParallel3,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('18'),
          points: COBParallel4,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('19'),
          points: COBParallel5,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('20'),
          points: COBParallel6,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('21'),
          points: COBParallel7,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('22'),
          points: COBParallel8,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('22'),
          points: COBParallel8,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('23'),
          points: UniversityHallCommuter,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('24'),
          points: UniversityHallProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('25'),
          points: UniversityHallProfessor2,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('26'),
          points: RailroadParallel,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('27'),
          points: Wyly,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('28'),
          points: IESBParallel,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('29'),
          points: IESBParallel2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('30'),
          points: NethkenParallel,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('31'),
          points: NethkenParallel2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('32'),
          points: GrahamSideCommuter,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('33'),
          points: NethkenCommuter,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('34'),
          points: NethkenProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('35'),
          points: BoghardProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('36'),
          points: BoghardAdamsProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('37'),
          points: BoghardAdamsProfessor2,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('38'),
          points: BoghardAdamsProfessor3,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('39'),
          points: BoghardAdamsProfessor4,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('40'),
          points: AdamsCommuter,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('41'),
          points: AdamsCommuter2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('42'),
          points: AdamsCommuter3,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('43'),
          points: AdamsCommuter4,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('44'),
          points: AdamsCommuter5,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('45'),
          points: AdamsCommuter6,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('46'),
          points: CarsonTaylorProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('47'),
          points: GrahamCommuter,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('48'),
          points: GrahamCommuter2,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('49'),
          points: AdamsCommuter7,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('50'),
          points: AdamsCommuter8,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('51'),
          points: DudleyHallResident,
          fillColor: Colors.red.withOpacity(0.3),
          strokeColor: Colors.red,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('52'),
          points: DavisonCommuter,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('53'),
          points: DavisonCommuter2,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('54'),
          points: DavisonProfessor,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeColor: Colors.blue,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('55'),
          points: DavisonGravelCommuter,
          fillColor: Colors.yellow.withOpacity(0.3),
          strokeColor: Colors.yellow,
          geodesic: true,
          strokeWidth: 4,
        )
      );

      _polygon.add(
        Polygon(
          polygonId: PolygonId('56'),
          points: BioMedProfessor,
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