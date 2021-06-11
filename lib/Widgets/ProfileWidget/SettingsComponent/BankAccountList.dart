import 'dart:convert';

import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/BankOptions.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/SetupBankAccount.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BankAccountList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BankAccountListState();
  }
}

class BankAccountListState extends State<BankAccountList> {
  List bankList = [];

  @override
  void initState() {
    getBank();
    super.initState();
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
      backgroundColor: checkForBackgroundColor(context),
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: eventajaGreenTeal,
          ),
        ),
        centerTitle: true,
        title: Text(
          'Bank Account',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            bankList == null
                ? Container()
                : ColumnBuilder(
                    mainAxisAlignment: MainAxisAlignment.center,
                    itemCount: bankList.length == null ? 0 : bankList.length,
                    itemBuilder: (BuildContext context, i) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      BankOptions(
                                        userBankId: bankList[i]['id'],
                                        accountName: bankList[i]
                                            ['account_name'],
                                        accountNumber: bankList[i]
                                            ['account_number'],
                                        bankName: bankList[i]['bank_name'],
                                      )));
                        },
                        child: Container(
                          height: ScreenUtil.instance.setWidth(85),
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(bottom: 3),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Align(
                                alignment: Alignment.centerRight,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                        child: Text(
                                      bankList[i]['account_name'],
                                      style: TextStyle(color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                    Container(
                                        width:
                                            ScreenUtil.instance.setWidth(200),
                                        child: Text(
                                          bankList[i]['bank_name'],
                                          style: TextStyle(
                                              fontSize: ScreenUtil.instance
                                                  .setSp(15)),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                    Text(
                                      bankList[i]['account_number'],
                                      style: TextStyle(
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: ScreenUtil.instance.setWidth(15)),
                              Icon(
                                Icons.navigate_next,
                                size: 25,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            bankList.length == 3
                ? Container()
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SetupBankAccount()));
                    },
                    child: Container(
                      height: ScreenUtil.instance.setWidth(100),
                      color: Colors.white,
                      child: Center(
                        child: Icon(
                          Icons.add_circle_outline,
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Future getBank() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/user_bank/list?X-API-KEY=$API_KEY';

    final response = await http.get(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        if (extractedData['desc'] == "Bank Account Found!") {
          bankList = extractedData['data'];
        } else {}
      });
    }
  }
}
