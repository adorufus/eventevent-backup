import 'package:eventevent/Widgets/Home/MiniDate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyTicketItem extends StatelessWidget {
  final image;
  final title;
  final ticketName;
  final ticketCode;
  final timeStart;
  final timeEnd;
  final ticketType;
  final ticketStatus;
  final Color ticketColor;

  const MyTicketItem(
      {Key key,
      this.image,
      this.title,
      this.ticketCode,
      this.timeStart,
      this.timeEnd,
      this.ticketType,
      this.ticketStatus, this.ticketName, this.ticketColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 13, right: 13, top: 13),
      height: 150.18,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            spreadRadius: 1.5)
      ], color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: <Widget>[
          Container(
            width: 100.19,
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: NetworkImage(image), fit: BoxFit.fill),
              color: Color(0xFFB5B5B5),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 19.35, top: 15.66, right: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MiniDate(),
                SizedBox(height: 5),
                Container(
                  width: MediaQuery.of(context).size.width - 146,
                  child: Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFF8A8A8B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 146,
                  height: 18,
                  child: Text(
                    ticketCode,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      timeStart + ' - ',
                      style:
                          TextStyle(fontSize: 10, color: Color(0xFF8A8A8B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                    Text(
                      timeStart,
                      style:
                          TextStyle(fontSize: 10, color: Color(0xFF8A8A8B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(
                    ticketName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                SizedBox(height: 5),
                Container(
                  height: 28,
                  width: 133,
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
                        fontSize: 10,
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
