import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';

class LoveItem extends StatefulWidget {
  final isComment;

  const LoveItem({Key key, this.isComment}) : super(key: key);

  @override
  _LoveItemState createState() => _LoveItemState();
}

class _LoveItemState extends State<LoveItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13),
      height: 30,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                spreadRadius: 1.5)
          ]),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Image.asset(
          widget.isComment == false ? 'assets/icons/icon_apps/love.png' : 'assets/icons/icon_apps/comment.png',
          color: widget.isComment == false ? Colors.red : eventajaGreenTeal,
          scale: 3.5,
        ),
        SizedBox(width: 5),
        Text('99+',
            style: TextStyle(
                color: Color(
                    0xFF8A8A8B))) //timelineList[i]['impression']['data'] == null ? '0' : timelineList[i]['impression']['data']
      ]),
    );
  }
}
