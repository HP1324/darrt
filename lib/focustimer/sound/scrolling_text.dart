import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double scrollSpeed;
  final double? width;

  const ScrollingText({
    super.key,
    required this.text,
    this.style,
    this.scrollSpeed = 50.0,
    this.width,
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Calculate duration based on text length and scroll speed
    final duration = Duration(
      milliseconds: (widget.text.length * widget.scrollSpeed).clamp(2000, 10000).toInt(),
    );

    _controller = AnimationController(
      duration: duration,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        _animation =
            Tween<double>(
              begin: 0.0,
              end: maxScrollExtent,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.linear,
              ),
            );

        _animation.addListener(() {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_animation.value);
          }
        });

        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // Prevent manual scrolling
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }
}
