import 'dart:convert';

import 'package:eventevent/Widgets/ProfileWidget/ScanBarcode.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsWidget.dart';
import 'package:eventevent/Widgets/ProfileWidget/UseTicketSuccess.dart';
import 'package:eventevent/Widgets/Transaction/SuccesPage.dart';
import 'package:eventevent/Widgets/openMedia.dart';
import 'package:eventevent/helper/API/apiHelper.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:eventevent/helper/WebView.dart';
import 'package:eventevent/helper/colorsManagement.dart';
import 'package:eventevent/helper/countdownCounter.dart';
import 'package:eventevent/livestream/LivestreamPlayer.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:eventevent/Widgets/ProfileWidget/SettingsComponent/ZoomTicketPage.dart';

class UseTicket extends StatefulWidget {
  final ticketTitle;
  final ticketImage;
  final ticketDate;
  final ticketCode;
  final ticketStartTime;
  final ticketEndTime;
  final ticketDesc;
  final ticketID;
  final eventId;
  final usedStatus;
  final livestreamUrl;
  final zoomId;
  final zoomDesc;
  final playbackUrl;
  final Map ticketDetail;

  const UseTicket({
    Key key,
    this.ticketTitle,
    this.ticketImage,
    this.ticketDate,
    this.ticketCode,
    this.ticketStartTime,
    this.ticketEndTime,
    this.ticketDesc,
    this.ticketID,
    this.eventId,
    this.usedStatus,
    this.livestreamUrl,
    this.zoomId,
    this.zoomDesc,
    this.playbackUrl,
    this.ticketDetail,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UseTicketState();
  }
}

class UseTicketState extends State<UseTicket> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  String _scanBarcode = '';
  Future<String> _barcodeString;

  DateTime startDate;
  int seconds;

  @override
  void initState() {
    startDate =
        DateTime.parse('${widget.ticketDate} ${widget.ticketStartTime}');
    final remaining = startDate.difference(DateTime.now());
    seconds = remaining.inSeconds;
    print("type: " + widget.usedStatus);
    print("in seconds" + seconds.toString());
    print('live url ' + widget.livestreamUrl.toString());
    setState(() {});
    super.initState();
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
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        brightness: Brightness.light,
        elevation: 0,
        backgroundColor: Colors.white,
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
        onTap: widget.usedStatus == 'Used'
            ? () {}
            : startDate.isAfter(DateTime.now()) &&
                    widget.usedStatus != 'On Demand Video'
                ? () {
                    print("ended");
                  }
                : widget.usedStatus == 'Streaming' ||
                        widget.usedStatus == 'On Demand Video' ||
                        widget.usedStatus == 'Watch Playback' ||
                        widget.usedStatus == 'Playback' ||
                        widget.usedStatus == 'Expired'
                    ? DateTime.parse(widget.ticketDetail['event']['dateEnd'])
                                .isBefore(DateTime.now()) &&
                            widget.ticketDetail['livestream']['playback_url'] ==
                                'not_available' &&
                            widget.usedStatus == 'Watch Playback'
                        ? () {
                            showCupertinoDialog(
                                context: context,
                                builder: (thisContext) {
                                  return CupertinoAlertDialog(
                                    title: Text('Notice'),
                                    content: Text(
                                      'playback not available yet, it my takes 1-2 hours for playback to be available',
                                    ),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: Text('Close'),
                                        onPressed: () {
                                          Navigator.of(thisContext).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          }
                        : widget.usedStatus != "On Demand Video" &&
                                    widget.zoomId != null ||
                                widget.zoomId != ""
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ZoomTicketPage(
                                        zoomLink: widget.zoomId,
                                        zoomDesc: widget.zoomDesc),
                                  ),
                                );
                              }
                            : () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                print(prefs.getString("streaming_token"));

                                // if (prefs.containsKey('streaming_token') &&
                                //     prefs.getString('streaming_token') !=
                                //         null) {
                                //   print(prefs.getString('streaming_token'));
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => LivestreamPlayer(
                                //         wowzaLiveUrl: widget.livestreamUrl,
                                //       ),
                                //     ),
                                //   );
                                // } else {
                                print(prefs.getString('streaming_token'));
                                getWatchLivestreamToken(widget.eventId)
                                    .then((response) async {
                                  print('code: ' +
                                      response.statusCode.toString() +
                                      ' message: ' +
                                      response.body);
                                  var extractedData =
                                      json.decode(response.body);

                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    prefs.setString(
                                        'streaming_token',
                                        extractedData['data']
                                            ['streaming_token']);
                                    // getEventStreamingDetail();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LivestreamPlayer(
                                          wowzaLiveUrl: widget.livestreamUrl,
                                        ),
                                      ),
                                    );
                                  } else {
                                    prefs.setString('streaming_token', null);
                                    Flushbar(
                                      animationDuration:
                                          Duration(milliseconds: 500),
                                      duration: Duration(seconds: 3),
                                      backgroundColor: Colors.red,
                                      message: 'User Have No Access!',
                                      flushbarPosition: FlushbarPosition.TOP,
                                    ).show(context);
                                  }
                                });
                                // }
                              }
                    : widget.usedStatus == 'Expired' ||
                            widget.usedStatus == 'Expired Zoom Session'
                        ? () {
                            print('expired');
                          }
                        : () {
                            scan().then((_) async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String url = BaseApi().apiUrl + '/tickets/verify';

                              final response = await http.post(url, headers: {
                                'Authorization': AUTHORIZATION_KEY,
                                'cookie': prefs.getString('Session')
                              }, body: {
                                'X-API-KEY': API_KEY,
                                'qrData': _scanBarcode,
                                'ticketID': widget.ticketID
                              });

                              var extractedData = json.decode(response.body);

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                print(extractedData['desc']);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            UseTicketSuccess(
                                              eventName: 'test',
                                            )));
                              } else {
                                Flushbar(
                                  flushbarPosition: FlushbarPosition.TOP,
                                  message: extractedData['desc'] ??
                                      extractedData['error'],
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 3),
                                  animationDuration:
                                      Duration(milliseconds: 500),
                                )..show(context);
                              }

                              //Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => SettingsWidget()));
                            });
//          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ScanBarcode()));
                          },
        child: Container(
          height: ScreenUtil.instance.setWidth(50),
          color: widget.usedStatus == 'Used'
              ? Colors.grey
              : widget.usedStatus == 'Expired' ||
                      widget.usedStatus == 'Expired Zoom Session'
                  ? Colors.red
                  : Colors.orange,
          child: Center(
            child: widget.usedStatus == 'Streaming' &&
                    startDate.isAfter(DateTime.now())
                ? CountDownTimer(
                    secondsRemaining: seconds,
                    useHHMMSS: true,
                    whenTimeExpires: () {},
                    countDownTimerStyle: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenUtil.instance.setSp(20),
                        fontWeight: FontWeight.bold),
                    isDay: false,
                  )
                : Text(
                    widget.usedStatus == 'Used'
                        ? 'USED'
                        : widget.usedStatus == 'Expired'
                            ? !widget.ticketDetail.containsKey('livestream')
                                ? 'EXPIRED'
                                : widget.zoomId != null
                                    ? 'Zoom Session Ended'
                                    : 'Watch Playback'
                            : widget.usedStatus == 'Expired Zoom Session'
                                ? 'Zoom Session Ended'
                                : widget.usedStatus == 'Playback'
                                    ? 'Watch Playback'
                                    : widget.usedStatus == 'On Demand Video'
                                        ? 'Watch On Demand Video'
                                        : widget.usedStatus == 'Streaming'
                                            ? widget.zoomId != null ||
                                                    widget.zoomId != "" ||
                                                    widget.zoomDesc != null ||
                                                    widget.zoomDesc != ""
                                                ? 'Get Zoom Link Here'
                                                : 'Watch Livestream'
                                            : widget.usedStatus ==
                                                    'Watch Playback'
                                                ? 'Watch Playback'
                                                : 'USE TICKET',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ScreenUtil.instance.setSp(20)),
                  ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Container(
            foregroundDecoration: BoxDecoration(
                backgroundBlendMode: widget.usedStatus == 'Available' ||
                        widget.usedStatus == 'Streaming' ||
                        widget.usedStatus == 'On Demand Video'
                    ? null
                    : BlendMode.saturation,
                color: widget.usedStatus == 'Available' ||
                        widget.usedStatus == 'Streaming' ||
                        widget.usedStatus == 'On Demand Video'
                    ? null
                    : Colors.grey),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            margin: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 5,
                            spreadRadius: 2,
                            color: Color(0xff8a8a8b).withOpacity(.6))
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      child:
                          Image.network(widget.ticketImage, fit: BoxFit.fill)),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: ScreenUtil.instance.setWidth(150),
                    width: MediaQuery.of(context).size.width,
                    // color: Colors.white,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5,
                              spreadRadius: 2,
                              color: Color(0xff8a8a8b).withOpacity(.3))
                        ],
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15))),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // SizedBox(height: ScreenUtil.instance.setWidth(15)),
                        // Text(
                        //   widget.ticketDate,
                        //   style: TextStyle(color: eventajaGreenTeal),
                        // ),
                        SizedBox(height: ScreenUtil.instance.setWidth(10)),
                        Text(widget.ticketTitle,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        SizedBox(height: ScreenUtil.instance.setWidth(10)),
                        Text(widget.ticketCode,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: ScreenUtil.instance.setSp(24))),
                        SizedBox(height: ScreenUtil.instance.setWidth(10)),
                        Text(
                          widget.ticketStartTime.toString() +
                              ' - ' +
                              widget.ticketEndTime.toString(),
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: ScreenUtil.instance.setWidth(10)),
                        Text(widget.ticketDesc)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//  scan2(){
//    setState(() {
//      _barcodeString = new QRCodeReader()
//          .setAutoFocusIntervalInMs(200)
//          .setForceAutoFocus(true)
//          .setTorchEnabled(false)
//          .setHandlePermissions(true)
//          .setExecuteAfterPermissionGranted(true)
//          .scan();
//    });
//
//    print(_barcodeString);
//  }

  Future<void> scan() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#00DE91", "Cancel", false, ScanMode.QR);
    } catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });

    print(_scanBarcode);
  }
}
