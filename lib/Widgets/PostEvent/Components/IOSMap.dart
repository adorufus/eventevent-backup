// import 'package:apple_maps_flutter/apple_maps_flutter.dart';
// import 'package:camera/new/camera.dart';
// import 'package:flutter/material.dart';

// class IosMap extends StatefulWidget {
//   final String latitude;
//   final String longitude;

//   const IosMap({Key key, this.latitude, this.longitude}) : super(key: key);
//   @override
//   _IosMapState createState() => _IosMapState();
// }

// class _IosMapState extends State<IosMap> {
//   _IosMapState();

//   AppleMapController mapController;
//   LatLng _lastSelected;
//   CameraPosition _kInitialPosition;

//   @override
//   void initState() {
//     _kInitialPosition = CameraPosition(
//         target: LatLng(double.parse(widget.latitude), double.parse( widget.longitude)),
//         zoom: 11
//     );
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AppleMap appleMap = AppleMap(
//       onMapCreated: onMapCreated,
//       initialCameraPosition: _kInitialPosition,
//       onTap: (LatLng pos){
//         setState(() {
//           _lastSelected = pos;
//         });
//       },
//     );

//     return Center(
//             child: SizedBox(
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               child: appleMap,
//             ),
//         );
//   }

//   void onMapCreated(AppleMapController controller) async{
//     setState(() {
//       mapController = controller;
//     });
//   }
// }

