import 'package:eventevent/Widgets/Transaction/Form.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:eventevent/helper/sharedPreferences.dart';

class SelectedTicketQuantityWidget extends StatefulWidget {
  final eventDate;
  final eventName;
  final eventStartTime;
  final eventEndTime;
  final ticketName;
  final eventAddress;
  final eventImage;
  final ticketDetail;
  final thisTicket;
  final ticketPrice;
  final ticketID;
  final ticketType;
  final isSingleTicket;
  final minTicket;

  const SelectedTicketQuantityWidget(
      {Key key,
      this.eventDate,
      this.eventName,
      this.ticketName,
      this.eventAddress,
      this.eventImage,
      this.ticketDetail,
      this.ticketPrice,
      this.ticketID,
      this.ticketType,
      this.eventStartTime,
      this.eventEndTime,
      this.isSingleTicket,
      this.minTicket, this.thisTicket})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SelectedTicketQuantityWidgetState();
  }
}

class _SelectedTicketQuantityWidgetState
    extends State<SelectedTicketQuantityWidget> {
  int ticketCount;
  int priceCount;
  int priceCount2;
  int counterMin, counterMax, counter;

  String price;
  String total;

  Future getPreferences(int counterMin, int counterMax, String price) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      counterMin = int.parse(preferences.getString('Min_Ticket'));
      counterMax = int.parse(preferences.getString('Max_Ticket'));
      price = preferences.getString('Ticket_Price');
      preferences.setString('EventName', widget.eventName);
      preferences.setString('EventImage', widget.eventImage);
      preferences.setString('TicketName', widget.ticketName);
      preferences.setString('EventAddress', widget.eventAddress);
      preferences.setString('EventDate', widget.eventDate);
      preferences.setString('EventStartTime', widget.eventStartTime);
      preferences.setString('EventEndTime', widget.eventEndTime);
      preferences.setString('TicketID', widget.ticketID);
    });

    print(counterMax.toString() + ' ' + counterMin.toString() + ' ' + price);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      ticketCount = int.parse(widget.minTicket);
    });

    getPreferences(counterMin, counterMax, price);
    setPreferences(widget.ticketPrice, ticketCount.toString());
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 1,
          leading: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              size: 30,
              color: eventajaGreenTeal,
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true,
          title: Text(
            'Ticket Quantity',
            style: TextStyle(
                color: eventajaGreenTeal,
                fontSize: ScreenUtil.instance.setSp(25)),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              header(),
              SizedBox(
                height: ScreenUtil.instance.setWidth(50),
              ),
              priceDetail(),
              GestureDetector(
                onTap: () {
                  Map<String, dynamic> prodViewedAction =
                      new Map<String, dynamic>();
                  prodViewedAction['Ticket Name'] = widget.ticketName;
                  prodViewedAction['TiketID'] = widget.ticketID;
                  prodViewedAction['Price'] = widget.ticketPrice;
                  prodViewedAction['Type'] = widget.ticketType;
                  prodViewedAction['Quantity'] = ticketCount;
                  print(prodViewedAction['Type']);

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) => TransactionForm(
                        ticketType: widget.ticketType,
                        eventTicketType: widget.thisTicket['event']
                            ['ticket_type']['type'],
                      ),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: ScreenUtil.instance.setWidth(50),
                  color: Colors.orange,
                  child: Center(
                      child: Text(
                    'BUY TICKET(S)',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(20)),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget priceDetail() {
    return Expanded(
      flex: 2,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: ScreenUtil.instance.setWidth(150),
        color: Colors.white,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Total: ',
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(18),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: ScreenUtil.instance.setWidth(150),
                    ),
                    Text(
                      'Rp' +
                          formatPrice(
                              price:
                                  (int.parse(widget.ticketPrice) * ticketCount)
                                      .toString()),
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(18),
                          fontWeight: FontWeight.bold,
                          color: eventajaGreenTeal),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(15),
              ),
              Divider(
                color: Colors.grey,
                height: ScreenUtil.instance.setWidth(5),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(15),
              ),
              Text(
                'Details',
                style: TextStyle(fontSize: ScreenUtil.instance.setSp(20)),
              ),
              SizedBox(
                height: ScreenUtil.instance.setWidth(10),
              ),
              Text(widget.ticketDetail == null
                  ? '-'
                  : widget.ticketDetail.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      height: ScreenUtil.instance.setWidth(200),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(color: Colors.white, boxShadow: <BoxShadow>[
        BoxShadow(color: Colors.grey, offset: Offset(1, 1), blurRadius: 2)
      ]),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            height: ScreenUtil.instance.setWidth(250),
            width: ScreenUtil.instance.setWidth(110),
            child: Image(
                image: widget.eventImage == 'assets/grey-fade.jpg'
                    ? AssetImage('assets/grey-fade.jpg')
                    : NetworkImage(widget.eventImage.toString()),
                fit: BoxFit.fill),
          ),
          Container(
            height: ScreenUtil.instance.setWidth(250),
            width: ScreenUtil.instance.setWidth(192),
            padding: EdgeInsets.only(right: 10),
            margin: EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.eventDate,
                  style: TextStyle(
                      color: eventajaGreenTeal,
                      fontSize: ScreenUtil.instance.setSp(15)),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(10)),
                Text(
                  widget.eventName,
                  style: TextStyle(
                      fontSize: ScreenUtil.instance.setSp(16),
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(10)),
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: ScreenUtil.instance.setWidth(235),
                    height: ScreenUtil.instance.setWidth(15),
                    child: Text(
                      widget.eventAddress,
                      overflow: TextOverflow.ellipsis,
                    )),
                Divider(
                  color: Colors.grey,
                  height: ScreenUtil.instance.setWidth(5),
                ),
                SizedBox(height: ScreenUtil.instance.setWidth(10)),
                Container(
                    width: 150,
                    child: Text(
                      widget.ticketName,
                      style: TextStyle(
                          fontSize: ScreenUtil.instance.setSp(16),
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                    )),
                SizedBox(height: ScreenUtil.instance.setWidth(10)),
                Container(
                  width: ScreenUtil.instance.setWidth(100),
                  height: ScreenUtil.instance.setWidth(40),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 1.5,
                            color: Color(0xff8a8a8b).withOpacity(0.2),
                            spreadRadius: 2)
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          decrease();
                        },
                        child: Text('-',
                            style: TextStyle(
                                color: ticketCount == 1
                                    ? Colors.grey.withOpacity(0.5)
                                    : Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(25),
                                fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Center(
                          child: Text(
                            ticketCount.toString(),
                            style: TextStyle(
                              fontSize: ScreenUtil.instance.setSp(20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        width: ScreenUtil.instance.setWidth(25),
                      ),
                      GestureDetector(
                          onTap: () {
                            if (widget.isSingleTicket == true) {
                              //do nothing
                            } else {
                              add();
                            }
                          },
                          child: Text(
                            '+',
                            style: TextStyle(
                                color: widget.isSingleTicket == true
                                    ? Colors.grey.withOpacity(0.5)
                                    : Colors.black54,
                                fontSize: ScreenUtil.instance.setSp(25),
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future setPreferences(String priceTotal, String ticketCount) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString('ticket_price_total', priceTotal);
    preferences.setString('ticket_many', ticketCount);
    print("ticket_total: " + preferences.getString('ticket_price_total'));
    print("ticket_many: " + preferences.getString('ticket_many'));
  }

  void add() {
    setState(() {
      ticketCount++;
      total = (int.parse(widget.ticketPrice) * ticketCount).toString();
      setPreferences(total, ticketCount.toString());
      print(total);
    });
  }

  void decrease() {
    setState(() {
      if (ticketCount != int.parse(widget.minTicket)) {
        ticketCount--;
        total = (int.parse(widget.ticketPrice) * ticketCount).toString();
        setPreferences(total, ticketCount.toString());
      }
    });
  }
}
