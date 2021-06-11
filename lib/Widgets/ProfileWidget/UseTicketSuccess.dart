import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';

class UseTicketSuccess extends StatefulWidget {
  final eventName;

  const UseTicketSuccess({Key key, this.eventName}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return UseTicketSuccessState();
  }
}

class UseTicketSuccessState extends State<UseTicketSuccess> {
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      backgroundColor: checkForBackgroundColor(context),
      
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: ScreenUtil.instance.setWidth(250),
              width: ScreenUtil.instance.setWidth(250),
              child: Image.asset('assets/drawable/success.png'),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20),
            ),
            Text('Congratulation', style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18), fontWeight: FontWeight.bold),),
            SizedBox(
              height: ScreenUtil.instance.setWidth(15),
            ),
            Text('YOU ARE CHECKED IN TO ${widget.eventName}', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20),
            ),
            GestureDetector(
              onTap: (){
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
                  builder: ( BuildContext context) => ProfileWidget(initialIndex: 0,)
                ), ModalRoute.withName('/Dashboard'));
              },
              child: Container(
                height: ScreenUtil.instance.setWidth(50),
                width: ScreenUtil.instance.setWidth(300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: eventajaGreenTeal,
                ),
                child: Center(
                  child: Text('OK', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.instance.setSp(18)),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
