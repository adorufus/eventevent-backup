import 'package:flutter/material.dart'; import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MediaPlayer extends StatefulWidget {
  final videoUri;

  const MediaPlayer({Key key, this.videoUri}) : super(key: key);

  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  VideoPlayerController _controller;
  ChewieController chewieController;

  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUri)
      ..initialize().then((_) {
        setState(() {});
      });

      chewieController = ChewieController(
        videoPlayerController: _controller,
        aspectRatio: 4 / 3,
        autoPlay: false,
        looping: false,
        placeholder: Container(color: Colors.white,),
        fullScreenByDefault: true,
      );

      _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) { double defaultScreenWidth = 400.0;
    double defaultScreenHeight = 810.0;

    ScreenUtil.instance = ScreenUtil(
      width: defaultScreenWidth,
      height: defaultScreenHeight,
      allowFontScaling: true,
    )..init(context);
    return Scaffold(
      backgroundColor: Colors.black,
        body: Center(
            child: Chewie(
              controller: chewieController,
            )),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     setState(() {
        //       _controller.value.isPlaying
        //           ? _controller.pause()
        //           : _controller.play();
        //     });
        //   },
        //   child: Icon(
        //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        //   ),
        // ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
