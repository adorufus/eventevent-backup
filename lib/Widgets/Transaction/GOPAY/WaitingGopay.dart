import 'dart:convert';

import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_gopay_midtrans/flutter_gopay_midtrans.dart';

class WaitingGopay extends StatefulWidget{

  final String amount;
  final String deadline;
  final String gopaytoken;
  final expDate;
  final String transactionID;

  const WaitingGopay({Key key, this.amount, this.deadline, this.gopaytoken, this.expDate, this.transactionID}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WaitingGopayState();
  }
}

class _WaitingGopayState extends State<WaitingGopay>{
  String month;
  String hour;
  String min;
  String sec;

  DateTime dateTime;

  Map<String, dynamic> paymentData;

  void startCounter(String expired) {
    int hoursStart, minuteStart, secondStart;
    String strHour, strMinute, strSecond;

    dateTime = DateTime.parse(expired);

    hoursStart = dateTime.hour;
    minuteStart = dateTime.minute;
    secondStart = dateTime.second;

    setState(() {
      hour = hoursStart.toString();
      min = minuteStart.toString();
      sec = secondStart.toString();
    });

    print(hoursStart.toString() +
        minuteStart.toString() +
        secondStart.toString());

    // timer = new CountdownTimer();
  }

  @override
  void initState() {
    super.initState();
    getTransactionDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: (){
            Navigator.of(context).pop();
          },
          child: Icon(Icons.close, size: 35, color: eventajaGreenTeal,),
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: (){
          // FlutterGopayMidtrans.configure(
          //   client_id: CLINET_ID,
          //   amount: widget.amount,
          //   deadline: widget.deadline,
          //   gopaytoken: widget.gopaytoken,
          //   merchantUrl: 'https://home.eventeventapp.com/webhook/midtrans/'
          // );
          launch(paymentData['payment']['data_vendor']['payment_url']);
        },
        child: Container(
                  height: 50,
                  color: Colors.deepOrangeAccent,
                  child: Center(
                    child: Text(
                      'PAY WITH GO-PAY',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )),
      ),
      body: ListView(
        children: <Widget>[
          Container(
                  height: 380,
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: eventajaGreenTeal),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Text('Complete Payment In',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('${hour}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  ':',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '$min',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  ':',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '$sec',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('H',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                                SizedBox(
                                  width: 35,
                                ),
                                Text('M',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                                SizedBox(
                                  width: 35,
                                ),
                                Text('S',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20)),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Complete payment before ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text('${widget.expDate}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'TRANSFER AMOUNT',
                            style:
                                TextStyle(fontSize: 20, color: Colors.black45),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Rp. ' +
                                paymentData['amount_detail']['final_amount'],
                            style: TextStyle(
                                fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Eventevent will automatically check your payment. It may take up to 1 hour to process',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    ],
                  ),
                ),
          howToTab()
        ],
      ),
    );
  }

  Widget howToTab(){
    return Container(
      color: Colors.white,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            TabBar(
              tabs: <Widget>[
                Tab(text: 'BAHASA'),
                Tab(text: 'ENGLISH')
              ],
            ),
            Container(
              color: Colors.white.withOpacity(0.9),
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                children: <Widget> [
                  ListView(
                      children: <Widget> [
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15, top: 15 ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              Text(GOPAY_HEADER_ID, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(GOPAY_HOWTO_LINE1_ID, style: TextStyle(fontSize: 14),),
                            ]
                          ),
                        )
                      ]
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: ListView(
                      children: <Widget> [
                        Padding(
                          padding: EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              Text(GOPAY_HEADER_EN, style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(GOPAY_HOWTO_LINE1_EN, style: TextStyle(fontSize: 14),),
                              
                            ]
                          )
                        )
                      ]
                    )
                  ),
                ]
              ),
            )
          ],
        ),
      ),
    );
  }

  Future getTransactionDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var session;

    setState(() {
      session = prefs.getString('Session');
    });

    String url = BaseApi().apiUrl +
        '/ticket_transaction/detail?transID=${widget.transactionID}&X-API-KEY=${API_KEY}';
    final response = await http.get(url,
        headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session});

    print(response.body);
    print(response.statusCode);

    if (response.statusCode == 200) {
      var extractedData = json.decode(response.body);
      setState(() {
        paymentData = extractedData['data'];
        startCounter(paymentData['expired_time']);
        print(paymentData);
      });
    }
  }

  // gopaySetup(){
  //   final flutrans = Flutrans();
  //   MidtransTransaction transaction;
  //   flutrans.init(CLINET_ID, 'https://home.eventeventapp.com/webhook.midtrans');
  //   flutrans.setFinishCallback(
  //     (TransactionFinished){
  //       //here
  //     }
  //   );
  //   ///flutrans.makePayment(transaction.)
  // }
}