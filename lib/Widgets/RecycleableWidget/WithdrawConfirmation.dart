import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WithdrawConfirmation extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    
    return WithdrawConfirmationState();
  }
}

class WithdrawConfirmationState extends State<WithdrawConfirmation>{

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController passwordController = new TextEditingController();

  String userBankId;
  String bankId;
  String accName;
  String accNumber;
  String bankName;

  int withdrawAmount;
  String finalAmount;

  getData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState((){
      userBankId = prefs.getString('WITHDRAW_USER_BANK_ID');
      bankId = prefs.getString('WITHDRAW_BANK_ID');
      accName = prefs.getString('WITHDRAW_ACCOUNT_NAME');
      accNumber = prefs.getString('WITHDRAW_ACCOUNT_NUMBER');
      bankName = prefs.getString('WITHDRAW_BANK_NAME');
      withdrawAmount = int.parse(prefs.getString('WITHDRAW_AMOUNT'));
      finalAmount = (withdrawAmount - 5000).toString();
    });

    print(userBankId);
    print(bankId);
    print(accName);
    print(accNumber);
    print(bankName);
    print(withdrawAmount.toString());
    print(finalAmount);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
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
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text('CONFIRMATION', style: TextStyle(color: eventajaGreenTeal),),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: (){
          showDialog(
              context: context,
              builder: (context){
                return GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        height: ScreenUtil.instance.setWidth(200),
                        width: ScreenUtil.instance.setWidth(300),
                        child: Column(
                          children: <Widget>[
                            Text('PASSWORD REQUIRED', style: TextStyle(color: Colors.black54,fontSize: ScreenUtil.instance.setSp(18), fontWeight: FontWeight.bold),),
                            SizedBox(height: ScreenUtil.instance.setWidth(10),),
                            Text('Please enter your EventEvent account password', textAlign: TextAlign.center,),
                            SizedBox(height: ScreenUtil.instance.setWidth(15),),
                            TextFormField(
                              obscureText: true,
                              controller: passwordController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black, width: ScreenUtil.instance.setWidth(1)),
                                ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black, width: ScreenUtil.instance.setWidth(1)),
                                  )
                              ),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  child: Text('Cancel', style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold),),
                                ),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(50),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    postWithdraw();
                                  },
                                  child: Text('Ok', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                )

                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
          );
        },
        child: Container(
          height: ScreenUtil.instance.setWidth(50),
          color: Colors.deepOrangeAccent,
          child: Center(child: Text('CONFIRM', style: TextStyle(color: Colors.white),),),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Center(
                    child: Text('WITHDRAW AMOUNT', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18),),),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(25),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text('Requested Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18), color: Colors.black26),),
                      Text('Rp. ' + withdrawAmount.toString() + ',-', style: TextStyle(fontSize: ScreenUtil.instance.setSp(18)),),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text('Processing Fee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18), color: Colors.black26),),
                      Text('-Rp. 5.000', style: TextStyle(fontSize: ScreenUtil.instance.setSp(18), color: Colors.red),),
                    ],
                  ),
                  Divider(color: Colors.grey,),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(15),
                  ),
                  Text('Amount will be transfered to your account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(16), color: Colors.grey),),
                  SizedBox(height: ScreenUtil.instance.setWidth(20),),
                  Text('Rp. ' + (withdrawAmount - int.parse('5000')).toString() + ',-', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(25), color: eventajaGreenTeal),),
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(20)
            ),
            Center(
              child: Text('TRANSFER TO', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18)),),
            ),
            SizedBox(
                height: ScreenUtil.instance.setWidth(20)
            ),
          ],
        ),
      ),
    );
  }

  Future postWithdraw() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/withdraw/post';

    final response = await http.post(
        url,
        headers: {
          'Authorization': AUTHORIZATION_KEY,
          'cookie': prefs.getString('Session')
        },
        body: {
          'X-API-KEY': API_KEY,
          'password': passwordController.text,
          'amount': withdrawAmount.toString(),
          'user_bank_id': userBankId,
          'desc': 'Withdraw from EventEvent'
    }
    );

    var extractedData = json.decode(response.body);
    print(response.statusCode);
    print(response.body);

    if(response.statusCode == 200 || response.statusCode == 201){
      Navigator.pop(context);

    }

    if(response.statusCode == 400){
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
}