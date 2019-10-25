import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportPost extends StatefulWidget {
  final postId;
  final postType;

  const ReportPost({Key key, this.postId, this.postType}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ReportPostState();
  }
}

class ReportPostState extends State<ReportPost> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Widget> reportItems = [];
  String responseId;
  TextEditingController othersController = TextEditingController();

  bool isShow = false;
  bool isReported = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios,
            color: eventajaGreenTeal,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: (){
              doReport('3').then((response){
                  print(response.statusCode);
                  print(response.body);
                  var extractedData = json.decode(response.body);

                  if(response.statusCode == 201){
                    print('reported!');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SuccesReportPage()));
                  }
                  else{
                    print('failed');
                  }
                });
            },
                      child: isShow == false ? Container() : Container(
              margin: EdgeInsets.symmetric(horizontal: 13),
              child: Center(child: Text('Send', style: TextStyle(color: eventajaGreenTeal),)),
            ),
          )
        ],
        centerTitle: true,
        title: Text(
          'Report',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: ListView(children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Report post',
                style: TextStyle(
                    fontSize: 15,
                    color: Color(0xff8a8a8b),
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Why are you reporting this post?',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 13,
        ),
        Container(
          margin: EdgeInsets.only(bottom: 13),
          color: Colors.white,
          child: ListTile(
            title: Text('This post is inappropriate'),
            onTap: () {
              setState(() {
                doReport('0').then((response){
                  print(response.statusCode);
                  print(response.body);
                  var extractedData = json.decode(response.body);

                  if(response.statusCode == 201){
                    print('reported!');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SuccesReportPage()));
                  }
                  else{
                    print('failed');
                  }
                });
                isShow = false;
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 13),
          color: Colors.white,
          child: ListTile(
            title: Text('This post is spam or scam'),
            onTap: () {
              setState(() {
                doReport('1').then((response){
                  print(response.statusCode);
                  print(response.body);
                  var extractedData = json.decode(response.body);

                  if(response.statusCode == 201){
                    print('reported!');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SuccesReportPage()));
                  }
                  else{
                    print('failed');
                  }
                });
                isShow = false;
              });
            },
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 13),
          color: Colors.white,
          child: ListTile(
            title: Text('This post shouldn\'t be in EventEvent'),
            onTap: () {
              setState(() {
                doReport('2').then((response){
                  print(response.statusCode);
                  print(response.body);
                  var extractedData = json.decode(response.body);

                  if(response.statusCode == 201){
                    print('reported!');
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SuccesReportPage()));
                  }
                  else{
                    print('failed');
                  }
                });
                isShow = false;
              });
            },
          ),
        ),
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text('Others'),
            onTap: () {
              setState(() {
                isShow = !isShow;
              });
            },
          ),
        ),
        
        isShow == false ? Container() : showOtherForm()
      ]),
    );
  }

  Widget showOtherForm(){
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: TextFormField(
        controller: othersController,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        maxLines: 10,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          hintText: 'Tell me about your problem...'
        ),
      ),
    );
  }

  Future<http.Response> doReport(String responseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    const Event = "/event_flag/post";
    const Love = "/love_flag/post";
    const Thought = "/thought_flag/post";
    const CheckIn = "/checkin_flag/post";
    const Photo = "/photo_flag/post";
    const Video = "/video/flag";

    String endpoints = '';
    String responseMsg = '';

    setState(() {
      if (widget.postType == 'love') {
        endpoints = Love;
      } else if (widget.postType == 'photo') {
        endpoints = Photo;
      } else if (widget.postType == 'video') {
        endpoints = Video;
      } else if (widget.postType == 'event') {
        endpoints = Event;
      }

      if(responseId == '0'){
        responseMsg = 'This post is inappropriate';
      }
      else if(responseId == '1'){
        responseMsg = 'This post is spam or scam';
      }
      else if(responseId == '2'){
        responseMsg = 'This post shouldn\'t be in EventEvent';
      }
      else if(responseId == '3'){
        responseMsg = othersController.text;
      }
    });

    print(responseMsg);
    print(responseId);



    String url = BaseApi().apiUrl + endpoints;

    final response = await http.post(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'id': widget.postId,
      'response': responseMsg
    });

    var extractedData = json.decode(response.body);

    if(response.statusCode == 400){
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(extractedData['desc'], style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.red,
      ));
    }

    return response;
  }
}

class SuccesReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          child: Icon(
            Icons.arrow_back_ios,
            color: eventajaGreenTeal,
          ),
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        
        centerTitle: true,
        title: Text(
          'Report',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: Container(
        child: Center(
          child: Text('Thank you for your submission'),
        ),
      ),
    );
  }
}
