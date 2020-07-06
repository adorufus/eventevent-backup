import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/merch/SelectAddress.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
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

  @override
  void initState() {
    getShippingOptions().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        shippingOptionList.addAll(extractedData['data']);
      } else {
        print(response.body);
      }
    });
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
              title: Text('Lorem Ipsum'),
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
            totalSection(context, title: 'Subtotal:', price: 'Rp. 410.000'),
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
              color: Color(0xfffec97c),
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
                  'Tas dari rotan',
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
                    '(2)',
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  )
                ],
              ),
              Expanded(child: SizedBox()),
              Text(
                'Rp. 400.000',
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
                showModalBottomSheet(
                  context: context,
                  builder: (thisContext) {
                    return StatefulBuilder(
                      builder: (BuildContext thisContext, StateSetter setState) => Container(
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                              top: 13, left: 25, right: 25, bottom: 30),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                              )),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 50),
                                child: SizedBox(
                                  height: ScreenUtil.instance.setWidth(5),
                                  width: ScreenUtil.instance.setWidth(50),
                                  child: Image.asset(
                                    'assets/icons/icon_line.png',
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 35,
                              ),
                              ColumnBuilder(
                                mainAxisSize: MainAxisSize.min,
                                itemCount: shippingOptionList.length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    children: <Widget>[
                                      ListTile(
                                        onTap: () {
                                          Navigator.pop(thisContext);
                                          if (!mounted) return;
                                          
                                          setState(() {
                                            selectedShippingMethodName =
                                                '${shippingOptionList[i]['code'].toUpperCase()} ${shippingOptionList[i]['service']} (${shippingOptionList[i]['estimated']} days)';
                                            selectedShippingMethodCode =
                                                shippingOptionList[i]['code'];
                                            selectedShippingMethodService =
                                                shippingOptionList[i]
                                                    ['service'];
                                            selectedShippingPrice =
                                                shippingOptionList[i]['price'];
                                          });

                                          
                                        },
                                        title: Text(shippingOptionList[i]
                                                ['code']
                                            .toString()
                                            .toUpperCase()),
                                        subtitle: Text(
                                            '${shippingOptionList[i]['service']} (${shippingOptionList[i]['estimated']} days)'),
                                      ),
                                      shippingOptionList[i] ==
                                              shippingOptionList.last
                                          ? Container()
                                          : SizedBox(
                                              height: ScreenUtil.instance
                                                  .setWidth(19)),
                                      shippingOptionList[i] ==
                                              shippingOptionList.last
                                          ? Container()
                                          : Divider(),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  elevation: 1,
                );
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

  Future<http.Response> getShippingOptions() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String currentBuyerAddressId =
        preferences.getString("currentSelectedAddressId");
    String thisProductSellerId = preferences.getString("sellerProductId");

    String url = BaseApi().apiUrl +
        '/address/shipping?X-API-KEY=$API_KEY&addressId=$currentBuyerAddressId&weight=2000&sellerId=$thisProductSellerId';

    try {
      final response = await http.get(url, headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString("Session")
      });

      return response;
    } on SocketException catch (e) {
      print(e);
      return null;
    }
  }
}
