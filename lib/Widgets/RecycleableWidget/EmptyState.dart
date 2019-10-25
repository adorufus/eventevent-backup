import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final emptyImage;
  final reasonText;

  const EmptyState({Key key, this.emptyImage, this.reasonText}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
              height: 12,
            ),
            Text(
              reasonText,
              style: TextStyle(
                  color: Color(0xff8a8a8b),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ),
    );
  }
}
