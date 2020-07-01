import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/merch/AddAddress.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddressItem.dart';
import 'DeliveryOptions.dart';
import 'package:http/http.dart' as http;

class SelectAddress extends StatefulWidget {
  @override
  _SelectAddressState createState() => _SelectAddressState();
}

class _SelectAddressState extends State<SelectAddress> {
  List allAddressList = [];
  int currentSelectedAddress = 0;

  @override
  void initState() {
    getAllAddress().then((response) {
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        print(extractedData);

        allAddressList.addAll(extractedData['data']);

        if (mounted) setState(() {});
      } else {
        print(extractedData);
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          message: "Something went wrong",
        ).show(context);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseBodyWithScaffoldAndAppBar(
      title: 'Select An Address',
      bottomNavBar: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => DeliveryOptions()));
        },
        child: Container(
          height: ScreenUtil.instance.setWidth(50),
          color: Color(0xFFff8812),
          child: Center(
              child: Text(
            'BUY',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAddress(),
                  ),
                ).then((item) {
                  if (item != null) {
                    if(item['utama'] == "1"){
                      allAddressList.insert(0, item);
                    } else 
                    {
                      allAddressList.add(item);
                    }
                  }
                });
              },
              child: addAddressButton(),
            ),
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
            ColumnBuilder(
              itemCount: allAddressList.length,
              itemBuilder: (context, i) {
                return addressItem(
                  addressName: allAddressList[i]['title'],
                  fullAddress: allAddressList[i]['address'],
                  isPrimary: allAddressList[i]['utama'],
                  index: i,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget addressItem(
      {int index, String addressName, String fullAddress, String isPrimary}) {
    if (isPrimary == "1") {
      // currentSelectedAddress = index;
      // if(mounted) setState((){});
    }
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
      margin: EdgeInsets.only(bottom: 15),
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
                    addressName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
                Container(
                  width: ScreenUtil.instance.setWidth(280),
                  child: Text(
                    fullAddress,
                    style: TextStyle(fontSize: 13),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(),
            ),
            Radio(
                value: index,
                groupValue: currentSelectedAddress,
                onChanged: (i) {
                  currentSelectedAddress = i;
                  if (mounted) setState(() {});
                  print(currentSelectedAddress);
                })
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

  Future<http.Response> getAllAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/address/list?X-API-KEY=$API_KEY';
    var response;

    try {
      response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString("Session")
        },
      );
    } on SocketException catch (e) {
      print('address: ' +
          e.address.address +
          ', message: ' +
          e.message +
          ', osError, message: ' +
          e.osError.message +
          ', osError, int: ' +
          e.osError.errorCode.toString());
    }

    return response;
  }
}
