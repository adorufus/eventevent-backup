import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Home/PeopleSearch.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'FinishPostEvent.dart';

class PostEventInvitePeople extends StatefulWidget {
  final String calledFrom;
  final eventId;

  const PostEventInvitePeople(
      {Key key, @required this.calledFrom, this.eventId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return PostEventInvitePeopleState();
  }
}

class PostEventInvitePeopleState extends State<PostEventInvitePeople> {
  List data;
  List<String> invitedPeople = new List<String>();
  List tempInvitedPeople = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Center(
                  child: Text(
                'back',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontSize: ScreenUtil.instance.setSp(18)),
              ))),
          centerTitle: true,
          title: Text(
            'PEOPLE',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    data == null
                        ? Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => FinishPostEvent()))
                        : finish();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: data == null
            ? HomeLoadingScreen().followListLoading()
            : Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 15, top: 15),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: 10, right: 25, left: 25, bottom: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => PeopleSearch(),
                            ),
                          ).then((invitedFromSearch) {
                            print(invitedFromSearch);
                            tempInvitedPeople.addAll(invitedFromSearch);
                            for(int i = 0; i < invitedFromSearch.length; i++){
                              invitedPeople.add(invitedFromSearch[i]['id']);
                            }

                            print(invitedPeople);
                            print(tempInvitedPeople);
                            if(mounted) setState((){});
                          });
                        },
                        child: Material(
                            borderRadius: BorderRadius.circular(40),
                            elevation: 2.0,
                            shadowColor: Colors.black,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.search),
                                  SizedBox(width: 10),
                                  Text(
                                    'Search People',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                    invitedPeople.isNotEmpty
                        ? Text('Invited People',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: eventajaBlack))
                        : Container(),
                    invitedPeople.isNotEmpty
                        ? ColumnBuilder(
                            itemCount: tempInvitedPeople.length == null
                                ? 0
                                : tempInvitedPeople.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                onTap: () {
                                  tempInvitedPeople.removeAt(i);
                                  invitedPeople.removeAt(i);
                                  if (mounted) setState((){});
                                },
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(tempInvitedPeople[i]['photo']),
                                ),
                                title: Text(
                                  tempInvitedPeople[i]['fullName'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('@' + tempInvitedPeople[i]['username']),
                                trailing: Icon(
                                  Icons.check,
                                  color: invitedPeople.contains(tempInvitedPeople[i]['id'])
                                      ? eventajaGreenTeal
                                      : Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(),
                    Text(
                      'Recommended From Following',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: eventajaBlack),
                    ),
                    ColumnBuilder(
                      itemCount: data.length == null ? 0 : data.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          onTap: () {
                            saveData(i);
                          },
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 15),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(data[i]['photo']),
                          ),
                          title: Text(
                            data[i]['fullName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('@' + data[i]['username']),
                          trailing: Icon(
                            Icons.check,
                            color: invitedPeople.contains(data[i]['id'])
                                ? eventajaGreenTeal
                                : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ));
  }

  Future finish() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/invite_event/post';
    Map<dynamic, dynamic> body = {
      'X-API-KEY': API_KEY,
      'eventID': widget.calledFrom == "other event"
          ? widget.eventId
          : prefs.getInt('NEW_EVENT_ID').toString()
    };

    for (int i = 0; i < invitedPeople.length; i++) {
      var people = invitedPeople;
      body.addAll({'userID[$i]': people[i]});
    }

    print(body.toString());

    final response = await http.post(url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        },
        body: body);

    print(response.statusCode);

    if (response.statusCode == 201) {
      print(response.body);
      if (widget.calledFrom == "other event") {
        Navigator.pop(context);
      } else {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => FinishPostEvent()));
      }
    }
  }

  saveData(int index) async {
    setState(() {
      if (invitedPeople.contains(data[index]['id'])) {
        invitedPeople.remove(data[index]['id']);
        tempInvitedPeople.removeWhere((invPpl) => invPpl['id'] == data[index]['id']);
      } else {
        invitedPeople.add(data[index]['id']);
        tempInvitedPeople.add({
          'id': data[index]['id'],
          'photo': data[index]['photo'],
          'username': data[index]['username'],
          'fullName': data[index]['fullName']
        });
      }
      print(invitedPeople);
      print(tempInvitedPeople);
    });
  }

  Future fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/user/follower?X-API-KEY=$API_KEY&userID=${prefs.getString('Last User ID')}&page=1';
    var extractedData;

    final response = await http.get(url,
        headers: ({
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        }));

    // print(prefs.getInt('NEW_EVENT_ID').toString());
    print(response.statusCode);
    print(response.body);
    setState(() {
      extractedData = json.decode(response.body);
    });

    if (response.statusCode == 200) {
      setState(() {
        data = extractedData['data'];
      });
    }
  }
}
