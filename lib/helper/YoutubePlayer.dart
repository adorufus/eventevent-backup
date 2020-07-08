import 'package:eventevent/helper/colorsManagement.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MyYoutubePlayer extends StatefulWidget {
  final YoutubePlayerController ytPlayerController;

  const MyYoutubePlayer({Key key, this.ytPlayerController}) : super(key: key);
  @override
  _MyYoutubePlayerState createState() => _MyYoutubePlayerState();
}

class _MyYoutubePlayerState extends State<MyYoutubePlayer> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: widget.ytPlayerController,
      showVideoProgressIndicator: true,
      progressIndicatorColor: eventajaGreenTeal,
      aspectRatio: 16 / 9,
    );
  }
}