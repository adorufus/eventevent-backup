import 'package:eventevent/Widgets/Home/MiniDate.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
              color: Color(0xFFFEC97C),
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
                  height: 18,
                  child: Text(
                    ticketCode,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                  ),
                ),
                Text(
                  quantity + 'x $ticketName'.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Color(0xFF8A8A8B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textWidthBasis: TextWidthBasis.parent,
                ),
                SizedBox(height: 5),
                Text(
                  'Last updated: $timeStart',
                  style: TextStyle(fontSize: 10, color: Color(0xFF8A8A8B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textWidthBasis: TextWidthBasis.parent,
                ),
                SizedBox(height: 5),
                Text(
                  'Rp. $price',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: eventajaGreenTeal),
                ),
                SizedBox(height: 15),
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
