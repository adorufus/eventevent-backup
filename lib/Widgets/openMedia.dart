import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OpenMedia extends StatefulWidget {
  final articleID;
  final url;

  const OpenMedia({Key key, this.articleID, this.url}) : super(key: key);
  @override
  _OpenMediaState createState() => _OpenMediaState();
}

class _OpenMediaState extends State<OpenMedia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 75,
          padding: EdgeInsets.symmetric(horizontal: 13),
          color: Colors.white,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
                          child: Image.asset(
                'assets/icons/icon_apps/arrow.png',
                scale: 5.5,
                alignment: Alignment.centerLeft,
              ),
            ),
            title: Text('eMedia'),
            centerTitle: true,
            
            textTheme: TextTheme(title: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            )),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: WebView(
              javascriptMode: JavascriptMode.unrestricted,
              initialUrl: widget.url
            ),
          )
        ],
      ),
    );
  }
}