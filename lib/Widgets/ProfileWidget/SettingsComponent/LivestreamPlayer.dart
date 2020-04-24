import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:chewie/src/chewie_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_playout/multiaudio/MultiAudioSupport.dart';
import 'package:flutter_playout/player_observer.dart';
import 'package:flutter_playout/video.dart';
import 'package:video_player/video_player.dart';

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

  @override
  void initState() {
    print('wowza url' + widget.wowzaLiveUrl);
    videoPlayerController = VideoPlayerController.network(
        widget.wowzaLiveUrl);
    setState(() {});
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 3 / 2,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      fullScreenByDefault: true,
      isLive: true,
    );

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Container(
          color: Colors.black,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: AspectRatio(
              aspectRatio: 3 / 4,
                          child: Video(
                url:
                    widget.wowzaLiveUrl,
                autoPlay: true,
                isLiveStream: true,
                onViewCreated: _onViewCreated,
                showControls: true,
                position: 1,
              ),
            ),
          ),
      ),
    );
  }

  void _onViewCreated(int viewId) {
    listenForVideoPlayerEvents(viewId);
    enableMultiAudioSupport(viewId);
  }
}
