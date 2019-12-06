import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniDate extends StatefulWidget {

  final DateTime date;

  const MiniDate({Key key, this.date}) : super(key: key);

  @override
  _MiniDateState createState() => _MiniDateState();
}

class _MiniDateState extends State<MiniDate> {

  String date = '';
  String month = '';

  @override
  void initState() {
    super.initState();

    print(widget.date.month.toString());
    print(DateTime.parse('2019-01-10').month.toString());

    setState(() {
      date = widget.date.day.toString();
      if(widget.date.month == 1){
        month = 'Jan';
      }else if(widget.date.month == 2){
        month = 'Feb';
      }else if(widget.date.month == 3){
        month = 'Mar';
      }else if(widget.date.month == 4){
        month = 'Apr';
      }else if(widget.date.month == 5){
        month = 'Mei';
      }else if(widget.date.month == 6){
        month = 'Jun';
      }else if(widget.date.month == 7){
        month = 'Jul';
      }else if(widget.date.month == 8){
        month = 'Aug';
      }else if(widget.date.month == 9){
        month = 'Sep';
      }else if(widget.date.month == 10){
        month = 'Oct';
      }else if(widget.date.month == 11){
        month = 'Nov';
      }else if(widget.date.month == 12){
        month = 'Dec';
      }
    });
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    
    return Container(
          padding: EdgeInsets.only(left: 2, right: 2, top: 1),
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
                    date,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(12),
                        fontWeight: FontWeight.bold),
                        maxLines: 1,
                  ),
                  Text(
                    month,
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