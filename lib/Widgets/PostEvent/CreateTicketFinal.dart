import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:eventevent/Widgets/PostEvent/FinishPostEvent.dart';
import 'package:eventevent/Widgets/PostEvent/PostEventInvitePeople.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTicketFinal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    
    return CreateTicketFinalState();
  }
}

class CreateTicketFinalState extends State<CreateTicketFinal> {
  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();

  String imageUri;
  String ticketQuantity;
  String ticketTypeId;
  String price;
  String finalPrice;
  String merchantPrice;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String desc;
  String ticketPaidBy = 'owner';
  int _curValue = 0;

  File imageFile;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      imageUri = prefs.getString('SETUP_TICKET_POSTER');
      ticketQuantity = prefs.getString('SETUP_TICKET_QTY');
      price = prefs.getString('SETUP_TICKET_PRICE');
      startDate = prefs.getString('SETUP_TICKET_START_DATE');
      endDate = prefs.getString('SETUP_TICKET_END_DATE');
      startTime = prefs.getString('SETUP_TICKET_START_TIME');
      endTime = prefs.getString('SETUP_TICKET_END_TIME');
      desc = prefs.getString('SETUP_TICKET_DESCRIPTION');
      ticketTypeId = prefs.getString('NEW_EVENT_TICKET_TYPE_ID');
      imageFile = new File(imageUri);
    });
  }

  @override
  void initState() {
    
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        key: thisScaffold,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
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
            'REVIEW TICKETS',
            style: TextStyle(color: eventajaGreenTeal),
          ),
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                height: 225,
                                width: 150,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(imageUri),
                                      fit: BoxFit.fill),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Ticket Quantity',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      width: 170,
                                      height: 40,
                                      child: Text(ticketQuantity)),
                                  SizedBox(height: 7),
                                  Text(
                                    'Ticket Sales Starts',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      width: 170,
                                      height: 40,
                                      child: Text(startDate + ' ' + startTime)),
                                  SizedBox(height: 7),
                                  Text(
                                    'Ticket Sales Ends',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                      width: 170,
                                      height: 40,
                                      child: Text(endDate + ' ' + endTime)),
                                ],
                              )
                            ],
                          ),
                        ),
                        Divider(color: Colors.black),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(desc),
                        SizedBox(height: 15),
                        Divider(),
                        SizedBox(height: 15),
                        ticketTypeId == '5' || ticketTypeId == '10' ? Container() : serviceFee(context),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          child: RaisedButton(
                            color: eventajaGreenTeal,
                            onPressed: () {
                              saveFinalData(context);
                            },
                            child: Text(
                              'SUBMIT TICKET',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]))));
  }

  Widget serviceFee(BuildContext context) {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Service Fee'),
        Text('Free applies at 3% or minimum Rp. 5000 / ticket sales.'),
        SizedBox(
          height: 15,
        ),
        Text('Choose who\'s going to pay the fee:'),
        SizedBox(height: 10),
        Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 2),
            color: Colors.white,
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        groupValue: _curValue,
                        onChanged: (int i) => setState(() {
                              _curValue = i;
                            }),
                        value: 0,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Paid by you',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          SizedBox(height: 10),
                          Container(
                              height: 50,
                              child: Text(
                                'eventevent fee will be \npaid by you, \nplease see details.',
                                maxLines: 3,
                                softWrap: true,
                              ))
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/btn_ticket/paid-value.png'),
                                    fit: BoxFit.fill)),
                            child: Center(
                                child: Text(
                              'Rp. ' + price,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Displayed Price',
                            style: TextStyle(color: Colors.grey[300]),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 55,
                      ),
                      Text('Ticket Price    :'),
                      SizedBox(
                        width: 55,
                      ),
                      Text('Rp. ' + price)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 55,
                      ),
                      Text('Fee                 :'),
                      SizedBox(
                        width: 47,
                      ),
                      Text(
                        '- Rp. ' + '5,000',
                        style: TextStyle(color: Colors.red),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 55,
                      ),
                      Text('You\'ll get       :'),
                      SizedBox(
                        width: 55,
                      ),
                      Text(
                        'Rp. ' + (int.parse(price) - 5000).toString(),
                        style: TextStyle(
                            color: eventajaGreenTeal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  )
                ])),
        SizedBox(
          height: 20,
        ),
        Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 2),
            color: Colors.white,
            height: 500,
            width: MediaQuery.of(context).size.width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Radio(
                        groupValue: _curValue,
                        onChanged: (int i) => setState(() {
                              _curValue = i;
                            }),
                        value: 1,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Paid by attendee',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          SizedBox(height: 10),
                          Container(
                              height: 50,
                              child: Text(
                                'eventevent fee will be \npaid by your customers, \nplease see details.',
                                maxLines: 3,
                                softWrap: true,
                              ))
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 40,
                            width: 100,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/btn_ticket/paid-value.png'),
                                    fit: BoxFit.fill)),
                            child: Center(
                                child: Text(
                              'Rp. ' + (int.parse(price) + 5000).toString(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'Displayed Price',
                            style: TextStyle(color: Colors.grey[300]),
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 55,
                      ),
                      Text('Ticket Price    :'),
                      SizedBox(
                        width: 55,
                      ),
                      Text('Rp. ' + price)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 55,
                      ),
                      Text('Fee                 :'),
                      SizedBox(
                        width: 55,
                      ),
                      Text(
                        'Rp. ' + '5,000',
                        style: TextStyle(color: Colors.grey[300]),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 55,
                      ),
                      Text('You\'ll get       :'),
                      SizedBox(
                        width: 55,
                      ),
                      Text(
                        'Rp. ' + (int.parse(price) + 5000).toString(),
                        style: TextStyle(
                            color: eventajaGreenTeal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ]))
      ],
    ));
  }

  Future saveFinalData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String url = BaseApi().apiUrl + '/ticket_setup/post';
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    final request = new http.MultipartRequest("POST", Uri.parse(url));
    request.headers.addAll({
      'Authorization': AUTHORIZATION_KEY,
      'cookie': prefs.getString('Session')
    });

    if(_curValue == 0){
      setState(() {
        ticketPaidBy = 'owner';
        finalPrice = price;
        merchantPrice = price;
      });
    }
    else if(_curValue == 1){
      setState(() {
        ticketPaidBy = 'attandee';
        finalPrice = (int.parse(price) + 5000).toString();
        merchantPrice = price;
      });
    }
    else if(_curValue == 2){
      setState((){
        ticketPaidBy = 'op1';
        finalPrice = (int.parse(price) + 10000).toString();
        merchantPrice = price;
      });
    }

    print(prefs.getString('SETUP_TICKET_NAME'));
    print(prefs.getString('SETUP_TICKET_DESCRIPTION'));
    print(prefs.getString('SETUP_TICKET_QTY'));
    print(prefs.getString('SETUP_TICKET_PRICE'));
    print(prefs.getString('SETUP_TICKET_MIN_BOUGHT'));
    print(prefs.getString('SETUP_TICKET_MAX_BOUGHT'));
    print(prefs.getString('SETUP_TICKET_START_DATE'));
    print(prefs.getString('SETUP_TICKET_START_TIME'));
    print(prefs.getString('SETUP_TICKET_END_DATE'));
    print(prefs.getString('SETUP_TICKET_END_TIME'));
    print(prefs.getString('SETUP_TICKET_SHOW_REMAINING_TICKET'));
    print(ticketPaidBy);
    print(finalPrice);

    request.fields.addAll({
      'X-API-KEY': API_KEY,
      'eventID': prefs.getInt('NEW_EVENT_ID').toString(),
      'ticket_name': prefs.getString('SETUP_TICKET_NAME'),
      'quantity': prefs.getString('SETUP_TICKET_QTY'),
      'price': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
              prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
          ? '0'
          : price,
      'min_ticket': prefs.getString('SETUP_TICKET_MIN_BOUGHT'),
      'max_ticket': prefs.getString('SETUP_TICKET_MAX_BOUGHT'),
      'sales_start_date': prefs.getString('SETUP_TICKET_START_DATE') +
          ' ' +
          prefs.getString('SETUP_TICKET_START_TIME') +
          ':00',
      'sales_end_date': prefs.getString('SETUP_TICKET_END_DATE') +
          ' ' +
          prefs.getString('SETUP_TICKET_END_TIME') +
          ':00',
      'descriptions': prefs.getString('SETUP_TICKET_DESCRIPTION'),
      'show_remaining_ticket':
          prefs.getString('SETUP_TICKET_SHOW_REMAINING_TICKET'),
      'fee_paid_by': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
              prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
          ? ''
          : ticketPaidBy,
      'final_price': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
              prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
          ? '0'
          : finalPrice,
      'paid_ticket_type_id': prefs.getString('SETUP_TICKET_PAID_TICKET_TYPE'),
      'merchant_price': prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '5' ||
              prefs.getString('NEW_EVENT_TICKET_TYPE_ID') == '10'
          ? '0'
          : merchantPrice,
      'is_single_ticket': prefs.getString('SETUP_TICKET_IS_ONE_PURCHASE'),
    });
    request.files.add(new http.MultipartFile('ticket_image', stream, length,
        filename: basename(imageFile.path)));

    request.send().then((response) async {
      print(response.statusCode);
      var myResponse = await http.Response.fromStream(response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(myResponse.body);
        if (prefs.getString('POST_EVENT_TYPE') == '0') {
          setState(() {
            var extractedData = json.decode(myResponse.body);
          });
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (BuildContext context) => FinishPostEvent()));
        } else {
          print(myResponse.body);
          setState(() {
            var extractedData = json.decode(myResponse.body);
          });
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (BuildContext context) => PostEventInvitePeople()));
        }
      }
      else{
        print(myResponse.body);
      }
    });
  }
}
