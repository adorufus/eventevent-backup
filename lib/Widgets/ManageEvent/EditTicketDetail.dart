import 'dart:io';

import 'package:eventevent/Widgets/ManageEvent/EditTicket.dart';
import 'package:eventevent/helper/DateTimeConverter.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditTicketDetail extends StatefulWidget {
  final ticketTitle;
  final ticketImage;
  final ticketQuantity;
  final ticketSalesStartDate;
  final ticketSalesEndDate;
  final eventStartDate;
  final eventEndDate;
  final eventStartTime;
  final eventEndTime;
  final ticketDescription;
  final Map ticketDetail;

  const EditTicketDetail({Key key, this.ticketTitle, this.ticketImage, this.ticketQuantity, this.ticketSalesStartDate, this.ticketSalesEndDate, this.eventStartDate, this.eventEndDate, this.eventStartTime, this.eventEndTime, this.ticketDescription, this.ticketDetail}) : super(key: key);

  @override
  _EditTicketDetailState createState() => _EditTicketDetailState();
}

class _EditTicketDetailState extends State<EditTicketDetail> {
  GlobalKey<ScaffoldState> thisScaffold = new GlobalKey<ScaffoldState>();
  DateTimeConverter dateTimeConverter = new DateTimeConverter();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: thisScaffold,
        backgroundColor: Colors.white.withOpacity(.5),
        appBar: AppBar(
          brightness: Brightness.light,
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
            widget.ticketTitle,
            style: TextStyle(color: eventajaGreenTeal),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            
          },
          child: Container(
            height: 60,
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  blurRadius: 2,
                  spreadRadius: 1.5,
                  color: Color(0xff8a8a8b).withOpacity(.3),
                  offset: Offset(0, -1))
            ]),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              height: ScreenUtil.instance.setWidth(50),
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(50),
                child: RaisedButton(
                  color: eventajaGreenTeal,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => EditTicket(ticketDetail: widget.ticketDetail,)));
                  },
                  child: Text(
                    'Edit Ticket',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15),
                          ),
                          Container(
                            height: ScreenUtil.instance.setWidth(250),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: ScreenUtil.instance.setWidth(225),
                                  width: ScreenUtil.instance.setWidth(150),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(widget.ticketImage,
                                        fit: BoxFit.fill),
                                  ),
                                ),
                                SizedBox(
                                  width: ScreenUtil.instance.setWidth(20),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Ticket Quantity',
                                      style: TextStyle(
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                        width:
                                            ScreenUtil.instance.setWidth(170),
                                        height:
                                            ScreenUtil.instance.setWidth(40),
                                        child: Text(widget.ticketQuantity)),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(7)),
                                    Text(
                                      'Ticket Sales Starts',
                                      style: TextStyle(
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                        width:
                                            ScreenUtil.instance.setWidth(170),
                                        height:
                                            ScreenUtil.instance.setWidth(40),
                                        child:
                                            Text(DateTimeConverter.convertToNamedMonth(DateTime.parse(widget.ticketSalesStartDate), ' '))),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(7)),
                                    Text(
                                      'Ticket Sales Ends',
                                      style: TextStyle(
                                          fontSize:
                                              ScreenUtil.instance.setSp(18),
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            ScreenUtil.instance.setWidth(10)),
                                    Container(
                                        width:
                                            ScreenUtil.instance.setWidth(170),
                                        height:
                                            ScreenUtil.instance.setWidth(40),
                                        child: Text(DateTimeConverter.convertToNamedMonth(DateTime.parse(widget.ticketSalesEndDate), ' '))),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Divider(color: Colors.black),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15),
                          ),
                          Row(
                            children: <Widget>[
                              Text('Event Date: '),
                              Expanded(child: SizedBox(),),
                              Text(DateTimeConverter.convertToNamedMonth(DateTime.parse(widget.eventStartDate), ' ') + ' - ' + DateTimeConverter.convertToNamedMonth(DateTime.parse(widget.eventEndDate), ' '))
                            ],
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(8),
                          ),
                          Row(
                            children: <Widget>[
                              Text('Event Time: '),
                              Expanded(child: SizedBox(),),
                              Text(widget.eventStartTime + ' - ' + widget.eventEndTime)
                            ],
                          ),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15),
                          ),
                          Divider(color: Colors.black),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15),
                          ),
                          Text(
                            'Description',
                            style: TextStyle(
                                fontSize: ScreenUtil.instance.setSp(18),
                                color: Colors.black54,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(widget.ticketDescription),
                          SizedBox(height: ScreenUtil.instance.setWidth(15)),
                          Divider(),
                          SizedBox(
                            height: ScreenUtil.instance.setWidth(15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}