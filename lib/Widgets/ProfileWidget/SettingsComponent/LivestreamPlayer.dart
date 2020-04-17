import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class LivestreamPlayer extends StatefulWidget {
  @override
  _LivestreamPlayerState createState() => _LivestreamPlayerState();
}

class _LivestreamPlayerState extends State<LivestreamPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Html(
          data:
              "<div id='wowza_player'></div>\n<script id='player_embed' src='//player.cloud.wowza.com/hosted/fsnjhbpx/wowza.js' type='text/javascript'></script>\n"),
    );
  }
}
