import 'dart:convert';

import 'package:eventevent/Widgets/PostEvent/CreateTicketName.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddNewTicket extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AddNewTicketState();
  }
}

class AddNewTicketState extends State<AddNewTicket>{
  GlobalKey<ScaffoldState> thisState = GlobalKey<ScaffoldState>();

  List ticketType;
  String imageUri;
  String description;
  String thisTicketTypeId;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: thisState,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            ),
          ),
          centerTitle: true,
          title: Text(
            'CHOOSE TICKET TYPE',
            style: TextStyle(color: eventajaGreenTeal),
          ),
        ),
        body: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              ListTile(
                onTap: (){
                  setState((){
                    thisTicketTypeId = "1";
                  });
                  proccess(thisTicketTypeId);
                },
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                leading: SizedBox(
                  height: 40,
                  width: 140,
                  child: Image.asset(
                    'assets/btn_ticket/paid.png',
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(
                  'Paid',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Set-up and start selling your own paid ticket(s) to your attandees'),
              ),
              ListTile(onTap: (){
                setState((){
                  thisTicketTypeId = "2";
                });
                proccess(thisTicketTypeId);
              },
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                leading: SizedBox(
                  height: 40,
                  width: 140,
                  child: Image.asset(
                    'assets/btn_ticket/free-limited.png',
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(
                  'Free - Limited',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('For free event that require form registrations and only offers limited slots \/ seats (i.e free seminar, workshop, class).'),
              ),
              ListTile(
                onTap: (){
                  setState((){
                    thisTicketTypeId = "4";
                  });
                  proccess(thisTicketTypeId);
                },
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                leading: SizedBox(
                  height: 40,
                  width: 140,
                  child: Image.asset(
                    'assets/btn_ticket/free-limited.png',
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(
                  'Free Live Stream',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('For free online live event for anyone across places. The streaming is mobile friendly and available to be played back by attendees for certain period.'),
              ),
              ListTile(onTap: (){
                setState((){
                  thisTicketTypeId = "7";
                });
                proccess(thisTicketTypeId);
              },
                contentPadding: EdgeInsets.symmetric(vertical: 20),
                leading: SizedBox(
                  height: 40,
                  width: 140,
                  child: Image.asset(
                    'assets/btn_ticket/free-limited.png',
                    fit: BoxFit.fill,
                  ),
                ),
                title: Text(
                  'Free Limited (Seating)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('For free event that require form registrations and only offers limited slots \/ seats (i.e free seminar, workshop, class)For free event that require form registrations and only offers limited slots \/ seats (i.e free seminar, workshop, class)'),
              )
            ],
          )
        ));
  }

  proccess(String ticketTypeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('NEW_EVENT_TICKET_TYPE_ID', ticketTypeId);
    print(prefs.getString('NEW_EVENT_TICKET_TYPE_ID'));
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => CreateTicketName()));
  }

//  Future getTicketTypeList() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String url = BaseApi().apiUrl + '/ticket_type/list?X-API-KEY=$API_KEY';
//
//    final response = await http.get(url,
//        headers: ({
//          'Authorization': AUTHORIZATION_KEY,
//          'cookie': prefs.getString('Session')
//        }));
//
//    if (response.statusCode == 200) {
//      setState(() {
//        var extractedData = json.decode(response.body);
//        ticketType = extractedData['data'];
//      });
//    }
//  }
}