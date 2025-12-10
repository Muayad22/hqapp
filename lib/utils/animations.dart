import 'package:flutter/material.dart';

class AppAnimations {
  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 300);
  static const Duration mediumDuration = Duration(milliseconds: 500);
  static const Duration longDuration = Duration(milliseconds: 800);
  static const Duration extraLongDuration = Duration(milliseconds: 1000);
  static const Duration confettiDuration = Duration(milliseconds: 1500);
  static const Duration trophyRotationDuration = Duration(milliseconds: 2000);
  static const Duration scoreCounterDuration = Duration(milliseconds: 1500);

  // Animation Curves
  static const Curve defaultCurve = Curves.easeOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve bounceCurve = Curves.bounceOut;

  // Animation Delays
  static Duration getStaggeredDelay(int index, {int baseDelay = 100}) {
    return Duration(milliseconds: baseDelay + (index * 100));
  }

  // Fade Animation
  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  // Slide Animation
  static Widget slideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(0.0, 0.1),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: end).animate(animation),
      child: child,
    );
  }

  // Scale Animation
  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }

  // Combined Fade and Slide
  static Widget fadeSlideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(0.0, 0.1),
    Offset end = Offset.zero,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: end).animate(animation),
        child: child,
      ),
    );
  }

  // Staggered List Animation
  static Widget staggeredFadeIn({
    required int index,
    required Widget child,
    int baseDelay = 100,
  }) {
    return TweenAnimationBuilder<double>(
      duration: getStaggeredDelay(index, baseDelay: baseDelay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: defaultCurve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

