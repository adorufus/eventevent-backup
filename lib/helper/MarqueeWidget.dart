import 'package:flutter/material.dart';

class MarqueeWidget extends StatefulWidget{
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;

  MarqueeWidget({
    @required this.child, 
    this.direction: Axis.horizontal,
    this.animationDuration: const Duration(milliseconds: 3000), 
    this.backDuration: const Duration(milliseconds: 800), 
    this.pauseDuration: const Duration(milliseconds: 800),
  });

  @override
  State<StatefulWidget> createState() {
    return _MarqueeWidgetState();
  }
}

class _MarqueeWidgetState extends State<MarqueeWidget>{
  ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: widget.child,
      scrollDirection: widget.direction,
      controller: _controller,
    );
  }

  void scroll() async{
    while (true){
      await Future.delayed(widget.pauseDuration);
      await _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: widget.animationDuration,
        curve: Curves.easeIn
      );
      // await Future.delayed(widget.pauseDuration);
      // await _controller.animateTo(
      //   0.0,
      //   duration: widget.backDuration, curve: Curves.easeOut
      // );
    }
  }
}