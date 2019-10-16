import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return PrivacyPolicyState();
  }
}

class PrivacyPolicyState extends State<PrivacyPolicy>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text('PRIVACY POLICY', style: TextStyle(color: eventajaGreenTeal),),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: 'https://eventevent.com/privacy-policy',
            ),
          )
        ],
      ),
    );
  }
}