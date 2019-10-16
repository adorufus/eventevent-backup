import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreditCardInput extends StatefulWidget {
  final String transactionID;
  final expDate;

  const CreditCardInput({Key key, this.transactionID, this.expDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CreditCardInputState();
  }
}

class CreditCardInputState extends State<CreditCardInput> {
  String month;
  String hour;
  String min;
  String sec;

  List<RegExp> listOfPattern = new List<RegExp>();

  RegExp visa = new RegExp(r"^4[0-9]$");

  RegExp mastercard = new RegExp(r"^5[1-5]$");

  RegExp discover = new RegExp(r"^6(?:011|5[0-9]{2})$");

  RegExp ameExp = new RegExp(r"^3[47]$");

  Image visaImg;
  Image mastercardImg;
  Image amexImg;
  Image discoverImg;


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

    listOfPattern.add(visa);
    listOfPattern.add(mastercard);
    listOfPattern.add(discover);
    listOfPattern.add(ameExp);

    visaImg = Image.asset('assets/drawable/visa.png');
    mastercardImg = Image.asset('assets/drawable/mastercard.png');
    amexImg = Image.asset('assets/drawable/amex.png');
    discoverImg = Image.asset('assets/drawable/discover.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GestureDetector(
        onTap: () {
          // FlutterGopayMidtrans.configure(
          //   client_id: CLINET_ID,
          //   amount: widget.amount,
          //   deadline: widget.deadline,
          //   gopaytoken: widget.gopaytoken,
          //   merchantUrl: 'https://home.eventeventapp.com/webhook/midtrans/'
          // );
        },
        child: Container(
            height: 50,
            color: Colors.deepOrangeAccent,
            child: Center(
              child: Text(
                'CONFIRM',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            color: eventajaGreenTeal,
          ),
        ),
      ),
      body: paymentData == null
          ? Container()
          : ListView(
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
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Card Number',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Put card number',
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0)))),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Cardholder name',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                              hintText: 'Put card number',
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0))),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0)))),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Expire',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              color: Colors.white,
                              width: 100,
                              child: DropdownButtonFormField<int>(
                                  items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30].map((int value){
                                return new DropdownMenuItem<int>(
                                    value: value,
                                    child: new Text(value.toString())
                                );
                              }).toList(),
                                  decoration: InputDecoration(

                                  ),
                                  hint: Text('Month'),
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              width: 100,
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'Year',
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0)))),
                              ),
                            ),
                            SizedBox(width: 15),
                            Container(
                              color: Colors.white,
                              width: 100,
                              child: TextFormField(
                                decoration: InputDecoration(
                                    hintText: 'CVV',
                                    fillColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(40),
                                        borderSide: BorderSide(
                                            color: Color.fromRGBO(0, 0, 0, 0)))),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Container(),
                Container(),
                Container()
              ],
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
}
