import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PostEventAdditionalMedia.dart';

class PostEventCreatorDetails extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PostEventCreatorDetailsState();
  }
}

class PostEventCreatorDetailsState extends State<PostEventCreatorDetails> {

  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();

  TextEditingController telephoneController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController websiteController = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();


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
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: eventajaGreenTeal,
            ),
          ),
          centerTitle: true,
          title: Text(
            'CREATE EVENT',
            style: TextStyle(color: eventajaGreenTeal),
          ),
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    saveAndNext();
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Additional Info',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(20),
                ),
                Divider(
                  color: Colors.grey,
                  height: ScreenUtil.instance.setWidth(5),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(15),
                ),
                Text('*Required', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18)),),
                SizedBox(height: ScreenUtil.instance.setWidth(20)),
                Center(
                  child: Text('Contact', style: TextStyle(color: eventajaGreenTeal, fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18)),),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: ScreenUtil.instance.setWidth(40), width: ScreenUtil.instance.setWidth(40), child: Image.asset('assets/icons/btn_phone_active.png'),),
                    Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 35),),
                    SizedBox(height: ScreenUtil.instance.setWidth(10),),
                    Text('Telephone', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.black54, fontWeight: FontWeight.bold),),
                    SizedBox(width: ScreenUtil.instance.setWidth(20),),
                    Container(
                      width: ScreenUtil.instance.setWidth(180),
                      height: ScreenUtil.instance.setWidth(35),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: telephoneController,
                        decoration: InputDecoration(
                            fillColor: Colors.grey.withOpacity(0.2),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(7)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(7)
                            )
                        ),),
                    )
                  ],
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(10),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: ScreenUtil.instance.setWidth(40), width: ScreenUtil.instance.setWidth(40), child: Image.asset('assets/icons/btn_mail_active.png'),),
                    SizedBox(width: ScreenUtil.instance.setWidth(24),),
                    Text('Email', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.black54, fontWeight: FontWeight.bold),),
                    SizedBox(width: ScreenUtil.instance.setWidth(52),),
                    Container(
                      width: ScreenUtil.instance.setWidth(180),
                      height: ScreenUtil.instance.setWidth(35),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                            fillColor: Colors.grey.withOpacity(0.2),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(7)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(7)
                            )
                        ),),
                    )
                  ],
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(10),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: ScreenUtil.instance.setWidth(40), width: ScreenUtil.instance.setWidth(40), child: Image.asset('assets/icons/btn_web_active.png'),),
                    SizedBox(width: ScreenUtil.instance.setWidth(9),),
                    Text('Website', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15), color: Colors.black54, fontWeight: FontWeight.bold),),
                    SizedBox(width: ScreenUtil.instance.setWidth(52),),
                    Container(
                      width: ScreenUtil.instance.setWidth(180),
                      height: ScreenUtil.instance.setWidth(35),
                      child: TextFormField(
                        controller: websiteController,
                        decoration: InputDecoration(
                            fillColor: Colors.grey.withOpacity(0.2),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(7)
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(7)
                            )
                        ),),
                    )
                  ],
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(20),),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Description', style: TextStyle(color: eventajaGreenTeal, fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18))),
                      Text('*', style: TextStyle(color: Colors.red, fontSize: ScreenUtil.instance.setSp(17), fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    fillColor: Colors.grey.withOpacity(0.3),
                    filled: true,
                    hintText: 'Type your event description here',
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(7),
                    ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(7),
                      )
                  ),
                )    
              ]),
            )));
  }

  saveAndNext() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(telephoneController.text == null || telephoneController.text == ''){
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Phone cannot be empty!',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }
    else if(descriptionController.text == null || descriptionController.text == ''){
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: 'Description cannot be empty',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }
    else{
      prefs.setString('CREATE_EVENT_TELEPHONE', telephoneController.text);
      prefs.setString('CREATE_EVENT_EMAIL', emailController.text);
      prefs.setString('CREATE_EVENT_WEBSITE', websiteController.text);
      prefs.setString('CREATE_EVENT_DESCRIPTION', descriptionController.text);
      Navigator.push(context, CupertinoPageRoute(builder: (BuildContext context) => PostEventAdditionalMedia()));
    }
  }
}
