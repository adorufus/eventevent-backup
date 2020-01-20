import 'dart:convert';

import 'package:eventevent/Widgets/RecycleableWidget/WaitTransaction.dart';
import 'package:eventevent/Widgets/Transaction/Alfamart/WaitingTransactionAlfamart.dart';
import 'package:eventevent/Widgets/Transaction/BCA/InputBankData.dart';
import 'package:eventevent/Widgets/Transaction/CC.dart';
import 'package:eventevent/Widgets/Transaction/GOPAY/WaitingGopay.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProcessingPayment extends StatefulWidget {
  final uuid;
  final isCustomForm;
  final ticketType;
  final customFormId;
  final customFormList;
  final total;

  const ProcessingPayment({Key key, this.uuid, this.isCustomForm, this.ticketType, this.customFormId, this.customFormList, this.total}) : super(key: key);

  @override
  _ProcessingPaymentState createState() => _ProcessingPaymentState();
}

class _ProcessingPaymentState extends State<ProcessingPayment> {

  bool isLoading = false;

  Map<String, dynamic> paymentData;
  String expDate;

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
  
  @override
  void initState() {
    postPurchaseTicket();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: CupertinoActivityIndicator(
            radius: 15,
            animating: true,
          ),
        ),
      ),
    );
  }
}