import 'dart:async';
import 'dart:convert';

import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_wowza/gocoder/wowza_gocoder.dart';
import 'package:wakelock/wakelock.dart';

class LivestreamBroadcast extends StatefulWidget {
  final eventDetail;
  final bitrate;

  const LivestreamBroadcast({Key key, this.eventDetail, this.bitrate}) : super(key: key);
  @override
  _LivestreamBroadcastState createState() => _LivestreamBroadcastState();
}

class _LivestreamBroadcastState extends State<LivestreamBroadcast> {
  WOWZCameraController wowzCameraController = WOWZCameraController();
  bool flashLight = false;
  bool isStarting = false;
  String hostAddress = '';
  String appName = '';
  String streamName = '';

  void getWowzaConfigData() {
    hostAddress = widget.eventDetail['livestream'][0]['primary_server']
        .toString()
        .substring(7, 40);
    appName = widget.eventDetail['livestream'][0]['primary_server']
        .toString()
        .substring(41);
    streamName = widget.eventDetail['livestream'][0]['stream_name'];

    print('host address: ' + hostAddress + ' app name: ' + appName);

    wowzCameraController.setWOWZConfig(
      hostAddress: hostAddress,
      portNumber: 1935,
      applicationName: appName,
      streamName: streamName,
      scaleMode: ScaleMode.RESIZE_TO_ASPECT,
      bps: widget.bitrate
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<http.Response> initializeWowzaLivestream() async {
    final response = await http.put(
      BaseApi.wowzaUrl +
          'live_streams/${widget.eventDetail['livestream'][0]['streaming_id']}/start',
      headers: {
        'wsc-api-key': WOWZA_API_KEY,
        'wsc-access-key': WOWZA_ACCESS_KEY,
        'Content-Type': 'application/json'
      },
    );

    print("WOWZA INITIALIZATION PROCESS, PLEASE WAIT.....");
    print(
        "WOWZA RESPONSE: ${response.body} WITH STATUS CODE: ${response.statusCode}");

    return response;
  }

  Future<http.Response> stopWowzaLivestream() async {
    final response = await http.put(
      BaseApi.wowzaUrl +
          'live_streams/${widget.eventDetail['livestream'][0]['streaming_id']}/stop',
      headers: {
        'wsc-api-key': WOWZA_API_KEY,
        'wsc-access-key': WOWZA_ACCESS_KEY,
        'Content-Type': 'application/json'
      },
    );

    print("Stopping WOWZA PROCESS, PLEASE WAIT.....");
    print(
        "WOWZA RESPONSE: ${response.body} WITH STATUS CODE: ${response.statusCode}");

    return response;
  }

  Future<http.Response> getWowzaLivestreamState() async {
    final response = await http.get(
      BaseApi.wowzaUrl +
          'live_streams/${widget.eventDetail['livestream'][0]['streaming_id']}/state',
      headers: {
        'wsc-api-key': WOWZA_API_KEY,
        'wsc-access-key': WOWZA_ACCESS_KEY,
        'Content-Type': 'application/json'
      },
    );

    print("FETCHING CURRENT LIVESTREAM STATE, PLEASE WAIT.....");
    print(
        "WOWZA RESPONSE: ${response.body} WITH STATUS CODE: ${response.statusCode}");

    return response;
  }

  @override
  void initState() {
    Wakelock.enable();
    getWowzaConfigData();
    // initializeWowzaLivestream().then((response) {
    //   if (response.statusCode == 200 || response.statusCode == 201) {}
    // });
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();
    wowzCameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: WOWZCameraView(
                controller: wowzCameraController,
                androidLicenseKey: 'GOSK-A847-010C-B1B7-290A-960F',
                iosLicenseKey: 'GOSK-A847-010C-BD3A-1853-C20A',
                broadcastStatusCallback: (status) {
                  print(status.message);
                  print(status.state);

                  if (status.state == BroadcastState.IDLE_ERROR ||
                      status.state == BroadcastState.BROADCASTING_ERROR ||
                      status.state == BroadcastState.READY_ERROR) {
                    Flushbar(
                      animationDuration: Duration(milliseconds: 500),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                      flushbarPosition: FlushbarPosition.TOP,
                      message: status.message,
                    ).show(context);
                  } else if (status.state == BroadcastState.BROADCASTING) {
                    isStarting = true;
                  }

                  setState(() {});
                },
                statusCallback: (status) {
                  print("test");
                  print(status.mState.toString());
                  print(status.isStarting().toString());
                  print(status.isReady().toString());
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, bottom: 20),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    flashLight = !flashLight;
                    wowzCameraController.flashLight(flashLight);
                    setState(() {});
                  },
                  child: Container(
                      child: Icon(
                    flashLight == false ? Icons.flash_off : Icons.flash_on,
                    color: Colors.white,
                    size: 50,
                  )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    if (isStarting == true) {
                      showCupertinoDialog(
                          context: context,
                          builder: (thisContext) {
                            return CupertinoAlertDialog(
                              title: Text('Warning'),
                              content: Text('Do you want to stop broadcasting?'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    wowzCameraController.endBroadcast();
                                    stopWowzaLivestream().then((response) {
                                      if (response.statusCode == 200 ||
                                          response.statusCode == 201) {
                                        print(
                                            'Stopping livestream succes: ${response.body} With Status Code: ${response.statusCode}');
                                            Navigator.pop(thisContext);
                                            Navigator.pop(context);
                                      }
                                    });
                                  },
                                )
                              ],
                            );
                          });
                    } else {
                      wowzCameraController.startBroadcast();
                    }

                    isStarting = !isStarting;
                    setState(() {});
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: Text(
                          '${isStarting == false ? 'Start' : 'End'} Livestream',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30, bottom: 20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    wowzCameraController.isSwitchCameraAvailable().then(
                      (isSwitchCamAvailable) {
                        if (isSwitchCamAvailable == true) {
                          wowzCameraController.switchCamera();
                        }
                      },
                    );
                  },
                  child: Container(
                      child: Icon(
                    CupertinoIcons.switch_camera,
                    color: Colors.white,
                    size: 50,
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void stopBroadcastDialog() {}
}
