import 'package:eventevent/Widgets/ManageEvent/PrivateEventList.dart';
import 'package:eventevent/Widgets/ManageEvent/PublicEventList.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventList extends StatefulWidget{
  final type;
  final userId;
  final isRest;

  const EventList({Key key, this.type, this.userId, this.isRest}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    
    return EventListState();
  }
}

class EventListState extends State<EventList>{

  String currentUserId = '';

  getUserDetail() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState((){
      currentUserId = preferences.getString('Last User ID');
    });
  }

  @override
  void initState() {
    getUserDetail();
    super.initState();
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
        brightness: Brightness.light,
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
        child: widget.userId == currentUserId ? DefaultTabController(
          length: 2,
          initialIndex: 0,
          child: ListView(
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
                    PublicEventList(
                      isRest: widget.isRest,
                      userId: widget.userId,
                      type: widget.type,
                    ),
                    PrivateEventList(
                      userId: widget.userId,
                      type: widget.type,)
                  ],
                ),
              )
            ],
          ),
        ) : PublicEventList(type: widget.type, userId: widget.userId, isRest: widget.isRest,)
      ),
    );
  }
}