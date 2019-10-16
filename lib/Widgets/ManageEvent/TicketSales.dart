import 'dart:convert';

import 'package:eventevent/Widgets/ManageEvent/Buyers.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WithdrawBank.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/ColumnBuilder.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TicketSales extends StatefulWidget {
  final eventID;
  final eventName;

  const TicketSales({Key key, this.eventID, this.eventName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TicketSalesState();
  }
}

class TicketSalesState extends State<TicketSales> {
  String eventName;
  Map ticketSalesData;
  List ticketData = [];

  @override
  void initState() {
    getData();
    super.initState();
    getTicketSales();
  }

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      eventName = prefs.getString('EVENT_NAME');
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Icon(Icons.arrow_back_ios, color: eventajaGreenTeal),
      ),
      body: ticketSalesData == null || ticketData == null
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'TOTAL TICKET SOLD',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          ticketSalesData['total_sold_ticket'] == null
                              ? '-'
                              : ticketSalesData['total_sold_ticket'].toString(),
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    color: Colors.white,
                    height: 300,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('From ' + widget.eventName),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'BALANCE ON HOLD',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Rp. ' +
                              ticketSalesData['onhold_balance'].toString() +
                              ',-',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        GestureDetector(
                          child: Text(
                            'SEE DETAILS >',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WithdrawBank()));
                            },
                            elevation: 0,
                            color: eventajaGreenTeal,
                            child: Text('WITHDRAW',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Notes',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Here\'s your net sales amount from your event...',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'TOTAL SALES AMOUNT',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            Text(
                              'Rp. ' +
                                  ticketSalesData['event_sold_amount'] +
                                  ',-',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: eventajaGreenTeal,
                                  fontSize: 18),
                            )
                          ],
                        ),
                        Divider(
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ColumnBuilder(
                          itemCount: ticketData == null ? 0 : ticketData.length,
                          itemBuilder: (BuildContext context, i) {
                            return GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Buyers(ticketID: ticketData[i]['id'],)));
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 130,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      height: 100,
                                      width: 70,
                                      child: Image.network(
                                        ticketData[i]['ticket_image']
                                            ['secure_url'],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Flexible(
                                                    flex: 1,
                                                    child: Text(
                                                      ticketData[i]
                                                          ['ticket_name'],
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                Text(
                                                  ticketData[i][
                                                              'paid_ticket_type_id'] ==
                                                          '1'
                                                      ? (int.parse(ticketData[i]
                                                                  [
                                                                  'merchant_price']) *
                                                              int.parse(
                                                                  ticketData[i]
                                                                      ['sold']))
                                                          .toString()
                                                      : 'FREE',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: ticketData[i][
                                                                  'paid_ticket_type_id'] ==
                                                              '1'
                                                          ? eventajaGreenTeal
                                                          : Colors.orange,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: Colors.grey,
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'REMAINING TICKET',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    ticketData[i]
                                                        ['remaining_ticket'],
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'TICKET SOLD',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Text(
                                                    ticketData[i]['sold'],
                                                    style: TextStyle(
                                                        color:
                                                            eventajaGreenTeal,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18),
                                                  )
                                                ],
                                              ),
                                              Icon(
                                                Icons.navigate_next,
                                                size: 25,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future getTicketSales() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl + '/event/sales';

    final response = await http.post(url, headers: {
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    }, body: {
      'X-API-KEY': API_KEY,
      'eventID': widget.eventID.toString()
    });

    print(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      var extractedData = json.decode(response.body);

      setState(() {
        ticketSalesData = extractedData['data'];
        ticketData = ticketSalesData['ticket_data'];
      });

      print(extractedData['data']);
    }
  }
}
