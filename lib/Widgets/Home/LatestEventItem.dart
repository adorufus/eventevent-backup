import 'package:eventevent/Widgets/Home/MiniDate.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'PopularEventWidget.dart';

class LatestEventItem extends StatelessWidget {
  final image;
  final title;
  final username;
  final location;
  final Color itemColor;
  final String itemPrice;
  final type;
  final isAvailable;
  final DateTime date;
  final isHybridEvent;

  const LatestEventItem(
      {Key key,
      this.image,
      this.title,
      this.username,
      this.location,
      this.itemColor,
      this.itemPrice,
      this.type,
      this.isAvailable,
      this.date,
      this.isHybridEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    // print(MediaQuery.of(context).size.width);
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
                  DecorationImage(image: NetworkImage(image), fit: BoxFit.fill),
              color: Color(0xFFB5B5B5),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Expanded(child: Container()),
          Container(
            padding: EdgeInsets.only(top: 15.66, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // MiniDate(
                //   date: date,
                // ),
                // Expanded(
                //   child: SizedBox(),
                // ),
                Container(
                  width: 300 - 76.0,
                  // height: ScreenUtil.instance.setWidth(20),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(20)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                ),
                isHybridEvent == 'streamOnly'
                    ? Container() : SizedBox(
                  height: 6,
                ),

                isHybridEvent == 'streamOnly'
                    ? Container() : Container(
                  height: ScreenUtil.instance.setWidth(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: ScreenUtil.instance.setWidth(10),
                        width: ScreenUtil.instance.setWidth(10),
                        child:
                            Image.asset('assets/icons/icon_apps/location.png'),
                      ),
                      SizedBox(width: ScreenUtil.instance.setWidth(3)),
                      Container(
                          width: ScreenUtil.instance.setWidth(200 - 20.37),
                          child: Text(
                            location,
                            style: TextStyle(
                                color: Color(0xFF8A8A8B), fontSize: 8),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                isHybridEvent == 'streamOnly'
                    ? Image.asset(
                        'assets/icons/icon_apps/LivestreamTagIcon.png',
                        scale: 25)
                    : Container(),
                // Expanded(
                //   child: SizedBox(),
                // ),
                // Row(
                //   children: <Widget>[
                //     type == 'paid' ||
                //             type == 'paid_seating' ||
                //             type == 'free_limited' ||
                //             type == 'free_limited_seating'
                //         ? isAvailable == '1'
                //             ? Icon(
                //                 CupertinoIcons.circle_filled,
                //                 color: eventajaGreenTeal,
                //                 size: 12,
                //               )
                //             : Icon(
                //                 CupertinoIcons.circle_filled,
                //                 color: itemPrice == 'sales_ended' ||
                //                         itemPrice == 'COMING SOON'
                //                     ? Colors.yellowAccent
                //                     : Colors.red,
                //                 size: 12,
                //               )
                //         : Container(),
                //     type == 'paid' ||
                //             type == 'paid_seating' ||
                //             type == 'free_limited' ||
                //             type == 'free_limited_seating'
                //         ? isAvailable == '1'
                //             ? Text(
                //                 'Available',
                //                 style: TextStyle(
                //                     fontSize: ScreenUtil.instance.setSp(10)),
                //               )
                //             : Text(
                //                 itemPrice,
                //                 style: TextStyle(
                //                     fontSize: ScreenUtil.instance.setSp(10)),
                //               )
                //         : Container(),
                //   ],
                // ),
                Expanded(
                  child: SizedBox(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  height: ScreenUtil.instance.setWidth(32 * 1.1),
                  width: ScreenUtil.instance.setWidth(110 * 1.1),
                  decoration: BoxDecoration(boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: itemColor.withOpacity(0.4),
                        blurRadius: 2,
                        spreadRadius: 1.5)
                  ], color: itemColor, borderRadius: BorderRadius.circular(30)),
                  child: Center(
                      child: Text(
                    itemPrice.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(itemPrice == "FREE LIVE STREAM" ? 10 : 16),
                        fontWeight: FontWeight.bold),
                  )),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
          SizedBox(
            width: 30,
          )
        ],
      ),
    );
  }
}
