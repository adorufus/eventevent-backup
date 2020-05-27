import 'dart:convert';

import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/Widgets/TransactionHistory.dart';
import 'package:eventevent/Widgets/dashboardWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/countdownCounter.dart';
import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class WaitingTransactionAlfamart extends StatefulWidget {
  final String transactionID;
  final String expDate;
  final String paymentImage;

  const WaitingTransactionAlfamart(
      {Key key, this.transactionID, this.expDate, this.paymentImage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _WaitingTransactionAlfamartState();
  }
}

class _WaitingTransactionAlfamartState
    extends State<WaitingTransactionAlfamart> {
  String month;
  String hour;
  String min;
  String sec;

  DateTime dateTime;

  int seconds;
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
    getTransactionDetails();
    final salesDay = DateTime.parse(widget.expDate);
    final remaining = salesDay.difference(DateTime.now());
    seconds = remaining.inSeconds;
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
      backgroundColor: Colors.white.withOpacity(0.9),
      // bottomNavigationBar: GestureDetector(
      //   onTap: (){
      //     Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SuccessPage()));
      //   },
      //   child: Container(
      //     height: ScreenUtil.instance.setWidth(50),
      //     width: MediaQuery.of(context).size.width,
      //     color: Colors.orange,
      //     child: Text('test succes page'),
      //   ),
      // ),
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 1,
        leading: GestureDetector(
          onTap: () {

            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => DashboardWidget(isRest: false, selectedPage: 3,)), ModalRoute.withName('/EventDetails'));
            Navigator.push(context, MaterialPageRoute(builder: (context) => TransactionHistory()));
          },
          child: Icon(
            Icons.close,
            size: 35,
            color: eventajaGreenTeal,
          ),
        ),
      ),
      body: paymentData == null
          ? Container(
              child: Center(
                child: CupertinoActivityIndicator(radius: 20),
              ),
            )
          : ListView(
              children: <Widget>[
                Container(
                  height: ScreenUtil.instance.setWidth(459),
                  color: Colors.white,
                  padding: EdgeInsets.only(left: 25, right: 25, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil.instance.setWidth(200),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: eventajaGreenTeal),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Text('Complete Payment In',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.instance.setSp(14),
                                    fontWeight: FontWeight.bold)),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            CountDownTimer(
                              secondsRemaining: seconds,
                              whenTimeExpires: () {

                              },
                              countDownTimerStyle: TextStyle(color: Colors.white, fontSize: ScreenUtil.instance.setSp(38),
                fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('H',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: ScreenUtil.instance.setSp(20))),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(35),
                                ),
                                Text('M',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: ScreenUtil.instance.setSp(20))),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(35),
                                ),
                                Text('S',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: ScreenUtil.instance.setSp(20))),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil.instance.setWidth(20),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Complete payment before ',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                Text('${widget.expDate}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12,
                                        fontWeight: FontWeight.bold))
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil.instance.setWidth(20),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'PAYMENT',
                            style:
                                TextStyle(fontSize: ScreenUtil.instance.setSp(20), color: Colors.black45),
                          ),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          Text(
                            'Rp. ' + paymentData['amount'] == null
                                ? '-'
                                : 'Rp. ' + paymentData['amount'],
                            style: TextStyle(
                                fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          Divider(height: ScreenUtil.instance.setWidth(5), color: Colors.black),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          Container(
                              height: ScreenUtil.instance.setWidth(50),
                              width: ScreenUtil.instance.setWidth(200),
                              child: Image.network(
                                  "https://home.eventeventapp.com/assets/landing/img/payment/" +
                                      paymentData['payment']['icon'])),
                          SizedBox(height: ScreenUtil.instance.setWidth(5)),
                          Text(
                            'Kode pembayaran Alfamart',
                            style: TextStyle(color: Colors.grey, fontSize: ScreenUtil.instance.setSp(12)),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          Text(paymentData['payment_vendor_code'],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil.instance.setSp(25),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                howToTab()
              ],
            ),
    );
  }

  Widget howToTab() {
    return Container(
      color: Colors.white,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            TabBar(
              tabs: <Widget>[Tab(text: 'BAHASA'), Tab(text: 'ENGLISH')],
            ),
            Container(
              color: Colors.white.withOpacity(0.9),
              height: MediaQuery.of(context).size.height,
              child: TabBarView(children: <Widget>[
                ListView(children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 15, top: 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(HEADER_ID,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: ScreenUtil.instance.setWidth(10)),
                          Text(
                            ALFAMART_HOWTO_LINE1_ID +
                                paymentData['payment_vendor_code'],
                            style: TextStyle(fontSize: ScreenUtil.instance.setSp(14)),
                          ),
                          Text(ALFAMART_HOWTO_LINE2_ID)
                        ]),
                  )
                ]),
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: ListView(children: <Widget>[
                      Padding(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, top: 15),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(HEADER_EN,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: ScreenUtil.instance.setWidth(10)),
                                Text(
                                  ALFAMART_HOWTO_LINE1_EN +
                                      paymentData['payment_vendor_code'],
                                  style: TextStyle(fontSize: ScreenUtil.instance.setSp(14)),
                                ),
                                Text(ALFAMART_HOWTO_LINE2_EN)
                              ]))
                    ])),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Future getTransactionDetails() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var session;

    setState(() {
      session = preferences.getString('Session');
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
        //startCounter(paymentData['expired_Date']);
        print(paymentData);
      });
    }
  }
}
