import 'package:eventevent/Widgets/PostEvent/PostEvent.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ZoomDetailForm extends StatefulWidget {
  @override
  _ZoomDetailFormState createState() => _ZoomDetailFormState();
}

class _ZoomDetailFormState extends State<ZoomDetailForm> {
  TextEditingController zoomIdController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
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
            title: Text('Create Event'),
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
      body: Container(
        padding: EdgeInsets.only(left: 24, right: 24, top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Zoom Detail',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(height: 15),
            Text('Zoom ID'),
            SizedBox(height: 3),
            TextFormField(
              controller: zoomIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Example: 660 550 440',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(.3))
              ),
            ),
            SizedBox(height: 15),
            Text('Description'),
            SizedBox(height: 3),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                hintText: 'Example: Awasome zoom livestream',
                hintStyle: TextStyle(color: Colors.grey.withOpacity(.3))
              ),
            ),
            SizedBox(height: 20),
            Flexible(
              child: Center(
                heightFactor: 1,
                child: GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    if (zoomIdController.text != '') {
                      prefs.setString('zoom_id', zoomIdController.text);
                      prefs.setString('zoom_desc', descriptionController.text);
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PostEvent()),
                      );
                    } else {
                      Flushbar(
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                        flushbarPosition: FlushbarPosition.TOP,
                        animationDuration: Duration(milliseconds: 500),
                        message: 'Please insert your Zoom Id',
                      ).show(context);
                    }
                  },
                  child: Container(
                    height: 32,
                    width: 130,
                    decoration: BoxDecoration(
                        color: eventajaGreenTeal,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 2,
                              spreadRadius: 1.5,
                              color: eventajaGreenTeal.withOpacity(.5))
                        ]),
                    child: Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
