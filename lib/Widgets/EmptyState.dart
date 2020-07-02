import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final imagePath;
  final reasonText;
  final isTimeout;
  final previousWidget;
  final String buttonText;
  final Function refreshButtonCallback;

  const EmptyState(
      {Key key, this.imagePath, this.reasonText, this.isTimeout = false, this.previousWidget, this.refreshButtonCallback, this.buttonText = 'Refresh'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              imagePath,
              scale: 2,
            ),
            SizedBox(height: 20),
            Text(
              reasonText,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            isTimeout == false ? Container() : RaisedButton(
              child: Text(buttonText),
              onPressed: refreshButtonCallback,
            )
          ],
        ),
      ),
    );
  }
}
