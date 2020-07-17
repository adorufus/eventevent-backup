import 'dart:async';
import 'dart:io';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewLivestream extends StatefulWidget {
  final url;

  const WebViewLivestream({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WebViewLivestreamState();
  }
}

class WebViewLivestreamState extends State<WebViewLivestream> {
  bool isLoading = false;
  String headerText = '';

  InAppWebViewController controller;
  ContextMenu contextMenu;
  double progress = 0;
  CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    contextMenu = ContextMenu(
      menuItems: [
        ContextMenuItem(androidId: 1, iosId: "1", title: "Special", action: () async {
          print("Menu item Special clicked!");
          print(await controller.getSelectedText());
          await controller.clearFocus();
        })
      ],
      options: ContextMenuOptions(
        hideDefaultSystemContextMenuItems: true
      ),
      onCreateContextMenu: (hitTestResult) async {
        print("onCreateContextMenu");
        print(hitTestResult.extra);
        print(await controller.getSelectedText());
      },
      onHideContextMenu: () {
        print("onHideContextMenu");
      },
      onContextMenuActionItemClicked: (contextMenuItemClicked) async {
        var id = (Platform.isAndroid) ? contextMenuItemClicked.androidId : contextMenuItemClicked.iosId;
        print("onContextMenuActionItemClicked: " + id.toString() + " " + contextMenuItemClicked.title);
      }
    );

    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
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
      backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          elevation: 0,
          backgroundColor: Colors.white,
          // title: Text(
          //   headerText,
          //   style: TextStyle(color: eventajaGreenTeal),
          // ),
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
          color: Colors.white,
          child: InAppWebView(
            contextMenu: contextMenu,
            initialUrl: widget.url,
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: false,
                cacheEnabled: false,
                clearCache: true,
                transparentBackground: false
              ),
            ),
            onWebViewCreated: (InAppWebViewController controller) {
              this.controller = controller;
            },
            onLoadStart: (InAppWebViewController controller, url) {
              this.headerText = url;
              if (mounted) setState(() {});
            },
            
            // shouldOverrideUrlLoading:
            //     (controller, shouldOverrideUrlLoadingRequest) async {
            //   var url = shouldOverrideUrlLoadingRequest.url;
            //   var uri = Uri.parse(url);

            //   if (![
            //     "http",
            //     "https",
            //     "file",
            //     "chrome",
            //     "data",
            //     "javascript",
            //     "about",
            //   ].contains(uri.scheme)) {
            //     if(await canLaunch(url)){
                  
            //     }
            //   }
            // },
            onLoadStop: (InAppWebViewController controller, String url) async {
                      print("onLoadStop $url");
                      setState(() {
                        this.headerText = url;
                      });
                    },
                    onProgressChanged: (InAppWebViewController controller, int progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    onUpdateVisitedHistory: (InAppWebViewController controller, String url, bool androidIsReload) {
                      print("onUpdateVisitedHistory $url");
                      setState(() {
                        this.headerText = url;
                      });
                    }
          ),
        ));
  }
}
