import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';

class ReportPost extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ReportPostState();
  }
}

class ReportPostState extends State<ReportPost>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
          onTap: (){
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text('Report', style: TextStyle(color: eventajaGreenTeal),),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Text('Report post'),
                Text('Why are you reporting this post?'),
              ],
            ),
          ),
          Container(
            child: Center(
              child: Text(
                'This post is inappropriate'
              ),
            ),
          ),
          Container(
            child: Center(
              child: Text(
                'This post is spam or scam'
              ),
            ),
          ),
          Container(
            child: Center(
              child: Text(
                'This post shouldn\'t be in EventEvent'
              ),
            ),
          ),
          Container(
            child: Center(
              child: Text(
                'Others'
              ),
            ),
          )
        ]
      ),
    );
  }
}