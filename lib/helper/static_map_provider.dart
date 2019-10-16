import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StaticMapsProvider extends StatefulWidget {
  final String GOOGLE_API_KEY;
  final int width;
  final int height;
  final String latitude;
  final String longitude;
  final bool isRedirectToGMAP;

  const StaticMapsProvider({Key key, @required this.GOOGLE_API_KEY, this.width, this.height, this.latitude, this.longitude, this.isRedirectToGMAP = true}) : super(key: key);

  
  @override
  State<StatefulWidget> createState() {
    return _StaticMapsProviderState();
  }
}

class _StaticMapsProviderState extends State<StaticMapsProvider>{
  

  @override
  Widget build(BuildContext context) {
    String mapURI = 'https://maps.googleapis.com/maps/api/staticmap?center=${widget.latitude}%2C${widget.longitude}&zoom=20&size=${widget.width}x${widget.height}&scale=2&maptype=roadmap&key=${widget.GOOGLE_API_KEY}';
    String googleMap = 'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    return widget.isRedirectToGMAP == false ? Image.network(mapURI, fit: BoxFit.fill, width: 300, height: 300) : GestureDetector(
      onTap: (){
        openMap(googleMap, context);
      },
      child: Image.network(mapURI, fit: BoxFit.fill,)
    );
  }

  static openMap(String mapurl, BuildContext context) async {
    String url = mapurl;
    if(await canLaunch(url)){
      await launch(url);
    }
    else{
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Couldn\'t open map'),
        duration: Duration(seconds: 3),
      ));
    } 
  }    
}