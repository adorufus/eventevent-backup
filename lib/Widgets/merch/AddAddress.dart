import 'dart:convert';
import 'dart:io';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/BaseBodyWithScaffoldAndAppBar.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddAddress extends StatefulWidget {
  final bool isEditing;
  final String addressId;
  final addressData;

  const AddAddress(
      {Key key, this.isEditing = false, this.addressId, this.addressData})
      : super(key: key);
  @override
  _AddAddressState createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  Map addressData = {};
  List provinceList = [];
  List citiesList = [];
  List kecamatanList = [];
  Map currentValueProvince;
  String currentProvinceId;
  Map currentValueCity;
  String currentCityId;
  String currentKecamatanId;
  Map currentValueKecamatan;
  int currentValue = 0;
  String isPrimary = "0";

  // TextEditingController provinceController = TextEditingController();
  // TextEditingController kecamatanController = TextEditingController();
  // TextEditingController kotaController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController yourNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  // TextEditingController  = TextEditingController();

  @override
  void initState() {
    print(widget.isEditing);
    if (widget.isEditing == true) {
      initialization();
    }

    getProvince().then((response) {
      print(response.statusCode);
      print(response.body);

      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        provinceList.addAll(extractedData['data']);
        if (mounted) setState(() {});
      } else {
        print('error aja, gatau gw');
      }
    });
    super.initState();
  }

  void initialization() {
    print(widget.addressData);
    titleController = TextEditingController(text: widget.addressData['title']);
    addressController =
        TextEditingController(text: widget.addressData['address']);
    yourNameController =
        TextEditingController(text: widget.addressData['name']);
    phoneController = TextEditingController(text: widget.addressData['phone']);
    postalCodeController =
        TextEditingController(text: widget.addressData['post_code']);
    isPrimary = widget.addressData['utama'];
    if (mounted) setState(() {});
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
              title: Text('Add Address'),
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
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13),
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 13),
            cacheExtent: 15,
            children: <Widget>[
              DropdownButton(
                hint: Text('Select Province'),
                items: provinceList.map((item) {
                  return DropdownMenuItem(
                    child: Text(item['name']),
                    value: item,
                  );
                }).toList(),
                value:
                    currentValueProvince != null ? currentValueProvince : null,
                onChanged: (value) {
                  print(value);
                  currentValueProvince = value;
                  if (mounted) setState(() {});
                  getCities().then((response) {
                    print(response.statusCode);
                    print(response.body);

                    var extractedData = json.decode(response.body);
                    if (response.statusCode == 200) {
                      if (citiesList.isNotEmpty) {
                        citiesList.clear();
                        citiesList.addAll(extractedData['data']);
                      } else {
                        citiesList.addAll(extractedData['data']);
                      }
                      if (mounted) setState(() {});
                    } else {
                      //TODO: handle error
                    }
                  });
                },
              ),
              SizedBox(
                height: 16,
              ),
              DropdownButton(
                hint: Text('Select City'),
                items: citiesList.map((item) {
                  return DropdownMenuItem(
                    child: Text(item['name']),
                    value: item as Map,
                  );
                }).toList(),
                value: currentValueCity != null ? currentValueCity : null,
                onChanged: (value) {
                  print(value);
                  currentValueCity = value;
                  if (mounted) setState(() {});
                  getSubDistrict().then((response) {
                    print(response.statusCode);
                    print(response.body);

                    var extractedData = json.decode(response.body);
                    if (response.statusCode == 200) {
                      if (kecamatanList.isNotEmpty) {
                        kecamatanList.clear();
                        kecamatanList.addAll(extractedData['data']);
                      } else {
                        kecamatanList.addAll(extractedData['data']);
                      }
                      if (mounted) setState(() {});
                    } else {
                      //TODO: handle error
                    }
                  });
                },
              ),
              SizedBox(
                height: 16,
              ),
              DropdownButton(
                hint: Text('Select Sub-District'),
                items: kecamatanList.map((item) {
                  return DropdownMenuItem(
                    child: Text(item['name']),
                    value: item as Map,
                  );
                }).toList(),
                value: currentValueKecamatan != null
                    ? currentValueKecamatan
                    : null,
                onChanged: (value) {
                  currentValueKecamatan = value;
                  print(currentValueKecamatan);
                  if (mounted) setState(() {});
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: postalCodeController,
                decoration: InputDecoration(
                  hintText: 'Masukan Kode Pos kamu disini',
                  labelText: 'Kode Pos',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Masukan Alamat Lengkap kamu disini',
                  labelText: 'Full Address',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Set your unique name here, (i.e Home, Office)',
                  labelText: 'address name',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: yourNameController,
                decoration: InputDecoration(
                  hintText: 'Set your name here',
                  labelText: 'Your name',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  hintText: 'Set your phone number here',
                  labelText: 'Phone number',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text('Set as primary address?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Radio(
                    groupValue: currentValue,
                    onChanged: (int i) => setState(() {
                      currentValue = i;
                      isPrimary = '0';
                    }),
                    value: 0,
                  ),
                  Text('No'),
                  SizedBox(width: ScreenUtil.instance.setWidth(30)),
                  Radio(
                    groupValue: currentValue,
                    onChanged: (int i) => setState(() {
                      currentValue = i;
                      isPrimary = '1';
                    }),
                    value: 1,
                  ),
                  Text('Yes'),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                margin: EdgeInsets.only(left: 13, right: 13, top: 13),
                width: MediaQuery.of(context).size.width,
                height: 60,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 15,
                        width: 15,
                        child:
                            Image.asset('assets/icons/icon_apps/location.png'),
                      ),
                      SizedBox(
                        width: 9,
                      ),
                      Container(
                        child: Text(
                          'Pilih Lokasi',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Map newAddressData = {
                      'title': titleController.text,
                      'name': yourNameController.text,
                      'address': addressController.text,
                      'province_data': currentValueProvince,
                      'city_data': currentValueCity,
                      'kecamatan_data': currentValueKecamatan,
                      'post_code': postalCodeController.text,
                      'utama': isPrimary,
                      'phone': phoneController.text
                    };

                    print(newAddressData);

                    print(currentValueProvince.toString() +
                        ' ' +
                        currentValueCity.toString() +
                        ' ' +
                        currentValueKecamatan.toString());
                    createNewAddress().then((response) {
                      print(response.statusCode);
                      print(response.body);

                      var extractedData = json.decode(response.body);

                      if (response.statusCode == 200) {
                        Navigator.pop(context, newAddressData);
                      } else {
                        print("error");
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    height: 35,
                    width: 150,
                    decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: eventajaGreenTeal.withOpacity(0.4),
                            blurRadius: 2,
                            spreadRadius: 1.5,
                          )
                        ],
                        color: eventajaGreenTeal,
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                        child: Text(
                      'SAVE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              widget.isEditing == true
                  ? Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () {
                          showCupertinoDialog(
                              context: context,
                              builder: (thisContext) {
                                return CupertinoAlertDialog(
                                  title: Text('Deleting Address'),
                                  content: Text(
                                      'Are you sure you want to delete this address?'),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: Text('No'),
                                      onPressed: () {
                                        Navigator.pop(thisContext);
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text('Yes'),
                                      onPressed: () {
                                        deleteAddress().then((response) {
                                          print(response.statusCode);
                                          print(response.body);

                                          if (response.statusCode == 200) {
                                            Navigator.pop(thisContext);
                                            Navigator.pop(context, true);
                                          }
                                        });
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          height: 35,
                          width: 150,
                          decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 2,
                                  spreadRadius: 1.5,
                                )
                              ],
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                            child: Text(
                              'Delete',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Future<http.Response> getProvince() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/address/province?X-API-KEY=$API_KEY';

    var response;

    try {
      response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session')
        },
      );
    } on SocketException catch (e) {
      print(e);
    }

    return response;
  }

  Future<http.Response> getCities() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/address/city?X-API-KEY=$API_KEY&province_id=${currentValueProvince['id']}';

    var response;

    try {
      response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session')
        },
      );
    } on SocketException catch (e) {
      print(e);
    }

    return response;
  }

  Future<http.Response> getSubDistrict() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/address/kecamatan?X-API-KEY=$API_KEY&city_id=${currentValueCity['id']}';

    var response;

    try {
      response = await http.get(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString('Session')
        },
      );
    } on SocketException catch (e) {
      print(e);
    }

    return response;
  }

  Future<http.Response> createNewAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String endpoint = '/address/create';

    if (widget.isEditing == true) {
      endpoint = '/address/edit';
    } else {
      endpoint = '/address/create';
    }

    String url = BaseApi().apiUrl + endpoint;

    print(url);

    Map bodyData = {
      'X-API-KEY': API_KEY,
      'title': titleController.text,
      'name': yourNameController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'province_id': currentValueProvince['id'],
      'province_name': currentValueProvince['name'],
      'city_id': currentValueCity['id'],
      'city_name': currentValueCity['name'],
      'kecamatan_id': currentValueKecamatan['id'],
      'kecamatan_name': currentValueKecamatan['name'],
      'post_code': postalCodeController.text,
      'latitude': '',
      'longitude': '',
      'optional_address': '',
      'utama': isPrimary,
    };

    if (widget.isEditing == true) bodyData['addressId'] = widget.addressId;

    final response = await http.post(url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': preferences.getString("Session")
        },
        body: bodyData);

    return response;
  }

  Future<http.Response> deleteAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        '/address/delete?X-API-KEY=$API_KEY&addressId=${widget.addressId}';

    try {
      final response = http.get(url, headers: {
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
