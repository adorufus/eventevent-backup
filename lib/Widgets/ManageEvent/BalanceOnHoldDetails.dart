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

  @override
  void initState() {
    super.initState();
    getSalesHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey.withOpacity(.1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal)),
      ),
      body: ListView(
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
                  'Rp. ' +
                      widget.ticketSales['onhold_balance'].toString() +
                      ',-',
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
                        return GestureDetector(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Invoice(
                              transactionID: ticketSalesData[i]['transaction_id'],
                            )));
                          },
                          child: BalanceOnHoldItem(
                              username: ticketSalesData[i]['username'],
                              totalPrice: ticketSalesData[i]['amount'],
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
    );
  }

  Future getSalesHistory() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      BaseApi().apiUrl +
          '/event/sales_history?X-API-KEY=$API_KEY&event_id=${widget.eventId}&page=all',
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': preferences.getString('Session')
      },
    );

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
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print(extractedData);
    }
  }
}