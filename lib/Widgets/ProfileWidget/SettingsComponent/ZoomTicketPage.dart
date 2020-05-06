import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZoomTicketPage extends StatefulWidget {
  final zoomLink;
  final zoomDesc;

  const ZoomTicketPage({Key key, this.zoomLink, this.zoomDesc})
      : super(key: key);
  @override
  _ZoomTicketPageState createState() => _ZoomTicketPageState();
}

class _ZoomTicketPageState extends State<ZoomTicketPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              backgroundColor: Colors.white,
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
            children: <Widget>[
              Image.asset('assets/icons/aset_icon/zoom_livestream.png', scale: 2
                ,),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Zoom ID: ', style: TextStyle(fontSize: 15),),
                  GestureDetector(
                    onTap: () {
                      launch('https://zoom.us/j/' + widget.zoomLink, enableJavaScript: true);
                    },
                    child: Text(
                      '${widget.zoomLink}',
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Zoom Description: ', style: TextStyle(fontSize: 15),),
                  Text('${widget.zoomDesc}', style: TextStyle(fontSize: 15),),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
