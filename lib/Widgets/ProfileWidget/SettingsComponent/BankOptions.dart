import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BankOptions extends StatefulWidget{
  final userBankId;
  final accountName;
  final bankName;
  final accountNumber;

  const BankOptions({Key key, this.userBankId, this.accountName, this.bankName, this.accountNumber}) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return BankOptionsState();
  }
}

class BankOptionsState extends State<BankOptions>{
  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap:(){
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal,),
        ),
        centerTitle: true,
        title: Text('BANK ACCOUNT', style: TextStyle(color: eventajaGreenTeal),),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                Text(widget.accountName),
                SizedBox(height: ScreenUtil.instance.setWidth(10),),
                Text(widget.bankName),
                SizedBox(height: ScreenUtil.instance.setWidth(10),),
                Text(widget.accountNumber)
              ],
            ),
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(50),),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 50),
            decoration: BoxDecoration(
              color: eventajaGreenTeal,
              borderRadius: BorderRadius.circular(10)
            ),
            height: ScreenUtil.instance.setWidth(50),
            child: Center(
              child: Text('EDIT ACCOUNT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: ScreenUtil.instance.setWidth(10),),
          GestureDetector(
            onTap: (){
              showDialog(
                context: context,
                builder: (BuildContext context){
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
                            height: ScreenUtil.instance.setWidth(100),
                            width: ScreenUtil.instance.setWidth(200),
                            child: Column(
                              children: <Widget>[
                                Text('Warning', style: TextStyle(color: Colors.black54,fontSize: ScreenUtil.instance.setSp(18), fontWeight: FontWeight.bold),),
                                SizedBox(height: ScreenUtil.instance.setWidth(10),),
                                Text('Delete this bank accout?', textAlign: TextAlign.center,),
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
                                        deleteBankAccount().then((response){
                                          print(response.statusCode);
                                          print(response.body);
                                          if(response.statusCode == 200){
                                            Navigator.pop(context);
                                          }
                                        });
                                      },
                                      child: Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
              margin: EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10)
              ),
              height: ScreenUtil.instance.setWidth(50),
              child: Center(
                child: Text('REMOVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ]
      ),
    );
  }

  Future<http.Response> deleteBankAccount() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/user_bank/delete';

    final response = http.delete(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session'),
        'id': widget.userBankId,
        'X-API-KEY': API_KEY
      }
    );

    return response;
  }
}