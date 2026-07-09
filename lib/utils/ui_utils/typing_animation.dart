import 'dart:async';
import 'package:flutter/material.dart';
import 'package:profitara/theme/app_colors.dart';

class TypingAnimation extends StatefulWidget {
  const TypingAnimation({
    super.key,
    required this.text,
    this.speed = const Duration(milliseconds: 100),
    this.initialDelay = Duration.zero,
    this.style,
    this.onComplete,
  });

  final String text;
  final Duration speed;
  final Duration initialDelay;
  final TextStyle? style;
  final VoidCallback? onComplete;

  @override
  State<TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation> {
  String _displayedText = '';
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.initialDelay, _startTyping);
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_index < widget.text.length) {
        setState(() {
          _displayedText = widget.text.substring(0, _index + 1);
          _index++;
        });
      } else {
        _timer?.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      _displayedText,
      style: widget.style ??
          TextStyle(
              fontSize: 16,
              color:
                  isDark ? AppColors.onPrimaryDark : AppColors.onSurfaceLight),
    );
  }
}
