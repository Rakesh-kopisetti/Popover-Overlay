import 'package:flutter/material.dart';

/// Animation curve for fade in effects.
/// Uses ease-out for a smooth deceleration effect.
const Curve fadeInCurve = Curves.easeOut;

/// Animation curve for slide in effects.
/// Uses ease-out cubic for a natural sliding motion.
const Curve slideInCurve = Curves.easeOutCubic;

/// Animation curve for scale in effects.
/// Uses elastic out for a bouncy scaling effect.
const Curve scaleInCurve = Curves.easeOutBack;

/// Default duration for popover animations.
const Duration popoverAnimationDuration = Duration(milliseconds: 200);

/// Animation curve for fade out effects.
const Curve fadeOutCurve = Curves.easeIn;

/// Animation curve for slide out effects.
const Curve slideOutCurve = Curves.easeInCubic;

/// Animation curve for scale out effects.
const Curve scaleOutCurve = Curves.easeInBack;

/// Creates a fade animation for popovers.
Animation<double> createFadeAnimation(AnimationController controller) {
  return CurvedAnimation(
    parent: controller,
    curve: fadeInCurve,
    reverseCurve: fadeOutCurve,
  );
}

/// Creates a slide animation for popovers.
Animation<Offset> createSlideAnimation(
  AnimationController controller, {
  Offset begin = const Offset(0, -0.1),
  Offset end = Offset.zero,
}) {
  return Tween<Offset>(begin: begin, end: end).animate(
    CurvedAnimation(
      parent: controller,
      curve: slideInCurve,
      reverseCurve: slideOutCurve,
    ),
  );
}

/// Creates a scale animation for popovers.
Animation<double> createScaleAnimation(
  AnimationController controller, {
  double begin = 0.8,
  double end = 1.0,
}) {
  return Tween<double>(begin: begin, end: end).animate(
    CurvedAnimation(
      parent: controller,
      curve: scaleInCurve,
      reverseCurve: scaleOutCurve,
    ),
  );
}

/// A widget that wraps content with fade, slide, and scale animations.
class AnimatedPopoverWrapper extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final bool enableFade;
  final bool enableSlide;
  final bool enableScale;
  final Offset slideBegin;
  final Offset slideEnd;
  final double scaleBegin;
  final double scaleEnd;

  const AnimatedPopoverWrapper({
    super.key,
    required this.controller,
    required this.child,
    this.enableFade = true,
    this.enableSlide = true,
    this.enableScale = false,
    this.slideBegin = const Offset(0, -0.1),
    this.slideEnd = Offset.zero,
    this.scaleBegin = 0.8,
    this.scaleEnd = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    if (enableScale) {
      final scaleAnimation = createScaleAnimation(
        controller,
        begin: scaleBegin,
        end: scaleEnd,
      );
      current = ScaleTransition(
        scale: scaleAnimation,
        child: current,
      );
    }

    if (enableSlide) {
      final slideAnimation = createSlideAnimation(
        controller,
        begin: slideBegin,
        end: slideEnd,
      );
      current = SlideTransition(
        position: slideAnimation,
        child: current,
      );
    }

    if (enableFade) {
      final fadeAnimation = createFadeAnimation(controller);
      current = FadeTransition(
        opacity: fadeAnimation,
        child: current,
      );
    }

    return current;
  }
}

/// A builder widget for animated popover transitions.
class PopoverTransitionBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final PopoverAnimationType type;

  const PopoverTransitionBuilder({
    super.key,
    required this.animation,
    required this.child,
    this.type = PopoverAnimationType.fadeSlide,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case PopoverAnimationType.fade:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: fadeInCurve,
          ),
          child: child,
        );
      
      case PopoverAnimationType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: slideInCurve,
          )),
          child: child,
        );
      
      case PopoverAnimationType.scale:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: scaleInCurve,
            ),
          ),
          child: child,
        );
      
      case PopoverAnimationType.fadeSlide:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: fadeInCurve,
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: slideInCurve,
            )),
            child: child,
          ),
        );
      
      case PopoverAnimationType.fadeScale:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: fadeInCurve,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: scaleInCurve,
              ),
            ),
            child: child,
          ),
        );
    }
  }
}

/// Types of animations available for popovers.
enum PopoverAnimationType {
  fade,
  slide,
  scale,
  fadeSlide,
  fadeScale,
}
