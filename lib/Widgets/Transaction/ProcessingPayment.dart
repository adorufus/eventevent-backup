import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eventevent/Widgets/PostEvent/CreateTicketName.dart';
import 'package:eventevent/Widgets/PostEvent/FinishPostEvent.dart';
import 'package:eventevent/Widgets/PostEvent/PostEventInvitePeople.dart';
import 'package:eventevent/Widgets/RecycleableWidget/WaitTransaction.dart';
import 'package:eventevent/Widgets/Transaction/Alfamart/WaitingTransactionAlfamart.dart';
import 'package:eventevent/Widgets/Transaction/BCA/InputBankData.dart';
import 'package:eventevent/Widgets/Transaction/CC.dart';
import 'package:eventevent/Widgets/Transaction/GOPAY/WaitingGopay.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProcessingPayment extends StatefulWidget {
  //if the loading from payment
  final uuid;
  final isCustomForm;
  final ticketType;
  final customFormId;
  final customFormList;
  final total;

  final loadingType;

  //if the loading from create event
  final imageFile;
  final isPrivate;
  final index;
  final context;

  const ProcessingPayment(
      {Key key,
      this.uuid,
      this.isCustomForm,
      this.ticketType,
      this.customFormId,
      this.customFormList,
      this.total,
      this.loadingType,
      this.imageFile,
      this.isPrivate,
      this.index,
      this.context})
      : super(key: key);

  @override
  _ProcessingPaymentState createState() => _ProcessingPaymentState();
}

class _ProcessingPaymentState extends State<ProcessingPayment> {
  bool isLoading = false;

  Map<String, dynamic> paymentData;
  String expDate;

  Dio dio = new Dio(BaseOptions(
      connectTimeout: 10000, baseUrl: BaseApi().apiUrl, receiveTimeout: 10000));
  FormData formData = new FormData();

  double progress = 0;

  Future getPaymentData(String expired) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('expDate', expired);

    var expiredDate = preferences.getString('expDate');

    expDate = expiredDate;
    print(expDate);
  }

  Future<Null> postPurchaseTicket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var session;

    setState(() {
      session = prefs.getString('Session');
    });

    Map<String, dynamic> body = {
      'X-API-KEY': API_KEY,
      'ticketID': prefs.getString('TicketID'),
      'quantity': prefs.getString('ticket_many'),
      'firstname': prefs.getString('ticket_about_firstname'),
      'lastname': prefs.getString('ticket_about_lastname'),
      'email': prefs.getString('ticket_about_email'),
      'phone': prefs.getString('ticket_about_phone'),
      'note': prefs.getString('ticket_about_aditional'),
      'payment_method_id': prefs.getString('payment_method_id'),
      'identifier': widget.uuid.v4().toString(),
    };

    Map<String, dynamic> bodyFreeLimit = {
      'X-API-KEY': API_KEY,
      'ticketID': prefs.getString('TicketID'),
      'quantity': prefs.getString('ticket_many'),
      'firstname': prefs.getString('ticket_about_firstname'),
      'lastname': prefs.getString('ticket_about_lastname'),
      'email': prefs.getString('ticket_about_email'),
      'phone': prefs.getString('ticket_about_phone'),
      'note': prefs.getString('ticket_about_aditional'),
      'identifier': widget.uuid.v4().toString(),
    };

    if (widget.isCustomForm == true) {
      for (int i = 0; i < widget.customFormId.length; i++) {
        body['form[$i][id]'] = widget.customFormId[i];
        bodyFreeLimit['form[$i][id]'] = widget.customFormId[i];
      }

      for (int i = 0; i < widget.customFormList.length; i++) {
        body['form[$i][answer]'] = widget.customFormList[i];
        bodyFreeLimit['form[$i][answer]'] = widget.customFormList[i];
      }
    }

    if (widget.ticketType == 'free_limited') {
      print(bodyFreeLimit);
    } else {
      print(body);
    }

    // for(int i = 0; i < widget.customForm.length; i++){
    //   var customForm = widget.customForm;
    //   bodyFreeLimit.putIfAbsent('form[$i][id]', customForm[i]['id']);
    //   bodyFreeLimit.putIfAbsent('form[$i][answer]', customForm[i]['answer']);
    // }

    String purchaseUri = BaseApi().apiUrl + '/ticket_transaction/post';

    setState(() {
      isLoading = true;
    });

    final response = await http.post(purchaseUri,
        headers: {'Authorization': AUTHORIZATION_KEY, 'cookie': session},
        body: widget.ticketType == 'free_limited' ? bodyFreeLimit : body);

    var length = response.contentLength;
    var recieved = 0;

    print('content length' + length.toString());

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      print('mantab gan');
      print(response.body);
      var extractedData = json.decode(response.body);
      setState(() {
        isLoading = false;
        paymentData = extractedData['data'];
        print(paymentData['expired_time']);
        getPaymentData(paymentData['expired_time']);
      });
      if (widget.ticketType == 'free_limited') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => SuccessPage()));
      } else if (paymentData['payment_method_id'] == '1') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => CreditCardInput(
                      transactionID: paymentData['id'],
                      expDate: paymentData['expired_time'],
                    )));
      } else if (paymentData['payment_method_id'] == '4') {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => WaitingGopay(
                    amount: paymentData['amount'],
                    deadline: paymentData['expired_time'],
                    gopaytoken: paymentData['gopay'],
                    expDate: paymentData['expired_time'],
                    transactionID: paymentData['id'],
                  )),
        );
      } else if (paymentData['payment_method_id'] == '2') {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => WaitTransaction(
                  expDate: paymentData['expired_time'],
                  transactionID: paymentData['id'],
                  finalPrice: widget.total.toString())),
        );
      } else if (paymentData['payment_method_id'] == '3') {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => WaitingTransactionAlfamart(
                    transactionID: paymentData['id'],
                    expDate: paymentData['expired_time'],
                  )),
        );
      } else if (paymentData['payment_method_id'] == '5') {
//        launch(paymentData['payment']['data_vendor']['payment_url']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WebViewTest(
                      url: paymentData['payment']['data_vendor']['payment_url'],
                    )));
      } else if (paymentData['payment_method_id'] == '9') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => WebViewTest(
                  url: paymentData['payment']['data_vendor']['invoice_url'],
                )));
      } else if (paymentData['payment_method_id'] == '7') {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (BuildContext context) => PaymentBCA(
                    expDate: paymentData['expired_time'],
                    transactionID: paymentData['id'],
                  )),
        );
      }
    }
  }

  Future postEvent(int index, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Cookie cookie = Cookie.fromSetCookieValue(prefs.getString('Session'));

    print(lookupMimeType(widget.imageFile.path));

    try {
      Map<String, dynamic> body = {
        'X-API-KEY': API_KEY,
        'eventTypeID':
            (int.parse(prefs.getString('POST_EVENT_TYPE')) + 1).toString(),
        'ticketTypeID': widget.ticketType[index]['id'],
        'name': prefs.getString('POST_EVENT_NAME'),
        'address': prefs.getString('CREATE_EVENT_LOCATION_ADDRESS'),
        'latitude': prefs.getString('CREATE_EVENT_LOCATION_LAT'),
        'longitude': prefs.getString('CREATE_EVENT_LOCATION_LONG'),
        'dateStart': prefs.getString('POST_EVENT_START_DATE'),
        'timeStart': prefs.getString('POST_EVENT_START_TIME'),
        'dateEnd': prefs.getString('POST_EVENT_END_DATE'),
        'timeEnd': prefs.getString('POST_EVENT_END_TIME'),
        'description': prefs.getString('CREATE_EVENT_DESCRIPTION'),
        'phone': prefs.getString('CREATE_EVENT_TELEPHONE'),
        'email': prefs.getString('CREATE_EVENT_EMAIL'),
        'website': prefs.getString('CREATE_EVENT_WEBSITE'),
        'isPrivate': prefs.getString('POST_EVENT_TYPE'),
        'modifiedById': prefs.getString('Last User ID'),
        'photo': UploadFileInfo(
            widget.imageFile, "eventevent-${DateTime.now().toString()}.jpg",
            contentType: ContentType('image', 'jpeg'))
      };

      List categoryList = prefs.getStringList('POST_EVENT_CATEGORY_ID');
      print(categoryList);

      for (int i = 0; i < categoryList.length; i++) {
        setState(() {
          body['category[$i]'] = categoryList[i];
        });
      }

      var data = FormData.from(body);
      Response response = await dio.post('/event/create',
          options: Options(headers: {
            'Authorization': AUTHORIZATION_KEY,
            'cookie': prefs.getString('Session')
          }, cookies: [
            cookie
          ], responseType: ResponseType.plain),
          data: data, onSendProgress: (sent, total) {
        print(
            'data uploaded: ' + sent.toString() + ' from ' + total.toString());
        setState(() {
          progress = ((sent / total) * 100);
          print(progress);
        });
      });

      var extractedData = json.decode(response.data);

      if (response.statusCode == 400) {
        print(response.data);
      } else if (response.statusCode == 201 || response.statusCode == 200) {
        print(response.data);
        print('ini untuk setup ticket');
        print(widget.ticketType[index]['id']);
        if (widget.ticketType[index]['isSetupTicket'] == '1') {
          print('paid: ' + response.data);

          setState(() {
            prefs.setString('SETUP_TICKET_PAID_TICKET_TYPE',
                widget.ticketType[index]['paid_ticket_type']['id']);
            prefs.setString(
                'NEW_EVENT_TICKET_TYPE_ID', widget.ticketType[index]['id']);
            prefs.setInt('NEW_EVENT_ID', extractedData['data']['id']);
          });
          Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) => CreateTicketName()));
        } else {
          if (widget.isPrivate == '0') {
            if (widget.ticketType[index]['id'] == '1' ||
                widget.ticketType[index]['2'] ||
                widget.ticketType[index]['3']) {
              print('non Paid: ' + response.data);
              setState(() {
                var extractedData = json.decode(response.data);
                prefs.setString(
                    'NEW_EVENT_TICKET_TYPE_ID', widget.ticketType[index]['id']);
                prefs.setInt('NEW_EVENT_ID', extractedData['data']['id']);
              });
              Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => FinishPostEvent()));
            }
          } else {
            print(widget.ticketType[index]['id']);
            if (widget.ticketType[index]['id'] == '1' ||
                widget.ticketType[index]['id'] == '2' ||
                widget.ticketType[index]['id'] == '3') {
              print('non paid: ' + response.data);
              setState(() {
                var extractedData = json.decode(response.data);
                prefs.setString(
                    'NEW_EVENT_TICKET_TYPE_ID', widget.ticketType[index]['id']);
                prefs.setInt('NEW_EVENT_ID', extractedData['data']['id']);
              });
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => PostEventInvitePeople()));
            }
          }
        }
      }
    } catch (e) {
      if (e is DioError) {
        print(e.message);
      }
      if (e is FileSystemException){
        print(e.message);
      }
    }
  }

  @override
  void initState() {
    if (widget.loadingType == 'create event') {
      postEvent(widget.index, context);
    } else {
      postPurchaseTicket();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: widget.loadingType == 'create event'
              ? Container(
                  width: 200,
                  height: 20,
                  child: LiquidLinearProgressIndicator(
                    backgroundColor: Color(0xff8a8a8b),
                    valueColor: AlwaysStoppedAnimation(eventajaGreenTeal),
                    direction: Axis.horizontal,
                    value: progress,
                    center: Text(
                      "Uploading: ${progress.toStringAsFixed(0)}%",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : CupertinoActivityIndicator(
                  radius: 15,
                  animating: true,
                ),
        ),
      ),
    );
  }
}