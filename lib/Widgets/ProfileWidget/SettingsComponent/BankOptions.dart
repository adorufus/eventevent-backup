import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BankOptions extends StatefulWidget {
  final userBankId;
  final accountName;
  final bankName;
  final accountNumber;
  final bankIndex;

  const BankOptions(
      {Key key,
      this.userBankId,
      this.accountName,
      this.bankName,
      this.accountNumber,
      this.bankIndex})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BankOptionsState();
  }
}

class BankOptionsState extends State<BankOptions> {
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
        backgroundColor: appBarColor,
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
          'BANK ACCOUNT',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: ListView(children: <Widget>[
        Container(
          padding: EdgeInsets.all(15),
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Text(widget.accountName),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Text(widget.bankName),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Text(widget.accountNumber)
            ],
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(50),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
              color: eventajaGreenTeal,
              borderRadius: BorderRadius.circular(10)),
          height: ScreenUtil.instance.setWidth(50),
          child: Center(
            child: Text('EDIT ACCOUNT',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(
          height: ScreenUtil.instance.setWidth(10),
        ),
        GestureDetector(
          onTap: () {
            showCupertinoDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text('Warning'),
                    content: Text(
                      'Delete this bank account?',
                      textScaleFactor: 1.2,
                      textWidthBasis: TextWidthBasis.longestLine,
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('No'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text('Yes'),
                        onPressed: () {
                          deleteBankAccount().then((response) {
                            print(response.statusCode);
                            print(response.body);
                            if (response.statusCode == 200) {
                              Navigator.pop(context);
                              Navigator.pop(context, widget.bankIndex);
                            }
                          });
                        },
                      )
                    ],
                  );
                });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(10)),
            height: ScreenUtil.instance.setWidth(50),
            child: Center(
              child: Text('REMOVE',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        )
      ]),
    );
  }

  Future<http.Response> deleteBankAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/user_bank/delete';

    final response = http.delete(url, headers: {
      'Authorization': AUTH_KEY,
      'cookie': prefs.getString('Session'),
      'id': widget.userBankId,
      'X-API-KEY': API_KEY
    });

    return response;
  }
}
