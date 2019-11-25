import 'package:eventevent/Widgets/eventDetailsWidget.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinishPostEvent extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    
    return FinishPostEventState();
  }
}

class FinishPostEventState extends State<FinishPostEvent>{
  String newEventId;

  @override
  void initState() {
    
    super.initState();
    getData();
  }
  
  getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      newEventId = prefs.getInt('NEW_EVENT_ID').toString();
    });
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: ScreenUtil.instance.setWidth(450),
              width: MediaQuery.of(context).size.width,
              child: Image.asset('assets/icons/Icon_finish_create_event.png')
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20)
            ),
            Text('Congratulation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18)),),
            Text('Your event is live now'),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20)
            ),
            GestureDetector(
              onTap: (){
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => EventDetailsConstructView(id: newEventId,)), ModalRoute.withName('/PostEvent'));
              },
              child: SizedBox(
                height: ScreenUtil.instance.setWidth(50), 
                width: ScreenUtil.instance.setWidth(200), 
                child: Image.asset('assets/icons/btn_ok.png'
              )
            )
          ),],
        )
      ),
    );
  }
}