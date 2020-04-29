
import 'dart:math';
//import 'package:eventevent_app_s/values.dart';
import 'package:flutter/widgets.dart';
import 'package:supernova_flutter_ui_toolkit/keyframes.dart';

Animation<double> _createOpacityProperty(AnimationController animationController) => Interpolation<double>(keyframes: [
  Keyframe<double>(fraction: 0, value: 1),
  Keyframe<double>(fraction: 0.00001, value: 0),
  Keyframe<double>(fraction: 1, value: 1),
]).animate(CurvedAnimation(
  curve: Interval(0, 1, curve: Cubic(0.42, 0, 0.58, 1)),
  parent: animationController,
));

Animation<double> _createScaleProperty(AnimationController animationController) => Interpolation<double>(keyframes: [
  Keyframe<double>(fraction: 0, value: 1),
  Keyframe<double>(fraction: 0.00001, value: 10),
  Keyframe<double>(fraction: 1, value: 1),
]).animate(CurvedAnimation(
  curve: Interval(0, 1, curve: Cubic(0.42, 0, 0.58, 1)),
  parent: animationController,
));


class SplashScreenAnimation extends StatelessWidget {
  
  SplashScreenAnimation({
    Key key,
    this.child,
    @required AnimationController animationController
  }) : assert(animationController != null),
       this.opacity = _createOpacityProperty(animationController),
       this.scale = _createScaleProperty(animationController),
       super(key: key);
  
  final Animation<double> opacity;
  final Animation<double> scale;
  final Widget child;
  
  
  @override
  Widget build(BuildContext context) {
  
    return AnimatedBuilder(
      animation: Listenable.merge([
        this.opacity,
        this.scale,
      ]),
      child: this.child,
      builder: (context, widget) {
      
        return Opacity(
          opacity: this.opacity.value,
          child: Transform.scale(
            scale: this.scale.value,
            alignment: Alignment.center,
            child: widget,
          ),
        );
      },
    );
  }
}