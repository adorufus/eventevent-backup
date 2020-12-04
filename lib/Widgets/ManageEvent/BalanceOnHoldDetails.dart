import 'dart:convert';

import 'package:eventevent/Widgets/EmptyState.dart';
import 'package:eventevent/Widgets/Home/HomeLoadingScreen.dart';
import 'package:eventevent/Widgets/ManageEvent/BalanceOnHoldItem.dart';
import 'package:eventevent/Widgets/RecycleableWidget/Invoice.dart';
import 'package:eventevent/Widgets/notification/TransactionHistoryItem.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BalanceOnHoldDetails extends StatefulWidget {
  final Map ticketSales;
  final String eventId;

  const BalanceOnHoldDetails({Key key, this.ticketSales, this.eventId})
      : super(key: key);
  @override
  _BalanceOnHoldDetailsState createState() => _BalanceOnHoldDetailsState();
}

class _BalanceOnHoldDetailsState extends State<BalanceOnHoldDetails> {
  List ticketSalesData;
  bool isEmpty;
  bool isLoading = false;
  String price = '0';
  int balance = 0;
  int newPage = 0;
  RefreshController refreshController = new RefreshController(initialRefresh: false);
  List<int> amountAccumulatedList = [];

  @override
  void initState() {
    super.initState();
    getSalesHistory().then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        if (extractedData['data']['history'].toString() == 'false') {
          setState(() {
            isEmpty = true;
          });
        } else {
          setState(() {
            isEmpty = false;
            ticketSalesData = extractedData['data']['history'];
            print('ticketSalesData: ' + ticketSalesData.toString());

            for (int i = ticketSalesData.length; i >= 0; i--) {
              try {
                int xAmount = int.parse(ticketSalesData[i]['amount']);
                if (ticketSalesData[i]['type'] == 'added_balance') {
                  balance = balance - xAmount;
                } else {
                  balance = balance + xAmount;
                }

                amountAccumulatedList.add(balance);
                print('accumulated list: ' + balance.toString());

                print(balance);
              } catch (e) {
                print(e);
              }
            }
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print(extractedData);
      }
    });
  }

  void onLoading () async {
    await Future.delayed(Duration(seconds: 2));
    setState((){
      newPage += 1;
    });

    getSalesHistory(page: newPage, isPull: true).then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (extractedData['data']['history'].toString() == 'false') {
          refreshController.loadNoData();
        } else {
          setState(() {
            isEmpty = false;
            ticketSalesData.addAll(extractedData['data']['history']);
            print('ticketSalesData: ' + ticketSalesData.toString());

            for (int i = ticketSalesData.length; i >= 0; i--) {
              try {
                int xAmount = int.parse(ticketSalesData[i]['amount']);
                if (ticketSalesData[i]['type'] == 'added_balance') {
                  balance = balance - xAmount;
                } else {
                  balance = balance + xAmount;
                }

                amountAccumulatedList.add(balance);
                print('accumulated list: ' + balance.toString());

                print(balance);
                refreshController.loadComplete();
              } catch (e) {
                print(e);
                refreshController.loadFailed();
              }

            }
          });
        }
      } else {
        refreshController.loadFailed();
        print(extractedData);
      }
    });
  }

  void onRefresh() async {
    setState((){
      newPage = 0;
    });

    getSalesHistory(isPull: true).then((response) {
      var extractedData = json.decode(response.body);

      if (response.statusCode == 200) {
        
        if (extractedData['data']['history'].toString() == 'false') {
          setState(() {
            isEmpty = true;
          });
          refreshController.refreshFailed();
        } else {
          setState(() {
            isEmpty = false;
            ticketSalesData = extractedData['data']['history'];
            print('ticketSalesData: ' + ticketSalesData.toString());

            for (int i = ticketSalesData.length; i >= 0; i--) {
              try {
                int xAmount = int.parse(ticketSalesData[i]['amount']);
                if (ticketSalesData[i]['type'] == 'added_balance') {
                  balance = balance - xAmount;
                } else {
                  balance = balance + xAmount;
                }

                amountAccumulatedList.add(balance);
                print('accumulated list: ' + balance.toString());

                print(balance);
              } catch (e) {
                print(e);
              }
            }
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print(extractedData);
      }
    });

    await Future.delayed(Duration(seconds: 2));

    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.withOpacity(.1),
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal)),
      ),
      body: SmartRefresher(
        onLoading: onLoading,
        onRefresh: onRefresh,
        controller: refreshController,
        enablePullUp: true,
              child: ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    blurRadius: 10,
                    color: Color(0xff8a8a8b).withOpacity(.5),
                    spreadRadius: 4,
                    offset: Offset(0, 1))
              ]),
              height: ScreenUtil.instance.setWidth(150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'BALANCE ON HOLD',
                    style: TextStyle(
                        fontSize: ScreenUtil.instance.setSp(20),
                        color: Colors.grey),
                  ),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(15),
                  ),
                  Text(
                    'Rp. ' + widget.ticketSales['onhold_balance'] + ',-',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                ],
              ),
            ),
            isEmpty == true
                ? SizedBox(
                    height: 50,
                  )
                : Container(),
            isLoading == true
                ? HomeLoadingScreen().myTicketLoading()
                : isEmpty == true
                    ? EmptyState(
                        reasonText: 'No Transaction :(',
                        imagePath: 'assets/icons/empty_state/my_ticket.png',
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            ticketSalesData == null ? 0 : ticketSalesData.length,
                        // itemCount: 5,
                        itemBuilder: (context, i) {
                          print(price);

                          var reversedList =
                              amountAccumulatedList.reversed.toList();

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Invoice(
                                        transactionID: ticketSalesData[i]
                                            ['transaction_id'],
                                      )));
                            },
                            child: BalanceOnHoldItem(
                                username: ticketSalesData[i]['username'],
                                totalPrice: reversedList[i],
                                price: int.parse(ticketSalesData[i]['quantity']) <
                                        2
                                    ? ticketSalesData[i]['amount']
                                    : (int.parse(ticketSalesData[i]['amount']) /
                                            int.parse(
                                                ticketSalesData[i]['quantity']))
                                        .toString(),
                                userPict: ticketSalesData[i]['picture'],
                                ticketQuantity: ticketSalesData[i]['quantity'],
                                dateTime: DateTime.parse(
                                    ticketSalesData[i]['created_at']),
                                ticketName: ticketSalesData[i]['ticket_name'],
                                ticketImage: ticketSalesData[i]['ticket_image']
                                    ['secure_url']),
                          );
                        })
          ],
        ),
      ),
    );
  }

  Future<http.Response> getSalesHistory({int page, bool isPull}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int currentPage = 1;
    setState(() {
      if(page != null){
        currentPage += page;
      }
      isPull == false ? isLoading = true : isLoading = false;
    });

    final response = await http.get(
      BaseApi().apiUrl +
          '/event/sales_history?X-API-KEY=$API_KEY&event_id=${widget.eventId}&page=$currentPage',
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      },
    );

    return response;
  }
}
