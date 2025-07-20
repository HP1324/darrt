import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class TimedBannerAdWidget extends StatefulWidget {
  final Widget Function() childBuilder;
  final Duration showFor;
  final Duration hideFor;
  final VoidCallback adInitializer;
  final bool showFirst;

  const TimedBannerAdWidget({
    super.key,
    required this.childBuilder,
    required this.adInitializer,
    this.showFor = const Duration(seconds: 20),
    this.hideFor = const Duration(seconds: 30),
    this.showFirst = true,
  });

  @override
  State<TimedBannerAdWidget> createState() => _TimedBannerAdWidgetState();
}

class _TimedBannerAdWidgetState extends State<TimedBannerAdWidget> {
  late bool _isVisible;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _isVisible = widget.showFirst;
    _initializeAd();
  }

  void _initializeAd() async{
    // Initialize the ad
    if (!await InternetConnection().hasInternetAccess) {
      return;
    }
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
    if (widget.showFirst) {
      _scheduleHide();
    } else {
      _scheduleShow();
    }
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