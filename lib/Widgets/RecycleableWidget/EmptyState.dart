import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyState extends StatelessWidget {
  final emptyImage;
  final reasonText;

  const EmptyState({Key key, this.emptyImage, this.reasonText}) : super(key: key);
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              emptyImage,
              scale: 2,
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(12),
            ),
            Text(
              reasonText,
              style: TextStyle(
                  color: Color(0xff8a8a8b),
                  fontSize: ScreenUtil.instance.setSp(18),
                  fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ),
    );
  }
}
