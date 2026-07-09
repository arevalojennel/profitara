import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'typing_animation.dart';

class CustomLoaderAnimation extends StatefulWidget {
  const CustomLoaderAnimation({
    super.key,
    this.height = 150,
    this.width = 150,
    this.stopAfterSeconds = 2,
    this.stopText = 'No production runs yet.', // 👈 Customize the message
  });
  final double height;
  final double width;
  final int stopAfterSeconds;
  final String stopText;

  @override
  State<CustomLoaderAnimation> createState() => _CustomLoaderAnimationState();
}

class _CustomLoaderAnimationState extends State<CustomLoaderAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  Timer? _stopTimer;
  bool _isStopped = false; // 👈 Track if animation has stopped

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _stopAtMiddle() {
    if (!_isStopped) {
      _animationController.value = 0.5;
      _animationController.stop();
      setState(() {
        _isStopped = true;
      });
    }
  }

  void _onAnimationCompleted() {
    if (!_isStopped) {
      setState(() {
        _isStopped = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/animations/Shopping bag - error.json',
          height: widget.height,
          width: widget.width,
          fit: BoxFit.contain,
          repeat: false, // 👈 Stops at the end naturally
          controller: _animationController,
          onLoaded: (composition) {
            _animationController.duration = composition.duration;

            // Listen for natural completion
            _animationController.addStatusListener((status) {
              if (status == AnimationStatus.completed) {
                _onAnimationCompleted();
              }
            });

            // Start playing from the beginning
            _animationController.forward();

            // Schedule a timer to stop at the middle (if still playing)
            _stopTimer = Timer(Duration(seconds: widget.stopAfterSeconds), () {
              if (mounted && !_isStopped) {
                _stopAtMiddle();
              }
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: _isStopped
              ? TypingAnimation(
                  text: widget.stopText,
                  speed: const Duration(milliseconds: 80),
                  initialDelay: const Duration(milliseconds: 300),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                )
              : const SizedBox(height: 22),
        ),
      ],
    );
  }
}
