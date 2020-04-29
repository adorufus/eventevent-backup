import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:page_indicator/page_indicator.dart';

class ScanQrTutorial extends StatefulWidget {
  @override
  _ScanQrTutorialState createState() => _ScanQrTutorialState();
}

class _ScanQrTutorialState extends State<ScanQrTutorial> {
  List imageList = [
    'assets/drawable/ic_tutorial_1.png',
    'assets/drawable/ic_tutorial_3.png',
  ];

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Text('HOW TO USE QR CODE', style: TextStyle(fontWeight: FontWeight.bold),),
            Text(
              currentPageIndex == 0
                  ? 'Show your QR code to attendee \n at event entrance gate'
                  : 'Your attendee name will appear after they scan your QR code',
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: PageIndicatorContainer(
                  align: IndicatorAlign.bottom,
                  indicatorColor: Colors.grey,
                  indicatorSelectorColor: eventajaGreenTeal,
                  length: imageList.length,
                  padding: EdgeInsets.all(5),
                  child: PageView(
                    onPageChanged: (index) {
                      currentPageIndex = index;
                      if (mounted) setState(() {});
                    },
                    children: imageList.map((values) {
                      return Image.asset(values);
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 14,
            ),
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                height: 45,
                width: 150,
                decoration: BoxDecoration(
                  color: eventajaGreenTeal,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: Center(child: Text(currentPageIndex == 0 ? 'Skip' : 'Done', style: TextStyle(color: Colors.white, fontSize: 18),),),
              ),
            ),
            SizedBox(
              height: 25,
            )
          ],
        ),
      ),
    );
  }
}
