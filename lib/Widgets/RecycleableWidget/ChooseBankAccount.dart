import 'dart:convert';

import 'package:eventevent/Widgets/Transaction/Xendit/TicketReview.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChooseBankAccount extends StatefulWidget {
  final String title;

  const ChooseBankAccount({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChooseBankAccountState();
  }
}

class _ChooseBankAccountState extends State<ChooseBankAccount> {
  List vaList;
  String vaPictureURI;

  @override
  void initState() {
    super.initState();
    getVirtualAccountList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios,
            size: 35,
            color: eventajaGreenTeal,
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                    child: Text(
                  'Choose bank account for payment',
                  style: TextStyle(fontSize: 20),
                )),
              ),
              Container(
                height: 340,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: vaList == null ? 0 : vaList.length,
                  itemBuilder: (BuildContext context, i) {
                    return GestureDetector(
                      onTap: (){
                        if(vaList[i]['bank_code'] == 'BNI'){
                          getBankDetails(vaList[i]['bank_code'], vaList[i]['virtual_account_number'], vaList[i]['virtual_account_name']);
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TicketReview()));
                        }
                        else if(vaList[i]['bank_code'] == 'BRI'){
                          getBankDetails(vaList[1]['bank_code'], vaList[1]['virtual_account_number'], vaList[1]['virtual_account_name']);
                          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => TicketReview()));
                        }
                      },
                      child: Container(
                        height: 130,
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.only(
                            left: 15, right: 7, top: 10, bottom: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: Colors.grey,
                                  blurRadius: 1,
                                  offset: Offset(1, 1))
                            ],
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                height:
                                    vaList[i]['bank_code'] == 'BNI' ? 40 : 30,
                                child: Image.asset(
                                    vaList[i]['bank_code'] == 'BNI'
                                        ? 'assets/drawable/bni.png'
                                        : 'assets/drawable/bri.png'),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    vaList[i]['virtual_account_name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.black54),
                                  ),
                                  SizedBox(height: 10),
                                  Text(vaList[i]['bank_code'],
                                      style: TextStyle(color: Colors.grey)),
                                  SizedBox(height: 10),
                                  Text(
                                    vaList[i]['virtual_account_number'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.black54),
                                  ),
                                ])
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  getBankDetails(String bankCode, String accNumber, String bankName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('bank_code', bankCode);
    preferences.setString('bank_acc', accNumber);
    preferences.setString('bank_name', bankName);

    print(preferences.getString('bank_code'));
    print(preferences.getString('bank_acc'));
    print(preferences.getString('bank_name'));
  }

  Future getVirtualAccountList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var session;

    setState(() {
      session = preferences.getString('Session');
    });

    String virtualAccURI = BaseApi().apiUrl + '/va/list?X-API-KEY=' + API_KEY;
    final response = await http.get(virtualAccURI,
        headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session});

    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);
        vaList = extractedData['data'];
      });
    }
  }
}
