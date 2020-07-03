import 'package:eventevent/helper/API/baseApi.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_playout/multiaudio/MultiAudioSupport.dart';
import 'package:flutter_playout/player_observer.dart';
import 'package:flutter_playout/video.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class LivestreamPlayer extends StatefulWidget {
  final wowzaLiveUrl;

  const LivestreamPlayer({Key key, this.wowzaLiveUrl}) : super(key: key);
  @override
  _LivestreamPlayerState createState() => _LivestreamPlayerState();
}

class _LivestreamPlayerState extends State<LivestreamPlayer>
    with PlayerObserver, MultiAudioSupport {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  IOWebSocketChannel channel =
      IOWebSocketChannel.connect(BaseApi.eventeventWebSocket);
  int messageNum = 0;

  @override
  void initState() {
    socketConnect();
    print('wowza url' + widget.wowzaLiveUrl.toString());
    videoPlayerController = VideoPlayerController.network(widget.wowzaLiveUrl);
    setState(() {});
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      autoInitialize: true,
      looping: false,
      
      showControls: true,
      
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],

      fullScreenByDefault: false,
      isLive: true,
    );

    channel.sink.add('testing');

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    socketDisconnect();
    super.dispose();
  }

  void socketConnect() async {
    print("web socket connecting...");
    channel = IOWebSocketChannel.connect(BaseApi.eventeventWebSocket);
  }

  void socketDisconnect() {
    channel.sink.close(status.goingAway);
  }

  void handleReconnectButton() {
    print('reconnecting...');
    socketConnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              child: Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                    child: Chewie(
                      controller: chewieController,
                    ),
                  )),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onViewCreated(int viewId) {
    listenForVideoPlayerEvents(viewId);
    enableMultiAudioSupport(viewId);
  }
}
