import 'package:eventevent/Widgets/PostEvent/CreateTicketDescription.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTicketOnePurchase extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CreateTicketOnePurchaseState();
  }
}

class CreateTicketOnePurchaseState extends State<CreateTicketOnePurchase> {
  var textController = new TextEditingController();
  var thisScaffold = new GlobalKey<ScaffoldState>();

  int __curValue = 0;

  bool isLivestream = false;

  void checkIfTicketLivestream() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    if(preferences.getBool('isLivestream') == true){
      isLivestream = true;
      __curValue = 1;
    }

    setState(() {

    });
  }

  @override
  void initState() {
    checkIfTicketLivestream();
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
        key: thisScaffold,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0,
          // leading: GestureDetector(
          //   onTap: (){
          //     Navigator.popUntil(context, ModalRoute.withName('/Dashboard'));
          //   },
          //   child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
          // ),
          centerTitle: true,
          title: Text(
            'CREATE TICKET',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    navigateToNextStep();
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
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, top: 15),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'One Purchase Per User',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: ScreenUtil.instance.setSp(25),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(20),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Divider(
                  color: Colors.grey,
                  height: ScreenUtil.instance.setWidth(10),
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(50),
              ),
              Image.asset('assets/drawable/single_ticket_purchase.png', scale: 4, colorBlendMode: BlendMode.dstIn, color: Colors.white.withOpacity(.5)),
              SizedBox(
                height: ScreenUtil.instance.setWidth(12),
              ),
              Container(
                width: 300,
                child: Text('Do you want to limit one purchase per user for your event?', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),)),
              SizedBox(
                height: ScreenUtil.instance.setWidth(30),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 29, left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      groupValue: __curValue,
                      onChanged: (int i) => setState(() => __curValue = i),
                      value: 1,
                    ),
                    Text('Yes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),),
                    SizedBox(
                        width: ScreenUtil.instance.setWidth(80),
                      ),
                    Radio(
                      groupValue: __curValue,
                      onChanged: isLivestream == true ? null : (int i) => setState((){
                        __curValue = i;
                        print(MaterialTapTargetSize.values);
                      }),
                      value: 0,
                    ),
                    Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26))
                  ],
                )
              )
            ],
          ),
        ));
  }

  navigateToNextStep() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (__curValue == null) {
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Choose at least one option',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    } else {
      prefs.setString('SETUP_TICKET_IS_ONE_PURCHASE', __curValue.toString());
      print(prefs.getString('SETUP_TICKET_IS_ONE_PURCHASE'));
      Navigator.push(context,
          CupertinoPageRoute(builder: (BuildContext context) => CreateTicketDescription()));
    }
  }
}