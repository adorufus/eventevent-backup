import 'dart:convert';

import 'package:eventevent/Widgets/RecycleableWidget/WaitTransaction.dart';
import 'package:eventevent/Widgets/Transaction/Alfamart/WaitingTransactionAlfamart.dart';
import 'package:eventevent/Widgets/Transaction/BCA/InputBankData.dart';
import 'package:eventevent/Widgets/Transaction/CC.dart';
import 'package:eventevent/Widgets/Transaction/ExpiredPage.dart';
import 'package:eventevent/Widgets/Transaction/GOPAY/WaitingGopay.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/Widgets/notification/TransactionHistoryItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TransactionHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionHistoryState();
  }
}

class TransactionHistoryState extends State<TransactionHistory> {
  List transactionList = [];
  Color paymentStatusColor;
  String paymentStatusText;

  @override
  void initState() {
    if (!mounted) {
      return;
    } else {
      getTransactionHistory();
    }
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

    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 13.0),
                  child: GestureDetector(
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
                ),
                centerTitle: true,
                title: Text(
                  'Transaction History',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil.instance.setSp(14)),
                ),
              ),
            )),
        body: transactionList == null
            ? Container(
                child: Center(
                  child: CupertinoActivityIndicator(radius: 20),
                ),
              )
            : Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: transactionList.length == null
                      ? 0
                      : transactionList.length,
                  itemBuilder: (BuildContext context, i) {
                    if (transactionList[i]['status_transaksi'] == 'completed') {
                      paymentStatusColor = eventajaGreenTeal;
                      paymentStatusText = 'Payment Success';
                    } else if (transactionList[i]['status_transaksi'] ==
                        'expired') {
                      paymentStatusColor = Colors.red[500];
                      paymentStatusText = 'Transaction Expired';
                    } else if (transactionList[i]['status_transaksi'] ==
                        'pending') {
                      paymentStatusColor = Colors.yellow[600];
                      paymentStatusText = 'Waiting for payment';
                    }

                    Widget page = WaitTransaction(
                      transactionID: transactionList[i]['id'],
                      expDate: transactionList[i]['expired_time'],
                      finalPrice: transactionList[i]['amount'],
                    );

                    if (transactionList[i]['payment']['method'] == 'Bca') {
                      page = PaymentBCA(
                        expDate: transactionList[i]['expired_time'],
                        transactionID: transactionList[i]['id'],
                      );
                    } else if (transactionList[i]['payment']['method'] ==
                        'Virtual Account') {
                      page = WaitTransaction(
                        transactionID: transactionList[i]['id'],
                        expDate: transactionList[i]['expired_time'],
                        finalPrice: transactionList[i]['amount'],
                      );
                    } else if (transactionList[i]['payment']['method'] ==
                        'Alfamart') {
                      page = WaitingTransactionAlfamart(
                        expDate: transactionList[i]['expired_time'],
                        transactionID: transactionList[i]['id'],
                      );
                    } else if (transactionList[i]['payment']['method'] ==
                        'Gopay') {
                      page = WaitingGopay(
                        expDate: transactionList[i]['expired_time'],
                        transactionID: transactionList[i]['id'],
                        amount: transactionList[i]['amount'],
                        deadline: transactionList[i]['expired_time'],
                        gopaytoken: transactionList[i]['payment_vendor_code'],
                      );
                    } else if (transactionList[i]['payment']['method'] ==
                        'Indomaret') {
                      page = WebViewTest(
                        url: transactionList[i]['payment']['data_vendor']
                            ['payment_url'],
                      );
                    } else if (transactionList[i]['payment']['method'] ==
                        'OVO') {
                      page = WebViewTest(
                        url: transactionList[i]['payment']['data_vendor']
                            ['invoice_url'],
                      );
                    } else if (transactionList[i]['payment']['method'] ==
                        'Credit Card') {
                      page = CreditCardInput(
                        transactionID: transactionList[i]['id'],
                        expDate: transactionList[i]['expired_date'],
                      );
                    }

                    return GestureDetector(
                        onTap: () {
                          if (transactionList[i]['status_transaksi'] ==
                              'pending') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => page));
                          } else if (transactionList[i]['status_transaksi'] ==
                              'completed') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        SuccessPage()));
                          } else if (transactionList[i]['status_transaksi'] ==
                              'expired') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ExpiredPage()));
                          }
                        },
                        child: TransactionHistoryItem(
                          image: transactionList[i]['ticket_image'] == false
                              ? ''
                              : transactionList[i]['ticket_image']
                                  ['secure_url'],
                          ticketCode: transactionList[i]['transaction_code'],
                          ticketName: transactionList[i]['ticket']
                              ['ticket_name'],
                          ticketStatus: paymentStatusText,
                          ticketColor: paymentStatusColor,
                          quantity: transactionList[i]['quantity'],
                          timeStart: transactionList[i]['updated_at'],
                          price: transactionList[i]['amount'],
                        ));
                  },
                ),
              ),
      ),
    );
  }

  Future getTransactionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url =
        BaseApi().apiUrl + '/ticket_transaction/list?X-API-KEY=$API_KEY&page=1';

    final response = await http.get(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      setState(() {
        var extractedData = json.decode(response.body);

        transactionList = extractedData['data'];
        print(transactionList);
      });
    }
  }
}
