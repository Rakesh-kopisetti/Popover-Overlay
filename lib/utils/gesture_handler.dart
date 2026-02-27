import 'package:flutter/material.dart';
import '../controllers/popover_controller.dart';

/// Enum defining the types of gestures that can trigger popovers.
enum PopoverGestureType {
  tap,
  longPress,
  doubleTap,
  hover,
}

/// A handler class that manages gestures for triggering popovers.
/// 
/// This class provides a standardized way to link user interactions
/// (tap, long-press, double-tap, hover) to popover triggers.
class PopoverGestureHandler {
  /// Callback for when a popover should be shown.
  final VoidCallback? onShow;

  /// Callback for when a popover should be hidden.
  final VoidCallback? onHide;

  /// Callback for when a popover should be toggled.
  final VoidCallback? onToggle;

  /// The type of gesture that triggers the popover.
  final PopoverGestureType gestureType;

  /// Creates a PopoverGestureHandler with the specified callbacks and gesture type.
  const PopoverGestureHandler({
    this.onShow,
    this.onHide,
    this.onToggle,
    this.gestureType = PopoverGestureType.tap,
  });

  /// Creates gesture callbacks based on the gesture type.
  GestureDetectorCallbacks createCallbacks() {
    return GestureDetectorCallbacks(
      onTap: gestureType == PopoverGestureType.tap ? _handleGesture : null,
      onLongPress: gestureType == PopoverGestureType.longPress ? _handleGesture : null,
      onDoubleTap: gestureType == PopoverGestureType.doubleTap ? _handleGesture : null,
    );
  }

  void _handleGesture() {
    if (onToggle != null) {
      onToggle!();
    } else if (onShow != null) {
      onShow!();
    }
  }
}

/// A container class for GestureDetector callbacks.
class GestureDetectorCallbacks {
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onDoubleTap;

  const GestureDetectorCallbacks({
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
  });
}

/// A widget that wraps a child with gesture detection for popover triggers.
class PopoverGestureWrapper extends StatefulWidget {
  /// The child widget to wrap with gesture detection.
  final Widget child;

  /// The type of gesture that triggers the popover.
  final PopoverGestureType gestureType;

  /// Callback when the gesture is triggered.
  final VoidCallback? onTriggered;

  /// Callback for long press with details (position).
  final void Function(LongPressStartDetails)? onLongPressStart;

  /// Callback for tap with details (position).
  final void Function(TapDownDetails)? onTapDown;

  /// Whether to show visual feedback on gesture.
  final bool showFeedback;

  /// Hit test behavior for the gesture detector.
  final HitTestBehavior behavior;

  const PopoverGestureWrapper({
    super.key,
    required this.child,
    this.gestureType = PopoverGestureType.tap,
    this.onTriggered,
    this.onLongPressStart,
    this.onTapDown,
    this.showFeedback = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<PopoverGestureWrapper> createState() => _PopoverGestureWrapperState();
}

class _PopoverGestureWrapperState extends State<PopoverGestureWrapper> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.gestureType == PopoverGestureType.tap
          ? widget.onTriggered
          : null,
      onTapDown: widget.onTapDown,
      onLongPress: widget.gestureType == PopoverGestureType.longPress
          ? widget.onTriggered
          : null,
      onLongPressStart: widget.onLongPressStart,
      onDoubleTap: widget.gestureType == PopoverGestureType.doubleTap
          ? widget.onTriggered
          : null,
      child: widget.showFeedback
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.gestureType == PopoverGestureType.tap
                    ? widget.onTriggered
                    : null,
                onLongPress: widget.gestureType == PopoverGestureType.longPress
                    ? widget.onTriggered
                    : null,
                onDoubleTap: widget.gestureType == PopoverGestureType.doubleTap
                    ? widget.onTriggered
                    : null,
                child: widget.child,
              ),
            )
          : widget.child,
    );
  }
}

/// A backdrop widget that dismisses popovers when tapped.
class PopoverBackdrop extends StatelessWidget {
  /// Callback when the backdrop is tapped.
  final VoidCallback onDismiss;

  /// The color of the backdrop.
  final Color color;

  /// Whether the backdrop is visible.
  final bool visible;

  const PopoverBackdrop({
    super.key,
    required this.onDismiss,
    this.color = Colors.transparent,
    this.visible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTap: onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: color,
        ),
      ),
    );
  }
}

/// Extension to easily add popover gesture handling to any widget.
extension PopoverGestureExtension on Widget {
  /// Wraps this widget with a popover gesture handler.
  Widget withPopoverGesture({
    PopoverGestureType gestureType = PopoverGestureType.tap,
    VoidCallback? onTriggered,
    void Function(LongPressStartDetails)? onLongPressStart,
    void Function(TapDownDetails)? onTapDown,
    bool showFeedback = true,
  }) {
    return PopoverGestureWrapper(
      gestureType: gestureType,
      onTriggered: onTriggered,
      onLongPressStart: onLongPressStart,
      onTapDown: onTapDown,
      showFeedback: showFeedback,
      child: this,
    );
  }
}

/// Helper class for calculating popover positions based on trigger widget.
class PopoverPositionCalculator {
  /// Calculates the optimal position for a popover.
  /// 
  /// [triggerKey] - GlobalKey of the trigger widget.
  /// [popoverSize] - Expected size of the popover.
  /// [preferredPosition] - Preferred position relative to trigger.
  /// [screenSize] - Size of the screen for boundary checking.
  /// [padding] - Padding from screen edges.
  static Offset calculate({
    required GlobalKey triggerKey,
    required Size popoverSize,
    required PopoverPosition preferredPosition,
    required Size screenSize,
    double padding = 8.0,
  }) {
    final RenderBox? renderBox =
        triggerKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return Offset.zero;

    final triggerSize = renderBox.size;
    final triggerPosition = renderBox.localToGlobal(Offset.zero);

    Offset position;

    switch (preferredPosition) {
      case PopoverPosition.top:
        position = Offset(
          triggerPosition.dx + (triggerSize.width - popoverSize.width) / 2,
          triggerPosition.dy - popoverSize.height - padding,
        );
        break;
      case PopoverPosition.bottom:
        position = Offset(
          triggerPosition.dx + (triggerSize.width - popoverSize.width) / 2,
          triggerPosition.dy + triggerSize.height + padding,
        );
        break;
      case PopoverPosition.left:
        position = Offset(
          triggerPosition.dx - popoverSize.width - padding,
          triggerPosition.dy + (triggerSize.height - popoverSize.height) / 2,
        );
        break;
      case PopoverPosition.right:
        position = Offset(
          triggerPosition.dx + triggerSize.width + padding,
          triggerPosition.dy + (triggerSize.height - popoverSize.height) / 2,
        );
        break;
      case PopoverPosition.center:
        position = Offset(
          (screenSize.width - popoverSize.width) / 2,
          (screenSize.height - popoverSize.height) / 2,
        );
        break;
    }

    // Clamp to screen bounds
    position = Offset(
      position.dx.clamp(padding, screenSize.width - popoverSize.width - padding),
      position.dy.clamp(padding, screenSize.height - popoverSize.height - padding),
    );

    return position;
  }

  /// Calculates position based on a specific point (for context menus).
  static Offset calculateFromPoint({
    required Offset point,
    required Size popoverSize,
    required Size screenSize,
    double padding = 8.0,
  }) {
    double x = point.dx;
    double y = point.dy;

    // Adjust if popover would go off-screen to the right
    if (x + popoverSize.width > screenSize.width - padding) {
      x = screenSize.width - popoverSize.width - padding;
    }

    // Adjust if popover would go off-screen to the bottom
    if (y + popoverSize.height > screenSize.height - padding) {
      y = screenSize.height - popoverSize.height - padding;
    }

    // Ensure minimum padding from edges
    x = x.clamp(padding, screenSize.width - popoverSize.width - padding);
    y = y.clamp(padding, screenSize.height - popoverSize.height - padding);

    return Offset(x, y);
  }
}
