import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eventevent/helper/colorsManagement.dart';

class ZoomTicketPage extends StatefulWidget {
  final zoomLink;
  final zoomDesc;

  const ZoomTicketPage({Key key, this.zoomLink, this.zoomDesc})
      : super(key: key);
  @override
  _ZoomTicketPageState createState() => _ZoomTicketPageState();
}

class _ZoomTicketPageState extends State<ZoomTicketPage> {

  void launchZoomPage(url) async {
    if(await canLaunch(url)){
      launch(url);
    } else {
      throw 'cannot open the url';
    }
  }

  String formattedId = "";

  @override
  void initState(){
    formattedId = widget.zoomLink.toString().replaceAll(" ", "");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: checkForBackgroundColor(context),
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: ScreenUtil.instance.setWidth(50),
            padding: EdgeInsets.symmetric(horizontal: 13),
            color: Colors.white,
            child: AppBar(
              brightness: Brightness.light,
              elevation: 0,
              backgroundColor: appBarColor,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/icons/icon_apps/arrow.png',
                  scale: 5.5,
                  alignment: Alignment.centerLeft,
                ),
              ),
              title: Text('Zoom Details'),
              centerTitle: true,
              textTheme: TextTheme(
                title: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil.instance.setSp(14),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/icons/aset_icon/zoom_livestream.png',
                scale: 2,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Zoom ID: ',
                    style: TextStyle(fontSize: 15),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      
                      launchZoomPage('https://zoom.us/j/$formattedId');
                      // try {
                      //   launch('https://zoom.us/j/' + widget.zoomLink, forceSafariVC: true);
                      // } catch (e){
                      //   throw 'error' + e.toString();
                      // }
                    },
                    child: Text(
                      '${widget.zoomLink}',
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                  ),
                  SizedBox(width: 5),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: (){
                      Clipboard.setData(ClipboardData(text: 'https://zoom.us/j/$formattedId'));
                      print(Clipboard.getData('text/plain'));
                      Flushbar(
                        flushbarPosition: FlushbarPosition.TOP,
                        message: 'Zoom URL Coppied!',
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                        animationDuration: Duration(milliseconds: 500),
                      )..show(context);
                    },
                    child: Icon(Icons.content_copy, size: 14))
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Zoom Description: ',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Text(
                        '${widget.zoomDesc}',
                        style: TextStyle(fontSize: 15),
                      
              ),
            ],
          ),
        ),
      ),
    );
  }
}
