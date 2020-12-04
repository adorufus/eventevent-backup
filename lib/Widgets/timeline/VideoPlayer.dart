import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_info/media_info.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MediaPlayer extends StatefulWidget {
  final videoUri;
  final videoHeight;
  final videoWidth;

  const MediaPlayer({Key key, this.videoUri, this.videoHeight, this.videoWidth})
      : super(key: key);

  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  VideoPlayerController _controller;
  ChewieController chewieController;
  Color backgroundColor = Colors.black;
  bool allowFullscreen = true;
  final MediaInfo _mediaInfo = MediaInfo();
  double aspectRatio = 4 / 3;

  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    if (widget.videoHeight != null && widget.videoWidth != null) {
      if (double.parse(widget.videoHeight) > double.parse(widget.videoWidth)) {
        aspectRatio = 9 / 16;
        backgroundColor = Colors.white;
        allowFullscreen = false;
      }
    }

    super.initState();
    _controller = VideoPlayerController.network(widget.videoUri)
      ..initialize().then((_) {
        setState(() {});
      });

    chewieController = ChewieController(
      videoPlayerController: _controller,
      aspectRatio: aspectRatio,
      autoPlay: false,
      looping: false,
      allowedScreenSleep: false,
      allowFullScreen: allowFullscreen,
      placeholder: Container(
        color: Colors.white,
      ),
      fullScreenByDefault: false,
    );

    _initializeVideoPlayerFuture = _controller.initialize();
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
      backgroundColor: backgroundColor,
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

  void getMediaInfo() async {
    // final Map<String, dynamic> mediaInfo = await _mediaInfo.getMediaInfo(path)
  }
}
