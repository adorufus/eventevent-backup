import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class GiveFeedback extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return GiveFeedbackState();
  }
}

class GiveFeedbackState extends State<GiveFeedback>{

  TextEditingController feedbackController = new TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text('FEEDBACK', style: TextStyle(color: eventajaGreenTeal),),
        actions: <Widget>[
          GestureDetector(
            onTap: (){
              postFeedback();
            },
            child: Center(
              child: Text('Submit', style: TextStyle(color: eventajaGreenTeal, fontSize: 18),),
            ),
          ),
          SizedBox(width: 20,)
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: TextFormField(
            controller: feedbackController,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15)
              ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(15)
                ),
              filled: true,
              fillColor: Colors.white
            ),
          ),
        ),
      ),
    );
  }

  Future postFeedback() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/feedback/post';

    final response = await http.post(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        },
        body: {
          'X-API-KEY': API_KEY,
          'comment': feedbackController.text
        }
    );

    print(response.statusCode);
    print(response.body);

    var extractedData = json.decode(response.body);

    if(response.statusCode == 200 || response.statusCode == 201){
      scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: eventajaGreenTeal,
        content: Text('Feedback submited, thank you', style: TextStyle(color: Colors.white),),
        duration: Duration(seconds: 3),
      ));
      Future.delayed(Duration(seconds: 3), (){
        Navigator.pop(context);
      });
    }
    else{
      scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(extractedData['desc'], style: TextStyle(color: Colors.white),),
        duration: Duration(seconds: 3),
      ));
    }

  }
}

