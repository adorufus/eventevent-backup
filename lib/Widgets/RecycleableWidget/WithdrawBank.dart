import 'dart:convert';

import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/BankOptions.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/SetupBankAccount.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawConfirmation.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WithdrawBank extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WithdrawBankState();
  }
}

class WithdrawBankState extends State<WithdrawBank> {
  GlobalKey _tabBarKey = new GlobalKey();
  GlobalKey _appBarKey = new GlobalKey();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController amountController = new TextEditingController();

  Map balanceData;
  List bankList = [];
  List historyList = new List();

  MoneyFormatterOutput fo;

  int _currentValue = 0;
  String user_bank_id;
  String bank_id;
  String account_name;
  String account_number;
  String bank_name;

  @override
  void initState() {
    super.initState();
    getBalance();
    getBank();
    getHistory().then((response) {
      print(response.statusCode);
      var extractedData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          historyList = extractedData['data'];
          
        });
      } else {
        print('gagal');
      }
    }).timeout(Duration(seconds: 8), onTimeout: () {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content:
            Text('Request Time Out!', style: TextStyle(color: Colors.white)),
      ));
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
        resizeToAvoidBottomPadding: false,
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
                      'Balance',
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
        bottomNavigationBar: GestureDetector(
          onTap: () async {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return showBottomPopup();
                });
          },
          child: Container(
            height: ScreenUtil.instance.setWidth(50),
            color: Color(0xFFFFAA00),
            child: Center(
                child: Text(
              'WITHDRAW',
              style: TextStyle(color: Colors.white),
            )),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      labelColor: Colors.black,
                      labelStyle: TextStyle(fontFamily: 'Proxima'),
                      tabs: [
                        Tab(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Withdraw',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          ScreenUtil.instance.setSp(12.5))),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('History',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          ScreenUtil.instance.setSp(12.5))),
                            ],
                          ),
                        ),
                      ],
                      unselectedLabelColor: Colors.grey,
                    ),
                  ),
                  Container(
                    height:
                        MediaQuery.of(context).size.height - 48 - 72 - 52 - 1,
                    child: TabBarView(
                        physics: AlwaysScrollableScrollPhysics(),
                        children: [Withdraw(), History()]),
                  )
                ],
              ),
            )
          ],
        ));
  }

  testGetWidgetHeight() {
    final RenderBox renderBox = _tabBarKey.currentContext.findRenderObject();
    final RenderBox appBarRender = _appBarKey.currentContext.findRenderObject();
    print(renderBox.size.height);
    print(appBarRender.size.height);
  }

  Widget showBottomPopup() {
    return Container(
      color: Color(0xFF737373),
      child: Container(
        padding: EdgeInsets.only(top: 13, left: 25, right: 25, bottom: 30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
                    height: ScreenUtil.instance.setWidth(5),
                    width: ScreenUtil.instance.setWidth(50),
                    child: Image.asset(
                      'assets/icons/icon_line.png',
                      fit: BoxFit.fill,
                    ))),
            SizedBox(height: ScreenUtil.instance.setWidth(70)),
            Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Withdraw Ammount',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil.instance.setSp(17)),
                    ),
                    SizedBox(height: ScreenUtil.instance.setWidth(20)),
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 2, vertical: 12),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter withdraw amount (e.g. 125000)',
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(12))),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();

                        prefs.setString('WITHDRAW_USER_BANK_ID', user_bank_id);
                        prefs.setString('WITHDRAW_ACCOUNT_NAME', account_name);
                        prefs.setString('WITHDRAW_BANK_ID', bank_id);
                        prefs.setString(
                            'WITHDRAW_ACCOUNT_NUMBER', account_number);
                        prefs.setString('WITHDRAW_BANK_NAME', user_bank_id);
                        prefs.setString(
                            'WITHDRAW_AMOUNT', amountController.text);

                        if (amountController.text == '') {
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              'Input withdraw amount first!',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ));
                        } else if (int.parse(amountController.text) < 10000) {
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              'Minimum withdraw amount is Rp. 10.000,-',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ));
                        } else if (int.parse(amountController.text) >
                            int.parse(balanceData['amount'])) {
                          scaffoldKey.currentState.showSnackBar(SnackBar(
                            content: Text(
                              'Withdraw amount is bigger than your balance! ',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  WithdrawConfirmation()));
                        }
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(top: 31, bottom: 35),
                          height: ScreenUtil.instance.setWidth(37),
                          decoration: BoxDecoration(
                              color: Color(0xFFFFAA00),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    blurRadius: 2,
                                    color: Color(0xFFFFAA00).withOpacity(0.5),
                                    spreadRadius: 1.5)
                              ]),
                          child: Center(
                              child: Text(
                            'WITHDRAW',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget Withdraw() {
    return balanceData == null
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : ListView(
            children: <Widget>[
              Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      EdgeInsets.only(left: 13, right: 13, bottom: 6, top: 20),
                  child: Text(
                    'Balance:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(14)),
                  )),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 13),
                height: ScreenUtil.instance.setWidth(80),
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
                    child: Text('Rp. ${balanceData['amount']},-',
                        style: TextStyle(
                            color: eventajaGreenTeal,
                            fontSize: ScreenUtil.instance.setSp(20),
                            fontWeight: FontWeight.bold))),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(15),
              ),
              // TextFormField(
              //   controller: amountController,
              //   keyboardType: TextInputType.number,
              //   decoration: InputDecoration(
              //       filled: true,
              //       fillColor: Colors.white,
              //       hintText: 'Enter withdraw amount (e.g. 125000)',
              //       enabledBorder: OutlineInputBorder(
              //           borderSide: BorderSide.none,
              //           borderRadius: BorderRadius.circular(0)
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //           borderSide: BorderSide.none,
              //           borderRadius: BorderRadius.circular(0)
              //       )
              //   ),
              // ),
              // SizedBox(
              //   height: ScreenUtil.instance.setWidth(25),
              // ),
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
                        margin: EdgeInsets.symmetric(horizontal: 13),
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
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 5 - 10),
                            Container(
                                child: Text(
                              'ADD BANK ACCOUNT',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ],
                        ),
                      ),
                    ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      EdgeInsets.only(left: 13, right: 13, bottom: 9, top: 20),
                  child: Text(
                    'Select Bank:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(14)),
                  )),
              ColumnBuilder(
                mainAxisAlignment: MainAxisAlignment.center,
                itemCount: bankList.length == null ? 0 : bankList.length,
                itemBuilder: (BuildContext context, i) {
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
                  } else if (bankList[i]['bank_code'] == 'CIMB') {
                    bankImageUri = 'assets/drawable/cimb.jpg';
                  } else if (bankList[i]['bank_code'] == 'BTN') {
                    bankImageUri = 'assets/drawable/btn.png';
                  } else {
                    bankImageUri = 'assets/drawable/bank.png';
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => BankOptions(
                            accountName: bankList[i]['account_name'],
                            accountNumber: bankList[i]['account_number'],
                            bankName: bankList[i]['bank_name'],
                            userBankId: bankList[i]['id'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: ScreenUtil.instance.setWidth(85),
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(bottom: 9, left: 13, right: 13),
                      padding:
                          EdgeInsets.only(bottom: 9, left: 9, right: 9, top: 9),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 2,
                                color: Colors.black.withOpacity(.1),
                                spreadRadius: 1.5)
                          ]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            bankImageUri,
                            scale: 2,
                          ),
                          SizedBox(
                            width: ScreenUtil.instance.setWidth(9),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                    child: Text(
                                  bankList[i]['account_name'],
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: ScreenUtil.instance.setSp(12)),
                                  overflow: TextOverflow.ellipsis,
                                )),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(3)),
                                Container(
                                    width: ScreenUtil.instance.setWidth(200),
                                    child: Text(bankList[i]['bank_name'],
                                        style: TextStyle(
                                            fontSize:
                                                ScreenUtil.instance.setSp(15),
                                            fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis)),
                                SizedBox(
                                    height: ScreenUtil.instance.setWidth(3)),
                                Text(
                                  bankList[i]['account_number'],
                                  style: TextStyle(
                                    fontSize: ScreenUtil.instance.setSp(12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ScreenUtil.instance.setWidth(10)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Radio(
                                value: i,
                                groupValue: _currentValue,
                                onChanged: (int index) {
                                  setState(() {
                                    _currentValue = index;
                                    user_bank_id = bankList[index]['id'];
                                    account_name =
                                        bankList[index]['account_name'];
                                    bank_id = bankList[index]['bank_id'];
                                    account_number =
                                        bankList[index]['account_number'];
                                    bank_name = bankList[index]['bank_name'];

                                    print(user_bank_id);
                                    print(bank_id);
                                    print(account_name);
                                    print(account_number);
                                    print(bank_name);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(21),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: ScreenUtil.instance.setSp(14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: ScreenUtil.instance.setWidth(6)),
                    Text('Withdraw process may take up to 1 business day',
                        style: TextStyle(
                            fontSize: ScreenUtil.instance.setSp(14),
                            color: Colors.grey)),
                    SizedBox(height: ScreenUtil.instance.setWidth(15)),
                  ],
                ),
              ),
            ],
          );
  }

  Future getBank() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/user_bank/list?X-API-KEY=$API_KEY';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        bankList = extractedData['data'];
      });
    }
  }

  Widget History() {
    String transactionStatus = '';
    Color transactionColor;
    Color amountColor;

    return historyList == null
        ? Container(child: Center(child: CircularProgressIndicator()))
        : ListView.builder(
            itemCount: historyList == null ? 0 : historyList.length,
            itemBuilder: (BuildContext context, i) {
              fo = FlutterMoneyFormatter(amount: double.parse(historyList[i]['amount'] + '.0')).output;
              if (historyList[i]['status'] == 'completed') {
                transactionStatus = 'WITHDRAW COMPLETE';
                transactionColor = eventajaGreenTeal;
                amountColor = Colors.black;
              } else if (historyList[i]['status'] == 'pending') {
                transactionStatus = 'PROCESSING WITHDRAW';
                transactionColor = Colors.yellow;
                amountColor = Colors.grey;
              } else if (historyList[i]['status'] == 'request') {
                transactionStatus = 'REQUEST WITHDRAW';
                transactionColor = Colors.blueAccent;
                amountColor = Colors.grey;
              } else if (historyList[i]['status'] == 'added') {
                transactionStatus = 'ADDED BALANCE';
                transactionColor = Colors.lightGreen;
                amountColor = eventajaGreenTeal;
              }

              return Container(
                margin: EdgeInsets.only(top: 5, bottom: 5, left: 13, right: 13),
                padding: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: <Widget>[
                    // Flexible(
                    //                       child: Align(
                    //       alignment: Alignment.topLeft,
                    //       child: Icon(
                    //         Icons.brightness_1,
                    //         color: transactionColor,
                    //       )),
                    // ),
                    Container(
                      width: ScreenUtil.instance.setWidth(210),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.brightness_1,
                                size: ScreenUtil.instance.setSp(12),
                                color: transactionColor,
                              ),
                              SizedBox(
                                width: ScreenUtil.instance.setWidth(5),
                              ),
                              Text(
                                transactionStatus,
                                style: TextStyle(
                                  fontSize: ScreenUtil.instance.setSp(13),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(12),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                historyList[i]['status'] == 'added'
                                    ? Text(
                                        historyList[i]['description'],
                                        style: TextStyle(fontSize: 10),
                                      )
                                    : Text(
                                        'Transfer to ' + historyList[i]['user_bank']['account_name'] ?? '-',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                historyList[i]['status'] == 'added'
                                    ? Container()
                                    : Text(
                                        historyList[i]['user_bank']['account_number'] ?? '-' + ' / ',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                historyList[i]['status'] == 'added'
                                    ? Container()
                                    : Text(
                                        DateTime.parse(historyList[i]['created_at']).day.toString() + '-' + DateTime.parse(historyList[i]['created_at']).month.toString() + '-' + DateTime.parse(historyList[i]['created_at']).year.toString() ,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                historyList[i]['status'] == 'added'
                                    ? Container()
                                    : Text(
                                        historyList[i]['withdraw_code'] ?? '-',
                                        style: TextStyle(fontSize: 10),
                                      )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Center(
                        child: Text(
                          'Rp. ${fo.withoutFractionDigits}',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              color: amountColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Future<http.Response> getHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + "/withdraw/list?X-API-KEY=$API_KEY&page=1";

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }

  Future getBalance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String uri = BaseApi().apiUrl + '/withdraw/balance?X-API-KEY=$API_KEY';

    final response = await http.get(uri, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        balanceData = extractedData['data'];
      });
    }
  }
}
