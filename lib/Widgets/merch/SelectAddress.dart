import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectAddress extends StatefulWidget {
  @override
  _SelectAddressState createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  @override
  Widget build(BuildContext context) {
    return BaseBodyWithScaffoldAndAppBar(
      title: 'Select An Address',
      bottomNavBar: Container(
        height: ScreenUtil.instance.setWidth(50),
        color: Color(0xFFff8812),
        child: Center(
            child: Text(
          'BUY',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        )),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          children: <Widget>[
            addAddressButton(),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 9, top: 20),
              child: Text(
                'Select Address:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil.instance.setSp(14)),
              ),
            ),
            addressItem(),
            SizedBox(
              height: 12,
            ),
            addressItem(),
            SizedBox(
              height: 12,
            ),
            addressItem(),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(bottom: 9, top: 20),
              child: Text(
                'Notes',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ScreenUtil.instance.setSp(14)),
              ),
            ),
            Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
          ],
        ),
      ),
    );
  }

  Widget addressItem() {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 2,
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1.5)
          ]),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 15,
              width: 15,
              child: Image.asset('assets/icons/icon_apps/location.png'),
            ),
            SizedBox(
              width: 9,
            ),
            Expanded(
              child: Container(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    'Address 1',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
                Container(
                  width: ScreenUtil.instance.setWidth(280),
                  child: Text(
                    'Jl Jend Gatot Subroto Kav 23 Graha BIP Lt 9,Karet Semanggi',
                    style: TextStyle(fontSize: 13),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Radio(value: null, groupValue: null, onChanged: null)
          ],
        ),
      ),
    );
  }

  Widget addAddressButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: ScreenUtil.instance.setWidth(42.61),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: <BoxShadow>[
            BoxShadow(
                blurRadius: 2,
                color: Colors.black.withOpacity(.1),
                spreadRadius: 1.5)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.add_circle_outline,
            size: 30,
          ),
          SizedBox(width: MediaQuery.of(context).size.width / 5 - 10),
          Container(
            child: Text(
              'ADD ADDRESS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
