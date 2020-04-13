import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wowza/gocoder/wowza_gocoder.dart';

class LivestreamBroadcast extends StatefulWidget {
  @override
  _LivestreamBroadcastState createState() => _LivestreamBroadcastState();
}

class _LivestreamBroadcastState extends State<LivestreamBroadcast> {
  WOWZCameraController wowzCameraController = WOWZCameraController();
  bool flashLight = false;
  bool isStarting = false;

  @override
  void initState() {
    wowzCameraController.setWOWZConfig(
        hostAddress: "48356e.entrypoint.cloud.wowza.com",
        portNumber: 1935,
        applicationName: "app-7c91",
        streamName: "808362fc",
        scaleMode: ScaleMode.FILL_VIEW);
    super.initState();
  }

  @override
  void dispose() {
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
                    isStarting == true
                        ? wowzCameraController.endBroadcast()
                        : wowzCameraController.startBroadcast();

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
                    wowzCameraController
                        .isSwitchCameraAvailable()
                        .then((isSwitchCamAvailable) {
                      if (isSwitchCamAvailable == true) {
                        wowzCameraController.switchCamera();
                      }
                    });
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
}
