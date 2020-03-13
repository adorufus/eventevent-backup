import 'dart:async';
import 'dart:convert';

import 'package:eventevent/Widgets/TransactionHistory.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebView3DS extends StatefulWidget {
  final url;
  final transaction_id;

  const WebView3DS({Key key, this.url, this.transaction_id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WebView3DSState();
  }
}

class WebView3DSState extends State<WebView3DS> {
  bool isLoading = false;
  String headerText = '';
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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
      appBar: AppBar(
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
                          selectedPage: 3,
                        )),
                ModalRoute.withName('/EventDetails'));
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TransactionHistory()));
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
              if (headerText.startsWith(
                  'https://api.veritrans.co.id/v2/token/rba/callback')) {
                getTransactStatus().then((response) {
                  var extractedData = json.decode(response.body);

                  if (response.statusCode == 200) {
                    if (extractedData['channel_response_code'] == '0') {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardWidget(
                                    isRest: false,
                                    selectedPage: 3,
                                  )),
                          ModalRoute.withName('/EventDetails'));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TransactionHistory()));
                    } else {
                      if (extractedData['transaction_status'] == 'deny' &&
                          extractedData['fraud_status'] == "deny") {
                        Navigator.pop(context,
                            "[fraud card] Card denied by system, please try another card");
                      } else {
                        Navigator.pop(
                            context, extractedData['channel_response_message']);
                      }
                    }
                  } else {
                    print(extractedData);
                  }
                });
              }
              isLoading = true;
            });
          },
          onPageFinished: (val) {
            setState(() {
              isLoading = false;
            });
          },
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
            });
          },
        ),
      ),
    );
  }

  Future<http.Response> getTransactStatus() async {
    String baseApi =
        BaseApi.midtransUrlProd + 'v2/${widget.transaction_id}/status';

    final response = await http.get(baseApi, headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Basic VlQtc2VydmVyLUlUcXdsRml1NjZ5V0ktdHZJci1UZDdiUzo='
    });

    print(response.statusCode);
    print(response.body);

    return response;
  }
}
