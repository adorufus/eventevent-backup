import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/Transaction/ExpiredPage.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/Widgets/notification/TransactionHistoryItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHisdtoryList extends StatefulWidget {
  @override
  _TransactionHisdtoryListState createState() =>
      _TransactionHisdtoryListState();
}

class _TransactionHisdtoryListState extends State<TransactionHisdtoryList> {
  List transactionList = [];
  String paymentStatusText = '';
  Color paymentStatusColor;

  bool isLoading = false;

  @override
  void initState() {
    getMerchTransactionList().then((response){
      print("Status code: " + response.statusCode.toString());
      print("Response Body: " + response.body);

      var extractedData = json.decode(response.body);

      if(response.statusCode == 200){
        transactionList.addAll(extractedData['data']);
      } else {
        print("error with response: " + response.body);
      }

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

    return SafeArea(
      bottom: false,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
              child: AppBar(
                brightness: Brightness.light,
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
        body: isLoading == true
            ? HomeLoadingScreen().myTicketLoading()
            : transactionList == null
                ? EmptyState(
                    imagePath: 'assets/icons/empty_state/history.png',
                    reasonText: 'You have no transaction yet.',
                  )
                : Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      itemCount: transactionList.length == null
                          ? 0
                          : transactionList.length,
                      itemBuilder: (BuildContext context, i) {
                        if (transactionList[i]['order_status'] ==
                            'finish') {
                          paymentStatusColor = eventajaGreenTeal;
                          paymentStatusText = 'Finished';
                        } else if (transactionList[i]['order_status'] ==
                            'rejected') {
                          paymentStatusColor = Colors.red[500];
                          paymentStatusText = 'Rejected';
                        } else if (transactionList[i]['order_status'] ==
                            'waiting_payment') {
                          paymentStatusColor = Colors.yellow[600];
                          paymentStatusText = 'Waiting for payment';
                        }

                        return GestureDetector(
                            onTap: () {
                              // if (transactionList[i]['status_transaksi'] ==
                              //     'pending') {
                              //   // Navigator.push(
                              //   //     context,
                              //   //     MaterialPageRoute(
                              //   //         builder: (BuildContext context) =>
                              //   //             page));
                              // } else if (transactionList[i]
                              //         ['status_transaksi'] ==
                              //     'completed') {
                              //   // Navigator.push(
                              //   //     context,
                              //   //     MaterialPageRoute(
                              //   //         builder: (BuildContext context) =>
                              //   //             SuccessPage(
                              //   //               invoiceNumber: transactionList[i]
                              //   //                   ['transaction_code'],
                              //   //             )));
                              // } else if (transactionList[i]
                              //         ['status_transaksi'] ==
                              //     'expired') {
                              //   Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (BuildContext context) =>
                              //               ExpiredPage()));
                              // }
                            },
                            child: TransactionHistoryItem(
                              image: transactionList[i]['product']['images'] == false
                                  ? ''
                                  : transactionList[i]['product']['images'],
                              ticketCode: transactionList[i]
                                  ['transaction_code'],
                              ticketName: transactionList[i]['product']
                                  ['product_name'],
                              ticketStatus: paymentStatusText,
                              ticketColor: paymentStatusColor,
                              quantity: transactionList[i]['product']['quantity'],
                              timeStart: transactionList[i]['created_at'],
                              price: transactionList[i]['grandtotal'],
                            ));
                      },
                    ),
                  ),
      ),
    );
  }

  Future<http.Response> getMerchTransactionList() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl +
        'transaction/list_transaction?X-API-KEY=$API_KEY&order_status=waiting_payment&page=1&limit=10';

    isLoading = true;
    if(mounted) setState((){});

    final response = await http.get(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString("Session"),
      }
    );

    return response;
  }
}