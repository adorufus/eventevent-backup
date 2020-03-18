import 'dart:async';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eventevent/helper/ColumnBuilder.dart';

class ShowQr extends StatefulWidget {
  final qrUrl;
  final eventName;

  const ShowQr({Key key, this.qrUrl, this.eventName}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return ShowQrState();
  }
}

class ShowQrState extends State<ShowQr> {
  TextEditingController searchController = new TextEditingController();
  String qrUri;
  String name;
  int total_user_have_ticket = 0;
  int total_user_checkin = 0;
  Timer refreshEverySecond;

  List checkinList = [];

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      qrUri = widget.qrUrl;
      name = widget.eventName;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();

    refreshEverySecond = Timer.periodic(Duration(seconds: 1), (Timer t) {
      fetchData();
    });
  }

  @override
  void dispose() {
    refreshEverySecond.cancel();
    super.dispose();
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Icon(
          Icons.arrow_back_ios,
          color: eventajaGreenTeal,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'SCAN THIS QR CODE FOR ENTRY',
          style: TextStyle(
              color: eventajaGreenTeal,
              fontSize: ScreenUtil.instance.setSp(14)),
        ),
        actions: <Widget>[
          Icon(
            Icons.help_outline,
            color: eventajaGreenTeal,
            size: 25,
          ),
          SizedBox(
            width: ScreenUtil.instance.setWidth(13),
          ),
          GestureDetector(
              onTap: () {
                ShareExtend.share(qrUri, 'text');
              },
              child: Icon(
                CupertinoIcons.share,
                color: eventajaGreenTeal,
                size: 25,
              )),
          SizedBox(
            width: ScreenUtil.instance.setWidth(13),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    offset: Offset(0, 1), color: Colors.grey, blurRadius: 5)
              ]),
              height: ScreenUtil.instance.setWidth(380),
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(alignment: Alignment.center, children: <Widget>[
                    Container(
                      height: ScreenUtil.instance.setWidth(300),
                      width: ScreenUtil.instance.setWidth(300),
                      child: Image.network(qrUri),
                    )
                  ]),
                  SizedBox(
                    height: ScreenUtil.instance.setWidth(15),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                        color: eventajaGreenTeal,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(18)),
                  ),
                  total_user_checkin == 0
                      ? Container()
                      : Text(
                          'Check-In: $total_user_checkin / $total_user_have_ticket')
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(10),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Material(
                borderRadius: BorderRadius.circular(40),
                elevation: 1,
                shadowColor: Colors.grey,
                child: TextFormField(
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        child: Icon(
                          Icons.close,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          if (searchController.text.isNotEmpty) {
                            searchController.text = '';
                          }
                        },
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 30,
                        color: Colors.grey,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                      hintText: 'Search People Checkins',
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              BorderSide(color: Color.fromRGBO(0, 0, 0, 0))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              BorderSide(color: Color.fromRGBO(0, 0, 0, 0)))),
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil.instance.setWidth(15),
            ),
            checkinList == null
                ? Container()
                : ColumnBuilder(
                    itemCount: checkinList == null ? 0 : checkinList.length,
                    itemBuilder: (BuildContext context, i) {
                      var time = DateTime.parse(checkinList[i]['checkinTime']);
                      print(time);

                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: ScreenUtil.instance.setWidth(80),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        padding: EdgeInsets.only(left: 10, right: 0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                  checkinList[i]['user']['pictureAvatarURL']),
                              radius: 25,
                            ),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(15),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  checkinList[i]['user']['fullName'],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: ScreenUtil.instance.setSp(18)),
                                ),
                                Text(checkinList[i]['ticket_name'],
                                    style: TextStyle(color: Colors.grey)),
                                Text(checkinList[i]['ticket_code'],
                                    style: TextStyle(
                                        color: eventajaGreenTeal,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(
                              width: ScreenUtil.instance.setWidth(60),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.check,
                                  color: eventajaGreenTeal,
                                  size: 30,
                                ),
                                Text(
                                  'CHECK IN',
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(10),
                                      color: Colors.grey),
                                ),
                                Text(
                                  time.hour.toString() +
                                      ':' +
                                      time.minute.toString(),
                                  style: TextStyle(
                                      fontSize: ScreenUtil.instance.setSp(10),
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }

  Future fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String url = BaseApi().apiUrl +
        '/event/checkin?X-API-KEY=$API_KEY&eventID=${prefs.getString('NEW_EVENT_ID')}';

    var response = await http.get(
      url,
      headers: {
        'Authorization': AUTHORIZATION_KEY,
        'cookie': prefs.getString('Session')
      },
    );

    print(response.statusCode);
    print('result: ' + response.body);

    if (response.statusCode == 200) {
      if (!mounted) return;

      setState(() {
        var extractedData = json.decode(response.body);
        if (extractedData['total_user_checkin'] == null) {
          total_user_checkin = 0;
        } else {
          total_user_checkin = extractedData['total_user_checkin'];
          total_user_have_ticket = extractedData['total_user_have_ticket'];
        }
        checkinList = extractedData['data'];
      });
    }
  }
}
