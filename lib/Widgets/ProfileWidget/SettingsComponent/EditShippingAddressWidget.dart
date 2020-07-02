import 'dart:convert';
import 'dart:io';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/merch/AddAddress.dart';
import 'package:eventevent/Widgets/merch/AddressItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditShippingAddressWidget extends StatefulWidget {
  @override
  _EditShippingAddressWidgetState createState() =>
      _EditShippingAddressWidgetState();
}

class _EditShippingAddressWidgetState extends State<EditShippingAddressWidget> {
  List allUserAddress = [];
  bool isRequest = false;
  bool isEmpty = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    getUser();
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
              title: Text("Edit Shipping Address"),
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
      body: isRequest == true && isError == false
          ? Center(
              child: CupertinoActivityIndicator(
                animating: true,
              ),
            )
          : isError == true && isRequest == false
              ? EmptyState(
                  imagePath: "assets/icons/empty_state/error.png",
                  isTimeout: false,
                  reasonText: "Something went wrong :(",
                  // previousWidget: ,
                  refreshButtonCallback: () {
                    getUser();
                  },
                )
              : isEmpty == true || allUserAddress.isEmpty
                  ? EmptyState(
                      imagePath: "assets/icons/empty_state/error.png",
                      reasonText: "No Address Found :(",
                      isTimeout: true,
                      buttonText: 'Add Address',
                      refreshButtonCallback: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddAddress(),
                          ),
                        ).then((item) {
                          if (item != null) {
                            if (item['utama'] == "1") {
                              allUserAddress.insert(0, item);
                              isEmpty = false;
                            } else {
                              allUserAddress.add(item);
                              isEmpty = false;
                            }

                            if (mounted) setState(() {});
                          }
                        });
                      },
                    )
                  : Container(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          vertical: 13,
                          horizontal: 13,
                        ),
                        itemCount: allUserAddress.length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddAddress(isEditing: true, addressId: allUserAddress[i]['id'], addressData: allUserAddress[i],),
                                ),
                              ).then((deleted){
                                if(deleted == true){
                                  allUserAddress.removeAt(i);
                                }
                              });
                            },
                            child: AddressItem(
                              isEditing: true,
                              addressName: allUserAddress[i]['title'],
                              fullAddress: allUserAddress[i]['address'],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Future<http.Response> getAllUserAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/address/list?X-API-KEY=$API_KEY';

    try {
      isRequest = true;
      isError = false;
      if (mounted) setState(() {});
      final response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString("Session")
        },
      );
      return response;
    } on SocketException catch (e) {
      isRequest = false;
      isError = true;
      if (mounted) setState(() {});
      print(e.toString());
      return null;
    }
  }

  void getUser() {
    getAllUserAddress().then((response) {
      print(response.statusCode);
      print(response.body);
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        isRequest = false;
        allUserAddress.addAll(extractedData['data']);
        isEmpty = false;
        isError = false;
        if (mounted) setState(() {});
      } else if (response.statusCode == 400) {
        isRequest = false;
        isEmpty = true;
        isError = false;
        if (mounted) setState(() {});
      } else {
        isRequest = false;
        isError = true;
        if (mounted) setState(() {});

        print('Error, reason: ' + response.body.toString());
      }
    });
  }
}
