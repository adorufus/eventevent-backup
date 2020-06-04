import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'PopularWidget.dart';

class PopularItem extends StatefulWidget {
  @override
  _PopularItemState createState() => _PopularItemState();
}

class _PopularItemState extends State<PopularItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, i){
          return PopularWidget(
           itemColor: eventajaGreenTeal,
           itemPrice: '50.000',
           title: 'test',
           username: 'ujang',
          );
        },
      ),
    );
  }
}