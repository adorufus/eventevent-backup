import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'FinishPostEvent.dart';


class PostEventInvitePeople extends StatefulWidget{
  final String calledFrom;
  final eventId;

  const PostEventInvitePeople({Key key, @required this.calledFrom, this.eventId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    
    return PostEventInvitePeopleState();
  }
}

class PostEventInvitePeopleState extends State<PostEventInvitePeople>{

  List data;
  List<String> invitedPeople = new List<String>();

  @override
  void initState() {
    
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Center(child: Text('back', style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18)),))
          ),
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
                    finish();
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                ),
              ),
            )
          ],
        ),
        body: data == null ? Container(child: Center(child: CupertinoActivityIndicator(radius: 20)),) : Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, top: 15),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              itemCount: data.length == null ? 0 : data.length,
              itemBuilder: (context, i){
                return ListTile(
                  onTap: (){
                    saveData(i);
                  },
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  leading: CircleAvatar(backgroundImage: NetworkImage(data[i]['photo']),),
                  title: Text(data[i]['fullName'], style: TextStyle(fontWeight: FontWeight.bold),),
                  subtitle: Text('@' + data[i]['username']),
                  trailing: Icon(Icons.check, color: Colors.grey,),
                );
              },
            ),
        ));
  }

  Future finish() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/invite_event/post';
    Map<dynamic, dynamic> body = {
        'X-API-KEY': API_KEY,
        'eventID': widget.calledFrom == "other event" ? widget.eventId : prefs.getInt('NEW_EVENT_ID').toString()
      };

    for(int i = 0; i < invitedPeople.length; i++){
      var people = invitedPeople;
      body.addAll({
        'userID[$i]': people[i]
      });
    }

    print(body.toString());

    final response = await http.post(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session')
      },
      body: body
    );

    print(response.statusCode);

    if(response.statusCode == 201){
      print(response.body);
      if(widget.calledFrom == "other event"){
        Navigator.pop(context);
      }
      else {
        Navigator.push(context, CupertinoPageRoute(builder: (context) => FinishPostEvent()));
      }
    }
  }

  saveData(int index) async{
    setState(() {
      if(invitedPeople.contains(data[index]['id'])){
        invitedPeople.remove(data[index]['id']);
      }
      else{
        invitedPeople.add(data[index]['id']);
      }
      print(invitedPeople);
    });
  }

  Future fetchData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/user/follower?X-API-KEY=${API_KEY}&userID=${prefs.getString('Last User ID')}&page=1';
    var extractedData;

    final response = await http.get(
      url,
      headers: ({'Authorization': AUTHORIZATION_KEY, 'cookie': prefs.getString('Session')})
    );

    print(prefs.getInt('NEW_EVENT_ID'));
    print(response.statusCode);
    print(response.body);
    setState(() {
      extractedData = json.decode(response.body);
    });

    if(response.statusCode == 200){
      setState(() {
        data = extractedData['data'];
      });
    }
  }
}