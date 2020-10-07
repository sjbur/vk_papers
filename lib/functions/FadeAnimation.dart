import 'package:flutter/material.dart';

class FadeAnimation {
  AnimationController controller;
  Animation<double> animation;
  CurvedAnimation curve;

  FadeAnimation(TickerProvider ticker) {
    controller = AnimationController(
      vsync: ticker,
      duration: Duration(milliseconds: 1000),
    );

    curve = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(curve);
  }
}
