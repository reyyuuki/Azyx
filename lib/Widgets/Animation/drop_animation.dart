import 'package:azyx/Widgets/Animation/animation.dart';
import 'package:flutter/material.dart';

class StickyPageAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const StickyPageAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1100),
    this.delay = Duration.zero,
  });

  @override
  State<StickyPageAnimation> createState() => _StickyPageAnimationState();
}

class _StickyPageAnimationState extends State<StickyPageAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _slideController;

  late Animation<double> _slideYAnimation;
  late Animation<double> _slideXAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideController = AnimationController(
      duration: Duration(
        milliseconds: (widget.duration.inMilliseconds * 0.7).round(),
      ),
      vsync: this,
    );

    _slideYAnimation = Tween<double>(begin: 120.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutExpo),
    );

    _slideXAnimation = Tween<double>(begin: -25.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 1.0, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.08, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuint),
      ),
    );

    if (widget.delay == Duration.zero) {
      _startAnimation();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _startAnimation();
        }
      });
    }
  }

  void _startAnimation() {
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_controller, _slideController]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideXAnimation.value, _slideYAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BouncePageAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const BouncePageAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 900),
    this.delay = Duration.zero,
  });

  @override
  State<BouncePageAnimation> createState() => _BouncePageAnimationState();
}

class _BouncePageAnimationState extends State<BouncePageAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(duration: widget.duration, vsync: this);

    _slideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.fastOutSlowIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedItemWrapper(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: widget.child,
              ),
            ),
          );
        },
      ),
    );
  }
}
