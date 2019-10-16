import 'dart:convert';

import 'package:eventevent/Widgets/Home/See%20All/MyTicketItem.dart';
import 'package:eventevent/Widgets/ProfileWidget/UseTicket.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyTicketWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyTicketWidgetState();
  }
}

class _MyTicketWidgetState extends State<MyTicketWidget> {
  var session;
  String userId;

  Map<String, dynamic> ticketData;
  Map<String, dynamic> publicData;

  List ticketDetailData;

  @override
  void initState() {
    super.initState();
    getDataTicket();
  }

  @override
  Widget build(BuildContext context) {
    return ticketDetailData == null
          ? Container(child: Center(child: CircularProgressIndicator()))
          : Container(
              color: Colors.black.withOpacity(0.05),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  itemCount:
                      ticketDetailData == null ? 0 : ticketDetailData.length,
                  itemBuilder: (BuildContext context, i) {
                    Color ticketColor;
                    String ticketStatusText;

                    if (ticketDetailData[i]['usedStatus'] == 'available') {
                      ticketColor = eventajaGreenTeal;
                      ticketStatusText = 'Available';
                    } else if (ticketDetailData[i]['usedStatus'] == 'used') {
                      ticketColor = Color(0xFFA6A8AB);
                      ticketStatusText = 'Used';
                    } else if (ticketDetailData[i]['usedStatus'] == 'expired') {
                      ticketColor = Color(0xFF8E1E2D);
                      ticketStatusText = 'Expired';
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => UseTicket(
                                  ticketTitle: ticketDetailData[i]['ticket']
                                      ['ticket_name'],
                                  ticketImage: ticketDetailData[i]
                                      ['ticket_image']['url'],
                                  ticketCode: ticketDetailData[i]
                                      ['ticket_code'],
                                  ticketDate: ticketDetailData[i]['event']
                                      ['dateStart'],
                                  ticketStartTime: ticketDetailData[i]['event']
                                      ['timeStart'],
                                  ticketEndTime: ticketDetailData[i]['event']
                                      ['timeEnd'],
                                  ticketDesc: ticketDetailData[i]['event']
                                      ['name'],
                                  ticketID: ticketDetailData[i]['id'],
                                  usedStatus: ticketStatusText,
                                )));
                      },
                      child: new MyTicketItem(
                        image: ticketDetailData[i]['ticket_image']
                            ['secure_url'],
                        title: ticketDetailData[i]['event']['name'],
                        ticketCode: ticketDetailData[i]['ticket_code'],
                        ticketStatus: ticketStatusText,
                        timeStart: ticketDetailData[i]['event']['timeStart'],
                        timeEnd: ticketDetailData[i]['event']['timeEnd'],
                        ticketName: ticketDetailData[i]['ticket']
                            ['ticket_name'],
                        ticketColor: ticketColor,
                        // topPadding: i == 0 ? 13.0 : 0.0,
                      ),
                    );
                  }),
    );
  }

  Future getDataTicket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      session = prefs.getString('Session');
      userId = prefs.getString('Last User ID');
    });

    var urlApi =
        BaseApi().apiUrl + '/tickets/all?X-API-KEY=${API_KEY}&page=1&search=';
    final response = await http.get(urlApi, headers: {
      'Authorization': 'Basic YWRtaW46MTIzNA==',
      'cookie': session
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        ticketDetailData = extractedData['data'];
      });
    }
  }
}
