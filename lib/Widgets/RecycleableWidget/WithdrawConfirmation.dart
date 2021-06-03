import 'dart:convert';

import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WithdrawConfirmation extends StatefulWidget {
  final bankCode;

  const WithdrawConfirmation({Key key, this.bankCode}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return WithdrawConfirmationState();
  }
}

class WithdrawConfirmationState extends State<WithdrawConfirmation> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController passwordController = new TextEditingController();

  String userBankId;
  String bankId;
  String accName;
  String accNumber;
  String bankName;

  int withdrawAmount;
  String finalAmount;
  String withdrawFee;
  bool isConfirmLoading = false;

  List paymentMethodList = [];

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userBankId = prefs.getString('WITHDRAW_USER_BANK_ID');
      bankId = prefs.getString('WITHDRAW_BANK_ID');
      accName = prefs.getString('WITHDRAW_ACCOUNT_NAME');
      accNumber = prefs.getString('WITHDRAW_ACCOUNT_NUMBER');
      bankName = prefs.getString('WITHDRAW_BANK_NAME');
      withdrawAmount = int.parse(prefs.getString('WITHDRAW_AMOUNT'));
    });

    print(userBankId);
    print(bankId);
    print(accName);
    print(accNumber);
    print(bankName);
    print(withdrawAmount.toString());
  }

  String getBankImageUri() {
    if (widget.bankCode == 'BCA') {
      return 'assets/drawable/bca.png';
    } else if (widget.bankCode == 'MANDIRI') {
      return 'assets/drawable/mandiri.png';
    } else if (widget.bankCode == 'BNI') {
      return 'assets/drawable/bni.png';
    } else if (widget.bankCode == 'BRI') {
      return 'assets/drawable/bri.png';
    } else if (widget.bankCode == 'PERMATA') {
      return 'assets/drawable/permata.png';
    } else if (widget.bankCode == 'DANAMON') {
      return 'assets/drawable/danamon.png';
    } else if (widget.bankCode == 'CIMB') {
      return 'assets/drawable/cimb.jpg';
    } else if (widget.bankCode == 'BTN') {
      return 'assets/drawable/btn.png';
    } else {
      return 'assets/drawable/bank.png';
    }
  }

  @override
  void initState() {
    getData();
    getWithdrawFee().then((response) {
      var extractedData = json.decode(response.body);

      print('payment method list: ' + extractedData.toString());

      if (response.statusCode == 200) {
        if (extractedData['data'].runtimeType.toString() ==
            '_InternalLinkedHashMap<String, dynamic>') {
          extractedData['data'].forEach((k, v) => paymentMethodList.add(v));
          print(paymentMethodList);
        } else {
          paymentMethodList = extractedData['data'];
        }

        for (int i = 0; i < paymentMethodList.length; i++) {
          withdrawFee = paymentMethodList[1]['withdraw_fee'];
        }
        setState(() {});
      }

      print(withdrawFee);
    });
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
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: checkForAppBarTitleColor(context),
          ),
        ),
        centerTitle: true,
        title: Text(
          'CONFIRMATION',
          style: TextStyle(color: checkForAppBarTitleColor(context)),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (thisContext) {
                return GestureDetector(
                  onTap: () {
                    // Navigator.pop(context);
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                            color: checkForBackgroundColor(context),
                            borderRadius: BorderRadius.circular(10)),
                        height: ScreenUtil.instance.setWidth(200),
                        width: ScreenUtil.instance.setWidth(300),
                        child: Column(
                          children: <Widget>[
                            Text(
                              'PASSWORD REQUIRED',
                              style: TextStyle(
                                  color: checkForSettingsTitleColor(context),
                                  fontSize: ScreenUtil.instance.setSp(18),
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(10),
                            ),
                            Text(
                              'Please enter your EventEvent account password',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(15),
                            ),
                            TextFormField(
                              obscureText: true,
                              controller: passwordController,
                              style: TextStyle(color: checkForSettingsTitleColor(context)),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: ScreenUtil.instance.setWidth(1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: ScreenUtil.instance.setWidth(1)),
                                ),
                              ),
                              textInputAction: TextInputAction.go,
                              onFieldSubmitted: (password) {
                                Navigator.pop(thisContext);
                                postWithdraw(password);
                              },
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                          color: Colors.lightBlue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil.instance.setWidth(50),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(thisContext);
                                      postWithdraw(passwordController.text);
                                    },
                                    child: Text('Ok',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        },
        child: Container(
          height: ScreenUtil.instance.setWidth(50),
          color: Colors.orange,
          child: Center(
            child: Text(
              'CONFIRM',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: withdrawAmount == null || withdrawFee == null
          ? HomeLoadingScreen().withdrawLoading(context)
          : Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: ListView(
                    children: <Widget>[
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Center(
                              child: Text(
                                'WITHDRAW AMOUNT',
                                style: TextStyle(
                                  color: checkForSettingsTitleColor(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(18),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(25),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  'Requested Amount',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil.instance.setSp(18),
                                      color: checkForSettingsTitleColor
                                        (context)),
                                ),
                                Text(
                                  'Rp' + withdrawAmount.toString() + ',-',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(18)),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Text(
                                  'Processing Fee',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil.instance.setSp(18),
                                      color: checkForSettingsTitleColor(context)),
                                ),
                                Text(
                                  '-Rp${withdrawFee == null ? '0' : withdrawFee}',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(18),
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(15),
                            ),
                            Text(
                              'Amount will be transfered to your account',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(16),
                                  color: Colors.grey),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Text(
                              'Rp' +
                                  (withdrawAmount == null || withdrawFee == null
                                          ? 0
                                          : withdrawAmount -
                                              int.parse(withdrawFee))
                                      .toString() +
                                  ',-',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: ScreenUtil.instance.setSp(25),
                                  color: eventajaGreenTeal),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(20)),
                      Center(
                        child: Text(
                          'TRANSFER TO',
                          style: TextStyle(
                              color: checkForSettingsTitleColor(context),
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil.instance.setSp(18)),
                        ),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(20)),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        color: checkForContainerBackgroundColor(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              getBankImageUri(),
                              scale: 2,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(accName, style: TextStyle(color: Colors.grey)),
                            Text(bankName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(accNumber, style: TextStyle(fontSize: 20))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                isConfirmLoading == false
                    ? Container()
                    : Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            animating: true,
                          ),
                        ),
                      )
              ],
            ),
    );
  }

  Future postWithdraw(String password) async {
    isConfirmLoading = true;
    setState(() {});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/withdraw/post';

    var body = {
      'X-API-KEY': API_KEY,
      'password': password,
      'amount': withdrawAmount.toString(),
      'user_bank_id': userBankId,
      'desc': 'Withdraw from EventEvent'
    };

    print(body);

    final response = await http.post(url,
        headers: {
          'Authorization': AUTH_KEY,
          'cookie': prefs.getString('Session')
        },
        body: body);

    var extractedData = json.decode(response.body);
    print(response.statusCode);
    print('xendit: ' + extractedData.toString());

    if (response.statusCode == 200 || response.statusCode == 201) {
      isConfirmLoading = false;
      setState(() {});
      if (extractedData['data']['isVendorPushSuccess'] == '0') {
        Navigator.pop(context);
        Flushbar(
          animationDuration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
          duration: Duration(seconds: 3),
          message: extractedData['data']['errors']['message'],
        ).show(context);
      } else {
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardWidget(
                      isRest: false,
                      selectedPage: 3,
                    )),
            ModalRoute.withName('/DashboardWidget'));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WithdrawBank(currentTab: 1),
          ),
        );
      }
    }

    if (response.statusCode == 400) {
      isConfirmLoading = false;
      setState(() {});
      Navigator.pop(context);
      Flushbar(
        flushbarPosition: FlushbarPosition.TOP,
        message: extractedData['desc'],
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
        animationDuration: Duration(milliseconds: 500),
      )..show(context);
    }
  }

  Future<http.Response> getWithdrawFee() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String baseUrl = BaseApi().apiUrl +
        '/payment_method/list?X-API-KEY=$API_KEY&indomaret=true';

    final response = await http.get(baseUrl, headers: {
      'Authorization': AUTH_KEY,
      'cookie': preferences.getString('Session')
    });

    print(response.statusCode);

    return response;
  }
}
