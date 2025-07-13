import 'package:flutter/material.dart';

class TimedBannerWidget extends StatefulWidget {
  final Widget Function() childBuilder;
  final Duration showFor;
  final Duration hideFor;
  final VoidCallback adInitializer;

  const TimedBannerWidget({
    super.key,
    required this.childBuilder,
    required this.adInitializer,
    this.showFor = const Duration(seconds: 20),
    this.hideFor = const Duration(seconds: 30),
  });

  @override
  State<TimedBannerWidget> createState() => _TimedBannerWidgetState();
}

class _TimedBannerWidgetState extends State<TimedBannerWidget> {
  bool _isVisible = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAd();
  }

  void _initializeAd() {
    // Initialize the ad
    widget.adInitializer();

    // Use post frame callback to ensure initialization is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startCycle();
      }
    });
  }

  void _startCycle() {
    _scheduleHide();
  }

  void _scheduleHide() {
    Future.delayed(widget.showFor, () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
        _scheduleShow();
      }
    });
  }

  void _scheduleShow() {
    Future.delayed(widget.hideFor, () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
        _scheduleHide();
      }
    });
  }

  Widget _buildChild() {
    try {
      return widget.childBuilder();
    } catch (e) {
      // If there's still an initialization error, return empty widget
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isVisible ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isVisible ? 1.0 : 0.0,
        child: _isVisible ? _buildChild() : const SizedBox.shrink(),
      ),
    );
  }
}