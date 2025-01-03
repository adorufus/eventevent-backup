import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';

class TransactionHistoryItem extends StatelessWidget {
  final image;
  final ticketName;
  final ticketCode;
  final timeStart;
  final timeEnd;
  final quantity;
  final ticketType;
  final ticketStatus;
  final price;
  final Color ticketColor;

  const TransactionHistoryItem(
      {Key key,
      this.image,
      this.ticketCode,
      this.timeStart,
      this.timeEnd,
      this.ticketType,
      this.ticketStatus,
      this.ticketName,
      this.ticketColor,
      this.quantity,
      this.price})
      : super(key: key);

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Container(
      margin: EdgeInsets.only(left: 13, right: 13, top: 13),
      height: ScreenUtil.instance.setWidth(150.18),
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil.instance.setWidth(100.19),
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: image == null || image == '' ? AssetImage('assets/grey-fade.jpg') : NetworkImage(image), fit: BoxFit.fill),
              color: Color(0xFF8a8a8b),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 19.35, top: 15.66, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width - 146,
                  height: ScreenUtil.instance.setWidth(18),
                  child: Text(
                    ticketCode,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(15)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                ),
                Text(
                  quantity + 'x $ticketName'.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.instance.setSp(10),
                      color: Color(0xFF8A8A8B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textWidthBasis: TextWidthBasis.parent,
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(5)),
                Text(
                  'Last updated: $timeStart',
                  style: TextStyle(fontSize: ScreenUtil.instance.setSp(10), color: Color(0xFF8A8A8B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textWidthBasis: TextWidthBasis.parent,
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(5)),
                Text(
                  '$price',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: eventajaGreenTeal),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(15)),
                Container(
                  height: ScreenUtil.instance.setWidth(32),
                  width: ScreenUtil.instance.setWidth(110),
                  decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: ticketColor.withOpacity(0.4),
                            blurRadius: 2,
                            spreadRadius: 1.5)
                      ],
                      color: ticketColor,
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                      child: Text(
                    ticketStatus.toString().toUpperCase(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(10),
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
