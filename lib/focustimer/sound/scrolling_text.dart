import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double scrollSpeed; // pixels per second
  final double? width;
  final Duration pauseDuration; // pause between loops

  const ScrollingText({
    super.key,
    required this.text,
    this.style,
    this.scrollSpeed = 50.0,
    this.width,
    this.pauseDuration = const Duration(seconds: 1),
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  final GlobalKey _textKey = GlobalKey();
  double _textWidth = 0.0;
  double _containerWidth = 0.0;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _measureAndStartAnimation();
      }
    });
  }

  void _measureAndStartAnimation() {
    final RenderBox? renderBox = _textKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && mounted) {
      setState(() {
        _textWidth = renderBox.size.width;
        _containerWidth = widget.width ?? (context.size?.width ?? 300);
        _shouldScroll = _textWidth > _containerWidth;
      });

      if (_shouldScroll) {
        _startScrolling();
      }
    }
  }

  void _startScrolling() {
    if (_controller == null || !mounted) return;

    // Total distance to scroll: text width + container width
    final totalDistance = _textWidth + _containerWidth;

    final duration = Duration(
      milliseconds: ((totalDistance / widget.scrollSpeed) * 1000).toInt(),
    );

    _controller!.duration = duration;

    _animation = Tween<double>(
      begin: 0.0,
      end: totalDistance,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.linear,
    ))..addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        await Future.delayed(widget.pauseDuration);
        if (mounted && _controller != null) {
          _controller!.reset();
          _controller!.forward();
        }
      }
    });

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.style?.height ??
            (widget.style?.fontSize ?? 14) * (widget.style?.height ?? 1.2),
        child: _shouldScroll && _animation != null
            ? AnimatedBuilder(
          animation: _animation!,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  left: _containerWidth - _animation!.value,
                  child: Text(
                    widget.text,
                    style: widget.style,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                ),
              ],
            );
          },
        )
            : Text(
          widget.text,
          key: _textKey,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }
}