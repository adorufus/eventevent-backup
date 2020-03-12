import 'dart:async';
import 'dart:convert';

import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView3DS extends StatefulWidget {
  final url;

  const WebView3DS({Key key, this.url}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WebView3DSState();
  }
}

class WebView3DSState extends State<WebView3DS> {
  bool isLoading = false;
  String headerText = '';
  Completer<WebViewController> _controller = Completer<WebViewController>();
  String kNavigationExamplePage;
  String contentBase64;
  String jsContent;

  @override
  void initState() {
    kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Acquiring 3DS..</title>
<script type='text/javascript'>
var MidtransNew3ds=function(){const t={production:"https://api.midtrans.com",sandbox:"https://api.sandbox.midtrans.com",staging:"https://api.stg.veritrans.co.id"};var n={},e={},a={},r="",i="";function s(t){var n="?",e=encodeURIComponent;for(var a in t)t.hasOwnProperty(a)&&(n+=e(a)+"="+e(t[a])+"&");return n}function c(t){var n=document.createElement("script");n.src=t,document.getElementsByTagName("head")[0].appendChild(n)}function o(n,e){var a=document.getElementById("midtrans-script");""===n?a.getAttribute("data-environment")&&(r=t[a.getAttribute("data-environment").toLowerCase()]+e):r=n,r||(r=t.production+e,console.log("Environment on `data-environment` is not found, set to production"))}function d(t){var n=document.getElementById("midtrans-script");""!==(i=""===t?n.getAttribute("data-client-key"):t)&&null!==i||console.log('Please add `data-client-key` attribute in the script tag <script id="midtrans-script" type="text/javascript" src="...midtrans-new-3ds.min.js" data-client-key="CLIENT-KEY"><\/script>')}function l(t){var n=t.origin||t.originalEvent.origin;t.data&&t.data.status_code&&t.data.status_message&&n&&n.match(/https?:\/\/[\w\.]+(veritrans|midtrans)\./)&&MidtransNew3ds.callback(t.data)}return{version:"1.2",clientKey:"",url:"",callback:function(t){t&&"200"==t.status_code?n.onSuccess&&n.onSuccess(t):t&&"201"==t.status_code?n.onPending&&n.onPending(t):n.onFailure&&n.onFailure(t)},authenticate:function(t,e){window.addEventListener?window.addEventListener("message",l,!1):window.attachEvent("onmessage",l),n=e,e.performAuthentication&&e.performAuthentication(t)},getCardToken:function(t,a){n=a,(e=t).callback="MidtransNew3ds.callback",o(MidtransNew3ds.url,"/v2/token"),d(MidtransNew3ds.clientKey),e.client_key=i,c(r+s(e))},redirect:function(t,n){url=t,queryParams={},queryParams.callback_type="form",n.callbackUrl&&(queryParams.callback_url=n.callbackUrl),url+=s(queryParams),location.href=url},registerCard:function(t,e){n=e,(a=t).callback="MidtransNew3ds.callback",o(MidtransNew3ds.url,"/v2/card/register"),d(MidtransNew3ds.clientKey),a.client_key=i,c(r+s(a))}}}();

var redirect_url = '${widget.url}';

// callback functions
var options = {
  performAuthentication: function(redirect_url){
    // Implement how you will open iframe to display 3ds authentication redirect_url to customer
    popupModal.openPopup(redirect_url);
  },
  onSuccess: function(response){
    // 3ds authentication success, implement payment success scenario
    console.log('response:',response);
    popupModal.closePopup();
  },
  onFailure: function(response){
    // 3ds authentication failure, implement payment failure scenario
    console.log('response:',response);
    popupModal.closePopup();
  },
  onPending: function(response){
    // transaction is pending, transaction result will be notified later via POST notification, implement as you wish here
    console.log('response:',response);
    popupModal.closePopup();
  }
};

// trigger `authenticate` function
MidtransNew3ds.authenticate(redirect_url, options);
</script>
</head>
<body>
<center><p>
Please wait.
</p></center>
</body>
</html>
''';
    contentBase64 =
        base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
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
          onWebViewCreated: (WebViewController controller) {
            _controller.complete(controller);
            controller.evaluateJavascript(jsContent);

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
}
