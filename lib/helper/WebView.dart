import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewTest extends StatefulWidget {
  final mediaID;

  const WebViewTest({Key key, this.mediaID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WebViewTestState();
  }
}

class WebViewTestState extends State<WebViewTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: WebView(
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'https://media.eventevent.com/medias/${widget.mediaID}',
        ),
      ),
    );
  }
}
