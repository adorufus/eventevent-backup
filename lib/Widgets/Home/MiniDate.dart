import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';

class MiniDate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          padding: EdgeInsets.only(left: 5.5, right: 5.5, top: 2),
          width: 27,
          height: 27,
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'sep',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                    ),
                  ),
                ],
              )),
        );
  }
}