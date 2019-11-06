import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:http/http.dart' as http;

class EventStatistic extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    
    return EventStatisticState();
  }
}

class EventStatisticState extends State<EventStatistic>{

  String eventName;
  String viewers;
  String lovers;
  String totalMale;
  String totalFemale;
  String totalUnspecified;

  Map sharedData;
  Map ticketData;
  Map genderData;
  Map checkinData;
  Map<String, double> dataMap = new Map();


  @override
  void initState() {
    super.initState();
    getData();
    getShared();
    getTicketStat();
    getCheckedIn();
    getViewers();
  }

  getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      eventName = prefs.getString('EVENT_NAME');
      viewers = prefs.getString('EVENT_VIEWED');
      lovers = prefs.getString('EVENT_LOVED');
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text('EVENT STATISTIC', style: TextStyle(color: eventajaGreenTeal),),
      ),
      body: sharedData == null || ticketData == null || checkinData == null || dataMap == null ? Container(child: Center(child: CircularProgressIndicator(),)) : Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text('EVENT NAME', style: TextStyle(fontSize: 18, color: Colors.grey[500]),),
                Text(eventName.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)
              ],
            ),
            SizedBox(height: 25,),
            Divider(color: Colors.grey,),
            SizedBox(height: 20,),
            Center(child: Text('OVERVIEW', style: TextStyle(color: Colors.grey[500], fontSize: 18),),),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 35,
                      width: 50,
                      child: Image.asset('assets/icons/butt_eye.png', fit: BoxFit.fill,),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      viewers,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    SizedBox(
                      height: 15
                    ),
                    Text(
                      'VIEWED',
                      style: TextStyle(color: eventajaGreenTeal),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/icons/butt_love_ijo.png', fit: BoxFit.fill,),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      lovers,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    SizedBox(
                        height: 15
                    ),
                    Text(
                      'LIKED',
                      style: TextStyle(color: eventajaGreenTeal),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset('assets/icons/butt_share.png', fit: BoxFit.fill,),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      sharedData['total_shared'] == null ? '-' : sharedData['total_shared'].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    SizedBox(
                        height: 15
                    ),
                    Text(
                      'SHARED',
                      style: TextStyle(color: eventajaGreenTeal),
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                'VIEWERS', style: TextStyle(color: Colors.grey[500], fontSize: 18)
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                PieChart(
                    dataMap: dataMap,
                  colorList: <Color>[
                    eventajaGreenTeal,
                    eventajaGreenTeal.withOpacity(0.5),
                    Colors.grey
                  ],
                  showLegends: false,
                  chartValuesColor: Colors.white,
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 80,
                      width: 45,
                      child: Image.asset('assets/icons/butt_cowo.png', color: eventajaGreenTeal,)
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(totalMale, style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                        height: 80,
                        width: 45,
                        child: Image.asset('assets/icons/butt_cewe.png', color: eventajaGreenTeal,)
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(totalFemale, style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      child: SizedBox(
                          height: 50,
                          width: 25,
                          child: Image.asset('assets/icons/butt_gender_apakah_ini.png', color: Colors.grey,)
                      ),
                    ),
                    SizedBox(
                      height: 25
                    ),
                    Text(totalUnspecified, style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                )
              ],
            ),
            SizedBox(
              height: 20
            ),
            Divider(
              color: Colors.grey,
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('TICKET SOLD', style: TextStyle(fontSize: 18),),
                Text(ticketData['sold'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: eventajaGreenTeal))
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('TICKET BOOKED', style: TextStyle(fontSize: 18)),
                Text(ticketData['booked'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: eventajaGreenTeal))
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('CHECKED IN', style: TextStyle(fontSize: 18)),
                Text(ticketData['sold'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: eventajaGreenTeal))
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('TOTAL AVAILABLE TICKET', style: TextStyle(fontSize: 18)),
                Text(ticketData['available'].toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: eventajaGreenTeal))
              ],
            )
          ],
        ),
      ),
    );
  }

  Future getShared() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/analytic_event/shared?X-API-KEY=$API_KEY&event_id=${prefs.getString('NEW_EVENT_ID')}';

    final response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        }
    );

    print(response.statusCode);

    if(response.statusCode == 200){
      setState(() {
        var extractedData = json.decode(response.body);
        sharedData = extractedData['data'];

        print(sharedData);
      });
    }
  }

  Future getCheckedIn() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/analytic_event/checkin?X-API-KEY=$API_KEY&event_id=${prefs.getString('NEW_EVENT_ID')}';

    final response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        }
    );

    print(response.statusCode);

    if(response.statusCode == 200){
      setState(() {
        var extractedData = json.decode(response.body);
        checkinData = extractedData['data'];

        print(checkinData);
      });
    }
  }

  Future getViewers() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/analytic_event/gender?X-API-KEY=$API_KEY&event_id=${prefs.getString('NEW_EVENT_ID')}';

    final response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        }
    );

    print(response.statusCode);
    print(response.body);

    if(response.statusCode == 200){
      setState(() {
        var extractedData = json.decode(response.body);
        double total = double.parse((extractedData['data']['Male'] + extractedData['data']['Female'] + extractedData['data']['Unspecified']).toString());

        totalMale = (((double.parse(extractedData['data']['Male'].toString()) / total) * 100).toStringAsFixed(0) + '%');
        totalFemale = (((double.parse(extractedData['data']['Female'].toString()) / total) * 100).toStringAsFixed(0) + '%');
        totalUnspecified = (((double.parse(extractedData['data']['Unspecified'].toString()) / total) * 100).toStringAsFixed(0) + '%');
        print(totalFemale);
        print(totalMale);
        print(totalUnspecified);

        dataMap.putIfAbsent('Male', () => double.parse(extractedData['data']['Male'].toString()));
        dataMap.putIfAbsent('Female', () => double.parse(extractedData['data']['Female'].toString()));
        dataMap.putIfAbsent('Unspecified', () => double.parse(extractedData['data']['Unspecified'].toString()));
      });
    }
  }

  Future getTicketStat() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/analytic_event/ticket?X-API-KEY=$API_KEY&event_id=${prefs.getString('NEW_EVENT_ID')}';

    final response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        }
    );

    print(response.statusCode);

    if(response.statusCode == 200){
      setState(() {
        var extractedData = json.decode(response.body);
        ticketData = extractedData['data'];

        print(ticketData);
      });
    }
  }
}