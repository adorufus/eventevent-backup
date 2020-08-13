import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/merch/SelectAddress.dart';
import 'package:eventevent/Widgets/merch/transactionUtilities/ShippingOptionLists.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AddressItem.dart';
import 'package:http/http.dart' as http;

class DeliveryOptions extends StatefulWidget {
  final addressName;
  final fullAddress;

  const DeliveryOptions({Key key, this.addressName, this.fullAddress})
      : super(key: key);
  @override
  _DeliveryOptionsState createState() => _DeliveryOptionsState();
}

class _DeliveryOptionsState extends State<DeliveryOptions> {
  List shippingOptionList = [];
  String selectedShippingMethodName = '';
  String selectedShippingMethodCode = '';
  String selectedShippingMethodService = '';
  int selectedShippingPrice = 0;

  bool shippingMethodSelected = false;

  String productName = '';
  int productPrice = 0;
  String productImage = '';
  int accumulatedPrice = 0;
  int howMuch = 0;

  SharedPreferences preferences;

  // @override
  // void initState() {
  //   initializeValue();
  //   super.initState();
  // }

  void initializeValue() async {
    preferences = await SharedPreferences.getInstance();

    productName = preferences.getString("productName");
    productPrice = preferences.getInt("accumulatedPrice");
    productImage = preferences.getString("productImage");
    howMuch = preferences.getInt("productQuantity");
    accumulatedPrice = productPrice;

    if (mounted) setState(() {});
  }

  @override
  void initState() {
    initializeValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 13),
            color: Colors.white,
            child: AppBar(
              brightness: Brightness.light,
              elevation: 0,
              backgroundColor: Colors.white,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/icons/icon_apps/arrow.png',
                  scale: 5.5,
                  alignment: Alignment.centerLeft,
                ),
              ),
              title: Text('Transaction Details'),
              centerTitle: true,
              textTheme: TextTheme(
                  title: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black,
              )),
            ),
          ),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => SelectAddress()));
          if (shippingMethodSelected == false) {
            Flushbar(
              message: "Please Select Shipping Method",
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
              flushbarPosition: FlushbarPosition.TOP,
              animationDuration: Duration(milliseconds: 500),
            ).show(context);
          }
        },
        child: Container(
          height: ScreenUtil.instance.setWidth(50),
          color: Color(0xFFff8812),
          child: Center(
              child: Text(
            'NEXT',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          children: <Widget>[
            topSection(context),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 12,
            ),
            addressSection(context),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 12,
            ),
            chooseDelivery(context),
            SizedBox(
              height: 20,
            ),
            Divider(),
            SizedBox(
              height: 12,
            ),
            totalSection(context,
                title: 'Subtotal:', price: 'Rp. $accumulatedPrice'),
          ],
        ),
      ),
    );
  }

  Widget topSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(
                image: NetworkImage(
                  productImage,
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10)),
        ),
        SizedBox(
          width: 15,
        ),
        Container(
          height: 98,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 197,
                child: Text(
                  '$productName',
                  style: TextStyle(
                    color: eventajaBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                children: <Widget>[
                  Text(
                    'Quantity',
                    style: TextStyle(
                        color: eventajaBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    '($howMuch)',
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  )
                ],
              ),
              Expanded(child: SizedBox()),
              Text(
                'Rp. $productPrice',
                style: TextStyle(
                    color: eventajaGreenTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget addressSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Address',
          style: TextStyle(
              color: eventajaBlack, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        AddressItem(
          isEditing: false,
          addressName: widget.addressName,
          fullAddress: widget.fullAddress,
        )
      ],
    );
  }

  Widget chooseDelivery(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Add Delivery',
              style: TextStyle(
                  color: eventajaBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Expanded(
              child: SizedBox(),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShippingOptionLists()))
                    .then((value) {
                  if (value != null) {
                    selectedShippingMethodName = value['shippingMethodName'];
                    selectedShippingMethodCode = value['shippingMethodCode'];
                    selectedShippingMethodService =
                        value['shippingMethodService'];
                    selectedShippingPrice = value['shippingPrice'];

                    accumulatedPrice = productPrice + selectedShippingPrice;

                    shippingMethodSelected = true;

                    if (mounted) setState(() {});
                  } else {
                    shippingMethodSelected = false;
                  }
                });
              },
              child: Container(
                height: 26,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey)),
                child: Center(
                    child: Text(
                  'Edit',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        totalSection(context,
            title: selectedShippingMethodName,
            price: 'Rp. $selectedShippingPrice')
      ],
    );
  }

  Widget totalSection(BuildContext context, {String title, String price}) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              color: eventajaBlack, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        Expanded(
          child: SizedBox(),
        ),
        Text(
          price,
          style: TextStyle(
              color: eventajaGreenTeal,
              fontWeight: FontWeight.bold,
              fontSize: 15),
        ),
      ],
    );
  }
}
