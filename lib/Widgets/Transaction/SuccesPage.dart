import 'package:eventevent/Widgets/profileWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SuccessPageState();
  }
}

class SuccessPageState extends State<SuccessPage> {

  String currentUserId = '';
  
  currentUserData() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      currentUserId = preferences.getString('Last User ID');
    });
  }

  @override
  void initState() {
    currentUserData();
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
      backgroundColor: Colors.white.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Icon(Icons.close, size: 35, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text('PAYMENT SUCCESS', style: TextStyle(color: eventajaGreenTeal)),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: ScreenUtil.instance.setWidth(200),
              width: ScreenUtil.instance.setWidth(200),
              child: Image.asset('assets/drawable/success.png'),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20),
            ),
            Text('INV/XXXX/XXX/XXXX/XXX', style: TextStyle(color: eventajaGreenTeal, fontSize: ScreenUtil.instance.setSp(18), fontWeight: FontWeight.bold),),
            SizedBox(
              height: ScreenUtil.instance.setWidth(15),
            ),
            Text('PAYMENT SUCCESS', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20),
            ),
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: ( BuildContext context) => ProfileWidget(initialIndex: 1, userId: currentUserId,)
                ));
              },
              child: Container(
                height: ScreenUtil.instance.setWidth(50),
                width: ScreenUtil.instance.setWidth(300),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: eventajaGreenTeal,
                ),
                child: Center(
                  child: Text('VIEW MY TICKETS', style: TextStyle(color: Colors.white, fontSize: ScreenUtil.instance.setSp(18)),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
