import 'package:eventevent/Widgets/ManageEvent/PrivateEventList.dart';
import 'package:eventevent/Widgets/ManageEvent/PublicEventList.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EventList extends StatefulWidget{
  final type;

  const EventList({Key key, this.type}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    
    return EventListState();
  }
}

class EventListState extends State<EventList>{

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal, size: 20,),
            onTap: (){
              Navigator.pop(context);
            },
        ),
        title: Text('event ${widget.type}', style: TextStyle(color: eventajaGreenTeal),),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: Column(
            children: <Widget>[
              TabBar(
                labelColor: eventajaGreenTeal,
                labelStyle: TextStyle(color: eventajaGreenTeal),
                tabs: <Widget>[
                  Tab(text: 'PUBLIC',),
                  Tab(text: 'PRIVATE',)
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height /1.24,
                width: MediaQuery.of(context).size.width,
                child: TabBarView(
                  children: <Widget>[
                    PublicEventList(type: widget.type,),
                    PrivateEventList(type: widget.type,)
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}