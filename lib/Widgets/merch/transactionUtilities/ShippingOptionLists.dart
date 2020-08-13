import 'dart:convert';
import 'dart:io';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShippingOptionLists extends StatefulWidget {
  @override
  _ShippingOptionListsState createState() => _ShippingOptionListsState();
}

class _ShippingOptionListsState extends State<ShippingOptionLists> {
  List shippingOptionList = [];

  bool isLoading = false;

  @override
  void initState() {
    getShippingOptions().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        shippingOptionList.addAll(extractedData['data']);
        isLoading = false;
        if (mounted) setState(() {});
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
              title: Text('Select Shipping Option'),
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
      body: isLoading == true
          ? Center(
              child: CupertinoActivityIndicator(
                animating: true,
              ),
            )
          : ListView.builder(
              itemCount: shippingOptionList.length,
              itemBuilder: (context, i) {
                return ListTile(
                  onTap: () {
                    // if (!mounted) return;

                    // if (mounted)
                    //   setState(() {
                    //     selectedShippingMethodName =
                    //         '${shippingOptionList[i]['code'].toUpperCase()} ${shippingOptionList[i]['service']} (${shippingOptionList[i]['estimated']} days)';
                    //     selectedShippingMethodCode = shippingOptionList[i]['code'];
                    //     selectedShippingMethodService =
                    //         shippingOptionList[i]['service'];
                    //     selectedShippingPrice = shippingOptionList[i]['price'];
                    //   });

                    Navigator.pop(
                      context,
                      {
                        "shippingMethodName":
                            '${shippingOptionList[i]['code'].toUpperCase()} ${shippingOptionList[i]['service']} (${shippingOptionList[i]['estimated']} days)',
                        "shippingMethodCode": shippingOptionList[i]['code'],
                        "shippingMethodService": shippingOptionList[i]
                            ['service'],
                        "shippingPrice": shippingOptionList[i]['price'],
                      },
                    );
                  },
                  title: Text(
                      shippingOptionList[i]['code'].toString().toUpperCase()),
                  subtitle: Text(
                      '${shippingOptionList[i]['service']} (${shippingOptionList[i]['estimated']} days)'),
                );
              },
            ),
    );
  }

  Future<http.Response> getShippingOptions() async {
    isLoading = true;
    if (mounted) setState(() {});

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
      isLoading = false;
      if (mounted) setState(() {});
      print(e);
      return null;
    }
  }
}
