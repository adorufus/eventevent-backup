import 'package:eventevent/Widgets/RecycleableWidget/EmptyState.dart';
import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrivateEventList extends StatefulWidget {
  final type;

  const PrivateEventList({Key key, this.type}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PrivateEventListState();
  }
}

class PrivateEventListState extends State<PrivateEventList> {
  List privateData;
  String imageUri;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    fetchMyEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        
        width: MediaQuery.of(context).size.width,
        child: isEmpty == true
            ? EmptyState(
                emptyImage: 'assets/drawable/event_empty_state.png',
                reasonText: 'You Have No Event Created Yet',
              )
            : privateData == null
                ? Container(
                    child: Center(
                    child: CircularProgressIndicator(),
                  ))
                : ListView.builder(
                  shrinkWrap: true,
                    itemCount:
                        privateData.length == null ? '0' : privateData.length,
                    itemBuilder: (BuildContext context, i) {
                      if (privateData.length == null) {
                        return Container(
                          child: Center(
                            child: Text('No Data'),
                          ),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  EventDetailsConstructView(
                                    id: privateData[i]['id'],
                                  )));
                        },
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          width: MediaQuery.of(context).size.width,
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width: 150,
                                    child: Image.network(
                                        privateData[i]['picture'],
                                        fit: BoxFit.fill),
                                  ),
                                  SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        privateData[i]['dateStart'],
                                        style:
                                            TextStyle(color: eventajaGreenTeal),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        privateData[i]['name'],
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        privateData[i]['isPrivate'] == '0'
                                            ? 'PUBLIC EVENT'
                                            : 'PRIVATE EVENT',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      buttonType(i)
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 20),
                              Divider()
                            ],
                          ),
                        ),
                      );
                    },
                  ));
  }

  Widget buttonType(int index) {
    if (privateData[index]['ticket_type']['id'] == '5' ||
        privateData[index]['ticket_type']['id'] == '10') {
      imageUri = 'assets/btn_ticket/free-limited.png';
    } else if (privateData[index]['ticket_type']['id'] == '1') {
      imageUri = 'assets/btn_ticket/free.png';
    } else if (privateData[index]['ticket_type']['id'] == '2') {
      imageUri = 'assets/btn_ticket/no-ticket.png';
    } else if (privateData[index]['ticket_type']['id'] == '3') {
      imageUri = 'assets/btn_ticket/ots-800px.png';
    } else if (privateData[index]['ticket_type']['id'] == '4') {
      imageUri = 'assets/btn_ticket/paid.png';
    }

    return SizedBox(
      height: 50,
      width: 150,
      child: Image.asset(
        imageUri,
        fit: BoxFit.fill,
      ),
    );
  }

  Future fetchMyEvent() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uri = BaseApi().apiUrl +
        '/user/${widget.type}?X-API-KEY=$API_KEY&page=1&userID=${prefs.getString('Last User ID')}&isPrivate=1';

    final response = await http.get(
      uri,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session')
      },
    );

    print(response.statusCode);
    var extractedData = json.decode(response.body);

    if (response.statusCode == 200) {
      print(response.body);
      if (extractedData['data']['private']['data'].length == 0) {
        setState(() {
          isEmpty = true;
        });
      } else {
        setState(() {
          isEmpty = false;
          privateData = extractedData['data']['private']['data'];
        });
      }
    } else {
      print(response.body);
    }
  }
}
