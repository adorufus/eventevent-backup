import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTicketItem extends StatefulWidget {
  final String image;
  final title;
  final ticketName;
  final ticketCode;
  final timeStart;
  final timeEnd;
  final ticketType;
  final ticketStatus;
  final ticketImage;
  final DateTime date;
  final Color ticketColor;

  const MyTicketItem(
      {Key key,
      this.image,
      this.title,
      this.ticketCode,
      this.timeStart,
      this.timeEnd,
      this.ticketType,
      this.ticketStatus, this.ticketName, this.ticketColor, this.date, this.ticketImage})
      : super(key: key);

  @override
  _MyTicketItemState createState() => _MyTicketItemState();
}

class _MyTicketItemState extends State<MyTicketItem> {

  @override
  void initState() {
    print("image: " + widget.image);
    super.initState();
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
      margin: EdgeInsets.only(left: 13, right: 13, top: 13),
      height: ScreenUtil.instance.setWidth(150.18),
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 1,
                      child: Container(
              width: ScreenUtil.instance.setWidth(100.19),
              decoration: BoxDecoration(
                image:
                    DecorationImage(image: widget.image == '' || widget.image == 'assets/grey-fade.jpg' || widget.image.toString() == "false" || widget.image == null ? AssetImage('assets/grey-fade.jpg') : NetworkImage(widget.image), fit: BoxFit.fill),
                color: Color(0xFFB5B5B5),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Flexible(
            flex: 3,
                      child: Container(
              padding: EdgeInsets.only(left: 13, top: 5, right: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // MiniDate(
                  //   date: date,
                  // ),
                  SizedBox(height: ScreenUtil.instance.setWidth(5)),
                  Flexible(
                    flex: 1,
                                      child: Container(
                      width: 500,
                      child: Text(
                        widget.ticketName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil.instance.setSp(14),
                            color: Color(0xFF8A8A8B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                                      child: Container(
                      width: 500,
                      // height: ScreenUtil.instance.setWidth(18),
                      child: Text(
                        widget.ticketCode,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(20)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                  ),
                  // Row(
                  //   children: <Widget>[
                  //     Text(
                  //       timeStart + ' - ',
                  //       style:
                  //           TextStyle(fontSize: ScreenUtil.instance.setSp(10), color: Color(0xFF8A8A8B)),
                  //       maxLines: 1,
                  //       overflow: TextOverflow.ellipsis,
                  //       textWidthBasis: TextWidthBasis.parent,
                  //     ),
                  //     Text(
                  //       timeStart,
                  //       style:
                  //           TextStyle(fontSize: ScreenUtil.instance.setSp(10), color: Color(0xFF8A8A8B)),
                  //       maxLines: 1,
                  //       overflow: TextOverflow.ellipsis,
                  //       textWidthBasis: TextWidthBasis.parent,
                  //     ),
                  //   ],
                  // ),
                  Expanded(child: Container()),
                  Container(
                    height: ScreenUtil.instance.setWidth(32),
                    width: widget.ticketStatus == 'On Demand Video' ? ScreenUtil.instance.setWidth(140) : ScreenUtil.instance.setWidth(110),
                    decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: widget.ticketColor.withOpacity(0.4),
                              blurRadius: 2,
                              spreadRadius: 1.5)
                        ],
                        color: widget.ticketColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                        child: Text(
                      widget.ticketStatus.toString().toUpperCase(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil.instance.setSp(14),
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                  SizedBox(height: 25,)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
