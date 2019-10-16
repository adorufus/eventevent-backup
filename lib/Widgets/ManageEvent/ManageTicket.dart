import 'dart:convert';

import 'package:eventevent/Widgets/ManageEvent/AddNewTicket.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ManageTicket extends StatefulWidget {
  final String eventID;

  const ManageTicket({Key key, this.eventID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ManageTicketState();
  }
}

class ManageTicketState extends State<ManageTicket> {
  String ticketID;
  List ticketList;
  Map ticketDetails;
  List imageUri;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTicketList();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal, size: 15),
        backgroundColor: Colors.white,
        centerTitle: true,
        title:
            Text('MANAGE TICKETS', style: TextStyle(color: eventajaGreenTeal)),
      ),
      body: ticketList == null
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  ColumnBuilder(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    itemCount: ticketList == null ? 0 : ticketList.length,
                    itemBuilder: (BuildContext context, i) {
                      print(ticketID);
                      return Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 150,
                              width: 100,
                              child: Image.network(
                                ticketList[i]['ticket_image']['secure_url'],
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  ticketList[i]['ticket_name'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Available',
                                        style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 18),
                                      )
                                    ]),
                                Container(
                                  height: 55,
                                  width: 125,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(ticketList[i][
                                                          'paid_ticket_type_id'] ==
                                                      '2' ||
                                                  ticketList[i][
                                                          'paid_ticket_type_id'] ==
                                                      '7'
                                              ? 'assets/btn_ticket/free-limited.png'
                                              : 'assets/btn_ticket/paid-value.png'))),
                                  child: ticketList[i]['paid_ticket_type_id'] ==
                                              '2' ||
                                          ticketList[i]
                                                  ['paid_ticket_type_id'] ==
                                              '7'
                                      ? Container()
                                      : Center(
                                          child: Text(
                                          'Rp. ' + ticketList[i]['final_price'],
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )),
                                ),
                                Text(
                                    'Ticket(s) left: ${(int.parse(ticketList[i]['quantity']) - int.parse(ticketList[i]['sold']))} / ${ticketList[i]['quantity']}')
                              ],
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.navigate_next,
                              color: Colors.black,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      prefs.setInt('NEW_EVENT_ID', int.parse(widget.eventID));
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => AddNewTicket()));
                    },
                    child: Container(
                      color: Colors.white,
                      height: 150,
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add_circle_outline,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          Text(
                            'Add Ticket',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[300]),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future getTicketList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/ticket_setup/list?X-API-KEY=$API_KEY&eventID=${widget.eventID}';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        ticketList = extractedData['data'];

        for (int i = 0; i < ticketList.length; i++) {
          print(ticketList[i]['id']);
          getTicketData(ticketList[i]['id']);
        }
      });
    }
  }

  Future getTicketData(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =
        BaseApi().apiUrl + '/ticket_setup/tickets?X-API-KEY=$API_KEY&id=$id';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        prefs.setInt('NEW_EVENT_ID', int.parse(widget.eventID));
        var extractedData = json.decode(response.body);
        ticketDetails = extractedData['data'];
        print(extractedData);
      });
    }
  }
}
