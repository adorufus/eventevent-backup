import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniDate extends StatelessWidget {
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Container(
          padding: EdgeInsets.only(left: 5.5, right: 2, top: 1),
          width: ScreenUtil.instance.setWidth(27),
          height: ScreenUtil.instance.setWidth(27),
          decoration: BoxDecoration(
              color: eventajaGreenTeal,
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: eventajaGreenTeal.withOpacity(0.3),
                    blurRadius: 1.5,
                    spreadRadius: 1.5)
              ],
              borderRadius: BorderRadius.circular(5)),
          child: Align(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Text(
                    '08',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(12),
                        fontWeight: FontWeight.bold),
                        maxLines: 1,
                  ),
                  Text(
                    'sep',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.instance.setSp(9),
                    ),
                  ),
                ],
              )),
        );
  }
}