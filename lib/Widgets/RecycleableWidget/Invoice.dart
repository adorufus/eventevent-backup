import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Invoice extends StatefulWidget {
  final transactionID;

  const Invoice({Key key, this.transactionID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InvoiceState();
  }
}

class InvoiceState extends State<Invoice> {
  Map transactionDetail;

  String paymentMethod = '-';

  @override
  void initState() {
    super.initState();
    getTransactionDetail().then((response) {
      print(response.statusCode);
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          transactionDetail = extractedData['data'];
          if (transactionDetail['payment_method_id'] == '2') {
            paymentMethod = 'Bank Transfer';
          } else if (transactionDetail['payment_method_id'] == '1') {
            paymentMethod = 'Credit Card';
          } else if (transactionDetail['payment_method_id'] == '3') {
            paymentMethod = 'Alfamart';
          } else {
            paymentMethod = '-';
          }
        });
      } else {
        print("response error: " + response.body);
      }
    });
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
      appBar: AppBar(
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
          'INVOICE',
          style: TextStyle(color: eventajaGreenTeal),
        ),
      ),
      body: transactionDetail == null ? Container(child: Center(child: CircularProgressIndicator()),) : Container(
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            SizedBox(height: ScreenUtil.instance.setWidth(15)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: ScreenUtil.instance.setWidth(250),
                    height: ScreenUtil.instance.setWidth(50),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/icons/ic_logo_company.png'),
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.fill)),
                  ),
                  SizedBox(height: ScreenUtil.instance.setWidth(10)),
                  Text(
                    'INVOICE',
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(20)),
                  )
                ],
              ),
            ),
            SizedBox(height: ScreenUtil.instance.setWidth(10)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Name',
                        style: TextStyle(fontSize: ScreenUtil.instance.setSp(15)),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text('Order Number', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text('Data', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text('Payment Method', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text('E-Mail', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text('Phone Number', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text('Notes', style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                    ],
                  ),
                  SizedBox(
                    width: ScreenUtil.instance.setWidth(15),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        transactionDetail['firstname'],
                        style: TextStyle(fontSize: ScreenUtil.instance.setSp(15)),
                      ),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text(transactionDetail['transaction_code'],
                          style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text(transactionDetail['created_at'],
                          style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text(paymentMethod, style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text(transactionDetail['email'],
                          style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text(transactionDetail['phone'],
                          style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                      SizedBox(height: ScreenUtil.instance.setWidth(10)),
                      Text(
                          transactionDetail['note'] == '' || transactionDetail['note'] == null
                              ? '-'
                              : transactionDetail['note'],
                          style: TextStyle(fontSize: ScreenUtil.instance.setSp(15))),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(15),
            ),
            Container(
                height: ScreenUtil.instance.setWidth(55),
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Qty',
                      style: TextStyle(color: Colors.white, fontSize: ScreenUtil.instance.setSp(16)),
                    ),
                    Text('Name',
                        style: TextStyle(color: Colors.white, fontSize: ScreenUtil.instance.setSp(16))),
                    SizedBox(width: ScreenUtil.instance.setWidth(40)),
                    Text('Price (Rp)',
                        style: TextStyle(color: Colors.white, fontSize: ScreenUtil.instance.setSp(16))),
                  ],
                )),
                SizedBox(width: ScreenUtil.instance.setWidth(15)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(transactionDetail['quantity'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(16)),),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${transactionDetail['event']['name']}', style: TextStyle(color: Colors.black, fontSize: ScreenUtil.instance.setSp(16))),
                          Text('${transactionDetail['ticket']['ticket_name']}', style: TextStyle(color: Colors.black, fontSize: ScreenUtil.instance.setSp(16))),
                          Text('${transactionDetail['event']['dateStart']}', style: TextStyle(color: Colors.black, fontSize: ScreenUtil.instance.setSp(16))),
                          Text('${transactionDetail['event']['timeStart']} - ${transactionDetail['event']['name']}', style: TextStyle(color: Colors.black, fontSize: ScreenUtil.instance.setSp(16))),
                        ],
                      ),
                      Text(transactionDetail['ticket']['paid_ticket_type_id'] == '2' ? 'FREE' : transactionDetail['amount'], style: TextStyle(color: Colors.black, fontSize: ScreenUtil.instance.setSp(16))),
                    ],
                  ),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(25),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Divider(color: Colors.black,),
                ),
                SizedBox(
                  height: ScreenUtil.instance.setWidth(25),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 70, right: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18)),),
                      Text(transactionDetail['ticket']['paid_ticket_type_id'] == '2' ? 'FREE' : transactionDetail['amount'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: ScreenUtil.instance.setSp(18), color: eventajaGreenTeal),),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> getTransactionDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/ticket_transaction/detail?transID=${widget.transactionID}&X-API-KEY=$API_KEY';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    return response;
  }
}
