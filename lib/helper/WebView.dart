import 'dart:async';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewTest extends StatefulWidget {
  final url;

  const WebViewTest({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WebViewTestState();
  }
}

class WebViewTestState extends State<WebViewTest> {
  bool isLoading = false;
  String headerText = '';
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      backgroundColor: checkForBackgroundColor(context),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text(
          headerText,
          style: TextStyle(color: eventajaGreenTeal),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 13),
            child: isLoading == true
                ? Theme(
                    data: ThemeData(
                        cupertinoOverrideTheme:
                            CupertinoThemeData(brightness: Brightness.dark)),
                    child: CupertinoActivityIndicator(
                      animating: true,
                      radius: 7,
                    ))
                : Container(),
          )
        ],
        leading: GestureDetector(
          onTap: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardWidget(
                          isRest: false,
                        )),
                ModalRoute.withName('/Dashboard'));
          },
          child: Icon(
            Icons.close,
            color: eventajaGreenTeal,
          ),
        ),
      ),
      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.url,
          onPageStarted: (val) {
            print(val);

            setState(() {
              headerText = val;
              isLoading = true;
            });
          },
          onPageFinished: (val) {
            setState(() {
              isLoading = false;
            });
          },
          // gestureRecognizers: <OneSequenceGestureRecognizer>[].toSet(),
          javascriptChannels: <JavascriptChannel>[].toSet(),
          onWebViewCreated: (WebViewController controller) {
            _controller.complete(controller);

            setState(() {
              isLoading = false;
              controller.getTitle().then((value) {
                setState(() {
                  headerText = value;
                });
              });
              print(controller.currentUrl());
              _controller.future.then((val){
                print(val);
              });
            });
          },
        ),
      ),
    );
  }
}
