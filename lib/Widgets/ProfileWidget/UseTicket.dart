import 'dart:convert';

import 'package:eventevent/Widgets/ProfileWidget/ScanBarcode.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsWidget.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class UseTicket extends StatefulWidget{

  final ticketTitle;
  final ticketImage;
  final ticketDate;
  final ticketCode;
  final ticketStartTime;
  final ticketEndTime;
  final ticketDesc;
  final ticketID;
  final usedStatus;

  const UseTicket({Key key, this.ticketTitle, this.ticketImage, this.ticketDate, this.ticketCode, this.ticketStartTime, this.ticketEndTime, this.ticketDesc, this.ticketID, this.usedStatus}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UseTicketState();
  }
}

class UseTicketState extends State<UseTicket>{
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  String _scanBarcode = '';
  Future<String> _barcodeString;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap:(){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text(widget.ticketTitle, style: TextStyle(color: eventajaGreenTeal),),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: widget.usedStatus == 'USED'|| widget.usedStatus == 'EXPIRED' ? (){} : (){
          scan().then((_) async{
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String url = BaseApi().apiUrl + '/tickets/verify';

            final response = await http.post(
              url,
              headers: {
                'Authorization': AUTHORIZATION_KEY,
                'cookie': prefs.getString('Session')
              },
              body: {
                'X-API-KEY': API_KEY,
                'qrData': _scanBarcode,
                'ticketID': widget.ticketID
              }
            );

            var extractedData = json.decode(response.body);

            if(response.statusCode == 200 || response.statusCode == 201){
              print(extractedData['desc']);
              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SuccessPage()));
            }
            else{
              scaffoldKey.currentState.showSnackBar(SnackBar(
                backgroundColor: Colors.red,
                content: extractedData['desc'] == null ? Text(extractedData['error']) : Text(extractedData['desc']),
              ));
            }

            //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SettingsWidget()));
          });
//          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ScanBarcode()));
        },
        child: Container(
          height: 50,
          color: widget.usedStatus == 'USED' ? Colors.grey : widget.usedStatus == 'EXPIRED' ? Colors.red : Colors.deepOrangeAccent,
          child: Center(
            child: Text(widget.usedStatus == 'USED' ? 'USED' : widget.usedStatus == 'EXPIRED' ? 'EXPIRED' :  'USE TICKET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Container(
            foregroundDecoration: BoxDecoration(backgroundBlendMode: widget.usedStatus == 'AVAILABLE' ? null : BlendMode.saturation, color: widget.usedStatus == 'AVAILABLE' ? null : Colors.grey),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(widget.ticketImage, fit: BoxFit.fill),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 15),
                        Text(widget.ticketDate, style: TextStyle(color: eventajaGreenTeal),),
                        SizedBox(height: 10),
                        Text(widget.ticketTitle, style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text(widget.ticketCode, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        SizedBox(height: 10),
                        Text(widget.ticketStartTime.toString() + ' - ' + widget.ticketEndTime.toString(), style: TextStyle(color: Colors.grey),),
                        SizedBox(height: 10),
                        Text(widget.ticketDesc)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//  scan2(){
//    setState(() {
//      _barcodeString = new QRCodeReader()
//          .setAutoFocusIntervalInMs(200)
//          .setForceAutoFocus(true)
//          .setTorchEnabled(false)
//          .setHandlePermissions(true)
//          .setExecuteAfterPermissionGranted(true)
//          .scan();
//    });
//
//    print(_barcodeString);
//  }

  Future<void> scan() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes =
      await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", true);
    } catch (e){
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
    
    print(_scanBarcode);
  }
}
