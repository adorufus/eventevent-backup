import 'dart:convert';

import 'package:eventevent/Widgets/PostEvent/CreateTicketName.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddNewTicket extends StatefulWidget {
  final isLivestream;

  const AddNewTicket({Key key, @required this.isLivestream}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return AddNewTicketState();
  }
}

class AddNewTicketState extends State<AddNewTicket> {
  GlobalKey<ScaffoldState> thisState = GlobalKey<ScaffoldState>();

  List ticketType;
  String imageUri;
  String description;
  String thisTicketTypeId;

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    return Scaffold(
        key: thisState,
        appBar: AppBar(
          brightness: Brightness.light,
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
              padding: EdgeInsets.symmetric(horizontal: 13),
              children: <Widget>[
                widget.isLivestream == true
                    ? Container()
                    : ListTile(
                        onTap: () {
                          setState(() {
                            thisTicketTypeId = "1";
                          });
                          proccess(thisTicketTypeId);
                        },
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        leading: SizedBox(
                          height: ScreenUtil.instance.setWidth(40),
                          width: ScreenUtil.instance.setWidth(140),
                          child: Image.asset(
                            'assets/btn_ticket/paid.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        title: Text(
                          'Paid',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'Set-up and start selling your own paid ticket(s) to your attandees'),
                      ),
                widget.isLivestream == true
                    ? Container()
                    : ListTile(
                        onTap: () {
                          setState(() {
                            thisTicketTypeId = "2";
                          });
                          proccess(thisTicketTypeId);
                        },
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        leading: SizedBox(
                          height: ScreenUtil.instance.setWidth(40),
                          width: ScreenUtil.instance.setWidth(140),
                          child: Image.asset(
                            'assets/btn_ticket/free-limited.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        title: Text(
                          'Free - Limited',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'For free event that require form registrations and only offers limited slots \/ seats (i.e free seminar, workshop, class).'),
                      ),
                widget.isLivestream == false
                    ? Container()
                    : ListTile(
                        onTap: () {
                          setState(() {
                            thisTicketTypeId = "4";
                          });
                          proccess(thisTicketTypeId);
                        },
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        leading: Container(
                          height: ScreenUtil.instance.setWidth(40),
                          width: ScreenUtil.instance.setWidth(140),
                          decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Color(0xFFFFAA00).withOpacity(0.4),
                                blurRadius: 2,
                                spreadRadius: 1.5,
                              )
                            ],
                            color: Color(0xFFFFAA00),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'FREE',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        title: Text(
                          'Free Live Stream',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'For free online live event for anyone across places. The streaming is mobile friendly and available to be played back by attendees for certain period.'),
                      ),
                widget.isLivestream == false
                    ? Container()
                    : ListTile(
                        onTap: () {
                          setState(() {
                            thisTicketTypeId = "3";
                          });
                          proccess(thisTicketTypeId);
                        },
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                        leading: Container(
                          height: ScreenUtil.instance.setWidth(40),
                          width: ScreenUtil.instance.setWidth(140),
                          decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: eventajaGreenTeal.withOpacity(0.4),
                                  blurRadius: 2,
                                  spreadRadius: 1.5)
                            ],
                            color: Color(0xFF34B323),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                              child: Text(
                            'PAID',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                        title: Text(
                          'Paid Live Stream',
                          style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(18),
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'For paid online live event for anyone across places. The streaming is mobile friendly and available to be played back by attendees for certain period.'),
                      ),
                // widget.isLivestream == true ? Container() : ListTile(onTap: (){
                //   setState((){
                //     thisTicketTypeId = "7";
                //   });
                //   proccess(thisTicketTypeId);
                // },
                //   contentPadding: EdgeInsets.symmetric(vertical: 20),
                //   leading: SizedBox(
                //     height: ScreenUtil.instance.setWidth(40),
                //     width: ScreenUtil.instance.setWidth(140),
                //     child: Image.asset(
                //       'assets/btn_ticket/free-limited.png',
                //       fit: BoxFit.fill,
                //     ),
                //   ),
                //   title: Text(
                //     'Free Limited (Seating)',
                //     style: TextStyle(fontSize: ScreenUtil.instance.setSp(18), fontWeight: FontWeight.bold),
                //   ),
                //   subtitle: Text('For free event that require form registrations and only offers limited slots \/ seats (i.e free seminar, workshop, class)For free event that require form registrations and only offers limited slots \/ seats (i.e free seminar, workshop, class)'),
                // )
              ],
            )));
  }

  proccess(String ticketTypeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('SETUP_TICKET_PAID_TICKET_TYPE', ticketTypeId);
    prefs.setString('NEW_EVENT_TICKET_TYPE_ID', ticketTypeId);
    prefs.setBool('isLivestream', widget.isLivestream);
    print(prefs.getString('SETUP_TICKET_PAID_TICKET_TYPE'));
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => CreateTicketName()));
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
