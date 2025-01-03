import 'package:eventevent/Widgets/ManageEvent/EventDetailLoadingScreen.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/utils.dart';
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
  Utils utility = Utils();

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: ScreenUtil.instance.setWidth(200),
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
              onTap: () async {
                SharedPreferences preferences = await SharedPreferences.getInstance();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardWidget(isRest: false, selectedPage: 4, userId: preferences.getString('Last User ID'),)), ModalRoute.withName('/Dashboard'));
                Navigator.push(context, MaterialPageRoute(builder: (context) => EventDetailLoadingScreen(eventId: newEventId)));
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