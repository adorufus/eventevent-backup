import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final imagePath;
  final reasonText;

  const EmptyState({Key key, this.imagePath, this.reasonText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(imagePath, scale: 1.5,),
            Text(reasonText, style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),)
          ],
        ),
      ),
    );
  }
}
