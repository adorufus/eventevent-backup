import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: eventajaGreenTeal,
        leading: GestureDetector(
          onTap: (){
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardWidget()), ModalRoute.withName('/Dashboard'));
          },
          child: Icon(Icons.close, color: Colors.white,),
        ),
      ),
      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: widget.url,
        ),
      ),
    );
  }
}
