import 'dart:async';

import 'package:camera_with_rtmp/camera.dart';
import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_wowza/gocoder/wowza_gocoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:torch_compat/torch_compat.dart';
import 'package:wakelock/wakelock.dart';

class LivestreamBroadcast extends StatefulWidget {
  final eventDetail;
  final bitrate;

  const LivestreamBroadcast({Key key, this.eventDetail, this.bitrate})
      : super(key: key);
  @override
  _LivestreamBroadcastState createState() => _LivestreamBroadcastState();
}

IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError("Unknown lens direction");
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _LivestreamBroadcastState extends State<LivestreamBroadcast> with WidgetsBindingObserver {
  WOWZCameraController wowzCameraController = WOWZCameraController();
  CameraController cameraController;
  ResolutionPreset resolutionPreset = ResolutionPreset.high;
  List<CameraDescription> cameras;
  bool flashLight = false;
  bool isStarting = false;
  bool isRear = true;
  bool isStopped = false;
  String hostAddress = '';
  String appName = '';
  String streamName = '';
  String statusText = 'idle';

  Future getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    print(statuses[Permission.microphone]);
  }

  Future<List<CameraDescription>> getAvailableCamera() async {
    try {
      cameras = await availableCameras();
      return cameras;
    } on CameraException catch (e) {
      print('code:  ${e.code} message: ${e.description}');
      return null;
    }
  }

  void setupLivestreamCamera(CameraDescription description) {
    if (widget.bitrate == 1000) {
      resolutionPreset = ResolutionPreset.high;
    } else if (widget.bitrate == 2500) {
      resolutionPreset = ResolutionPreset.veryHigh;
    }

    print(description.sensorOrientation);

    if (!mounted) return;
    setState(() {});

    try {
      cameraController =
          CameraController(description, resolutionPreset, enableAudio: true);

      cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }

        cameraController.addListener(camControlListener);

        setState(() {});
      });

      // cameraController.prepareForVideoStreaming();
    } catch (e) {
      print(e.toString());
    }
  }

  void camControlListener() {
    if (cameraController.value.isStreamingVideoRtmp) {
      print('Camera Is Recording RTMP');
      statusText = 'Recording';
    } else {
      if (isStopped == true) {
        print('stream ended by user');
        statusText = 'Streaming ended by user';
      } else {
        print('stream ended by unexpected event');
        statusText = 'Streaming ended by unexpected event';
        startVideoStreaming().then((url) {
          statusText = 'Reconnected';
          if (mounted) setState(() {});
          print(url);
        });
      }
    }

    if (cameraController.value.isStreamingPaused) {
      print('Streaming rtmp paused');
    }

    if (cameraController.value.hasError) {
      print('Error: ${cameraController.value.errorDescription}');
      statusText = cameraController.value.errorDescription;
    }

    if (mounted) setState(() {});
  }

  void onVideoStreamingButtonPressed() {
    startVideoStreaming().then((url) {
      if (mounted) setState(() {});
      print(url);
    });
  }

  void onStopStreamingButtonPressed() {
    isStopped = true;
    stopVideoStreaming().then((_) {
      if (mounted) setState(() {});
    });
  }

  void onFlashlightPressed() {}

  void onChangeCamera() {
    final lensDirection = cameraController.description.lensDirection;

    CameraDescription newDescription;

    if (lensDirection == CameraLensDirection.front) {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = cameras.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    if (newDescription != null) {
      setupLivestreamCamera(newDescription);
    } else {
      print('no camera found');
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController = CameraController(
      cameraDescription,
      resolutionPreset,
      enableAudio: true,
    );

    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print('Camera Error: ${cameraController.value.errorDescription}');
      }

      if (mounted) setState(() {});
    });
  }

  Future<String> startVideoStreaming() async {
    String broadcastServerUrl =
        widget.eventDetail['livestream'][0]['primary_server'];
    String streamName = widget.eventDetail['livestream'][0]['stream_name'];
    String serverPort = widget.eventDetail['livestream'][0]['host_port'];

    String finalBroadcastServerUrl = broadcastServerUrl.substring(0, 40) +
        ':$serverPort/' +
        broadcastServerUrl.substring(41, broadcastServerUrl.length) +
        '/$streamName';

    print('finalBroadcast url: ' + finalBroadcastServerUrl);

    if (!cameraController.value.isInitialized) {
      print('error: select camera first');
      return 'error: select camera first';
    }

    if (cameraController.value.isStreamingVideoRtmp) {
      
      return 'currently streaming, please stop broadcasting first';
    }

    try {
      await cameraController.startVideoStreaming(finalBroadcastServerUrl, androidUseOpenGL: true);
    } on CameraException catch (e) {
      print(e);
      return e.toString();
    }

    cameraController.addListener(() {});

    return 'it works!';
  }

  Future<void> stopVideoStreaming() async {
    if (!cameraController.value.isStreamingVideoRtmp) {
      return null;
    }

    try {
      await cameraController.stopVideoStreaming();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(cameraController == null || cameraController.value.isInitialized){
      return;
    }

    if(state == AppLifecycleState.inactive){
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed){
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void initState() {
    Wakelock.enable();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    // ]);
    getPermission().then((_) {
      getAvailableCamera().then((cameraList) {
        print(cameraList.first.toString());
        setupLivestreamCamera(cameraList.first);
      });
    });

    // startVideoStreaming();
    // getWowzaConfigData();
    // initializeWowzaLivestream().then((response) {
    //   if (response.statusCode == 200 || response.statusCode == 201) {}
    // });
    super.initState();
  }

  @override
  void dispose() {
    Wakelock.disable();

    cameraController?.dispose();
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
              child: cameraController != null
                  ? AspectRatio(
                      aspectRatio: cameraController.value.previewSize != null
                          ? cameraController.resolutionPreset == ResolutionPreset.medium ? 4 / 3 : cameraController.value.aspectRatio
                          : 1.0,
                      child: CameraPreview(cameraController),
                    )
                  : Center(
                      child: Text(
                        'No Camera Detected',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
              //   WOWZCameraView(
              //     controller: wowzCameraController,
              //     androidLicenseKey: 'GOSK-A847-010C-B1B7-290A-960F',
              //     iosLicenseKey: 'GOSK-A847-010C-BD3A-1853-C20A',
              //     broadcastStatusCallback: (status) {
              //       print(status.message);
              //       print(status.state);

              //       if (status.state == BroadcastState.IDLE_ERROR ||
              //           status.state == BroadcastState.BROADCASTING_ERROR ||
              //           status.state == BroadcastState.READY_ERROR) {
              //         Flushbar(
              //           animationDuration: Duration(milliseconds: 500),
              //           backgroundColor: Colors.red,
              //           duration: Duration(seconds: 3),
              //           flushbarPosition: FlushbarPosition.TOP,
              //           message: status.message,
              //         ).show(context);
              //       } else if (status.state == BroadcastState.BROADCASTING) {
              //         isStarting = true;
              //       }

              //       setState(() {});
              //     },
              //     statusCallback: (status) {
              //       print("test");
              //       print(status.mState.toString());
              //       print(status.isStarting().toString());
              //       print(status.isReady().toString());
              //     },
              //   ),
              ),
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (flashLight == true) {
                    TorchCompat.turnOff();
                    flashLight = !flashLight;
                  } else {
                    TorchCompat.turnOn();
                    flashLight = !flashLight;
                  }
                  setState(() {});
                },
                child: Container(
                    child: Image.asset('assets/drawable/flashlight.png',
                        scale: 2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: cameraController == null
                    ? () {}
                    : () {
                        if (isStarting == true) {
                          showCupertinoDialog(
                              context: context,
                              builder: (thisContext) {
                                return CupertinoAlertDialog(
                                  title: Text('Warning'),
                                  content:
                                      Text('Do you want to stop broadcasting?', textScaleFactor: 1.2, textWidthBasis: TextWidthBasis.longestLine,),
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
                                        onStopStreamingButtonPressed();
                                        stopWowzaLivestream();
                                        isStarting = !isStarting;

                                        print('is stopped: ' +
                                            isStopped.toString());
                                        if (mounted) setState(() {});
                                        Navigator.pop(thisContext);
                                        // stopWowzaLivestream().then((response) {
                                        //   if (response.statusCode == 200 ||
                                        //       response.statusCode == 201) {
                                        //     print(
                                        //         'Stopping livestream succes: ${response.body} With Status Code: ${response.statusCode}');
                                        //         Navigator.pop(thisContext);
                                        //         Navigator.pop(context);
                                        //   }
                                        // },);
                                      },
                                    )
                                  ],
                                );
                              });
                        } else {
                          onVideoStreamingButtonPressed();
                          isStopped = false;
                          isStarting = !isStarting;
                        }

                        setState(() {});
                      },
                child: Container(
                  height: 50,
                  width: 200,
                  decoration: BoxDecoration(
                      color:
                          cameraController != null ? Colors.red : Colors.grey,
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
          Positioned(
            top: 25,
            left: 25,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (cameraController != null) {
                  cameraController.dispose();
                  onStopStreamingButtonPressed();
                }

                Navigator.pop(context);
              },
              child: Icon(Icons.close, color: Colors.white),
            ),
          ),
          Positioned(
              right: 25,
              top: 25,
              child: Text(statusText, style: TextStyle(color: Colors.white)))
          // Padding(
          //   padding: const EdgeInsets.only(right: 30, bottom: 20),
          //   child: Align(
          //     alignment: Alignment.bottomRight,
          //     child: GestureDetector(
          //       behavior: HitTestBehavior.opaque,
          //       onTap: () {
          //         onChangeCamera();
          //         // wowzCameraController.isSwitchCameraAvailable().then(
          //         //   (isSwitchCamAvailable) {
          //         //     if (isSwitchCamAvailable == true) {

          //         //     }
          //         //   },
          //         // );
          //       },
          //       child: Container(
          //           child: Image.asset('assets/drawable/cam_switch.png', scale: 12,)),
          //     ),
          //   ),
          // ),
        ],
      ),
    ));
  }

  void stopBroadcastDialog() {}
}
