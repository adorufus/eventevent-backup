import 'dart:convert';

import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/BankAccountList.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/BankList.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SetupBankAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SetupBankAccountState();
  }
}

class SetupBankAccountState extends State<SetupBankAccount> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController accName = new TextEditingController();
  TextEditingController accNumber = new TextEditingController();
  String bankName = 'Choose bank';
  String bankID;

  @override
  Widget build(BuildContext context) {
    double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      key: scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(null, 100),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil.instance.setWidth(75),
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
            title: Text('Setup Bank Account'),
            centerTitle: true,
            textTheme: TextTheme(
                title: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: ScreenUtil.instance.setSp(14),
              color: Colors.black,
            )),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(15),
        children: <Widget>[
          Text(
              'Please setup your bank account for balance withdraw from your ticket sales or ticket refund'),
          SizedBox(
            height: ScreenUtil.instance.setWidth(15),
          ),
          Text(
            'Account Name',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.instance.setSp(18)),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(10),
          ),
          TextFormField(
            controller: accName,
            decoration: InputDecoration(
                hintText: 'Put your account name...',
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10))),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(15),
          ),
          Text(
            'Account Number',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.instance.setSp(18)),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(10),
          ),
          TextFormField(
            controller: accNumber,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: 'Put your account number...',
                fillColor: Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10))),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(15),
          ),
          Text(
            'Bank Name',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: ScreenUtil.instance.setSp(18)),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(10),
          ),
          GestureDetector(
            onTap: () async {
              Map<String, dynamic> result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => BankList()));
              bankName = result['bank_name'];
              bankID = result['id'];
              print(result['bank_name']);
            },
            child: Container(
              height: ScreenUtil.instance.setWidth(50),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child:
                  Align(alignment: Alignment.centerLeft, child: Text(bankName)),
            ),
          ),
          SizedBox(
            height: ScreenUtil.instance.setWidth(20),
          ),
          GestureDetector(
            onTap: () {
              postNewBank().then((response) {
                print(response.statusCode);
                print(response.body);
                var extractedData = json.decode(response.body);
                if (response.statusCode == 201 || response.statusCode == 200) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => DashboardWidget(isRest: false, selectedPage: 3,)),
                      ModalRoute.withName('/WithdrawBank'));
                      Navigator.push(context, MaterialPageRoute(builder: (context) => WithdrawBank()));
                } else {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    message: extractedData['desc'],
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                    animationDuration: Duration(milliseconds: 500),
                  )..show(context);
                }
              });
            },
            child: Container(
              height: ScreenUtil.instance.setWidth(50),
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: eventajaGreenTeal,
                  borderRadius: BorderRadius.circular(10)),
              child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Future<http.Response> postNewBank() async {
    String url = BaseApi().apiUrl + '/user_bank/post';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final response = await http.post(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'bank_id': bankID,
      'account_name': accName.text,
      'account_number': accNumber.text
    });

    return response;
  }
}
