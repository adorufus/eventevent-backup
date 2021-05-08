import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BankList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BankListState();
  }
}

class BankListState extends State<BankList> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  List bankList = [];

  @override
  void initState() {
    super.initState();
    getBankList().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('berhasil');
        print('response: ' + response.body);
        setState(() {
          bankList = extractedData['data'];
        });
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
  }

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
          child: Container(
            color: Colors.white,
            child: Container(
              margin: EdgeInsets.fromLTRB(13, 15, 13, 0),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil.instance.setWidth(15.49),
                          width: ScreenUtil.instance.setWidth(9.73),
                          child: Image.asset(
                            'assets/icons/icon_apps/arrow.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width / 2.8),
                  Text(
                    'Bank List',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(14)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: bankList == null ? 0 : bankList.length,
        itemBuilder: (context, i) {
          String bankImageUri = '';

          if (bankList[i]['bank_code'] == 'BCA') {
            bankImageUri = 'assets/drawable/bca.png';
          } else if (bankList[i]['bank_code'] == 'MANDIRI') {
            bankImageUri = 'assets/drawable/mandiri.png';
          } else if (bankList[i]['bank_code'] == 'BNI') {
            bankImageUri = 'assets/drawable/bni.png';
          } else if (bankList[i]['bank_code'] == 'BRI') {
            bankImageUri = 'assets/drawable/bri.png';
          } else if (bankList[i]['bank_code'] == 'PERMATA') {
            bankImageUri = 'assets/drawable/permata.png';
          } else if (bankList[i]['bank_code'] == 'DANAMON') {
            bankImageUri = 'assets/drawable/danamon.png';
          } else if (bankList[i]['bank_code'] == 'BTN') {
            bankImageUri = 'assets/drawable/btn.png';
          } else if (bankList[i]['bank_code'] == 'BII') {
            bankImageUri = 'assets/drawable/maybank.png';
          } else if (bankList[i]['bank_code'] == 'CIMB') {
            bankImageUri = 'assets/drawable/cimbniaga.png';
          } else {
            bankImageUri = 'assets/drawable/bank.png';
          }

          return ListTile(
            onTap: () {
              Navigator.pop(context,
                  {'id': bankList[i]['id'], 'bank_name': bankList[i]['name']});
            },
            leading: SizedBox(
                height: ScreenUtil.instance.setWidth(50),
                width: ScreenUtil.instance.setWidth(50),
                child: Image.asset(bankImageUri)),
            title: Text(
              bankList[i]['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              bankList[i]['bank_code'],
            ),
          );
        },
      ),
    );
  }

  Future<http.Response> getBankList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/bank/list?X-API-KEY=$API_KEY';

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
