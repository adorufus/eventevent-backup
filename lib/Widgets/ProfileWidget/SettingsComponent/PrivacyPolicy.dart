import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicy extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    
    return PrivacyPolicyState();
  }
}

class PrivacyPolicyState extends State<PrivacyPolicy>{
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);

    bool isLoading = false;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: eventajaGreenTeal,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white,),
        ),
        centerTitle: true,
        actions: <Widget>[
          Padding(
          padding: EdgeInsets.only(right: 13),
          child: isLoading == true ? CupertinoActivityIndicator(animating: true,radius: 15,) : Container())
        ],
        title: Text('PRIVACY POLICY', style: TextStyle(color: Colors.white),),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: 'https://eventevent.com/privacy-policy',
              onPageStarted: (val){
                print('loading page: ' + val);
                setState((){
                  isLoading = true;
                });
              },
              onPageFinished: (val){
                setState((){
                  isLoading = false;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}