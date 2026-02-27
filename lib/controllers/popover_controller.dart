import 'package:flutter/material.dart';
import '../state/popover_state.dart';
import '../utils/popover_animations.dart';

/// Enum representing the different types of popovers.
enum PopoverType {
  tooltip,
  dropdown,
  context,
  modal,
}

/// Enum representing the possible positions for a popover.
enum PopoverPosition {
  top,
  bottom,
  left,
  right,
  center,
}

/// Configuration class for popover appearance and behavior.
class PopoverConfig {
  final String id;
  final PopoverType type;
  final PopoverPosition position;
  final String content;
  final Color backgroundColor;
  final Duration animationDuration;

  const PopoverConfig({
    required this.id,
    required this.type,
    this.position = PopoverPosition.bottom,
    required this.content,
    this.backgroundColor = const Color(0xFF333333),
    this.animationDuration = const Duration(milliseconds: 200),
  });

  factory PopoverConfig.fromJson(Map<String, dynamic> json) {
    return PopoverConfig(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      position: _parsePosition(json['position'] as String? ?? 'bottom'),
      content: json['content'] as String,
      backgroundColor: _parseColor(json['backgroundColor'] as String? ?? '#333333'),
      animationDuration: Duration(
        milliseconds: (json['animationDuration'] as num?)?.toInt() ?? 200,
      ),
    );
  }

  static PopoverType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'tooltip':
        return PopoverType.tooltip;
      case 'dropdown':
        return PopoverType.dropdown;
      case 'context':
        return PopoverType.context;
      case 'modal':
        return PopoverType.modal;
      default:
        return PopoverType.tooltip;
    }
  }

  static PopoverPosition _parsePosition(String position) {
    switch (position.toLowerCase()) {
      case 'top':
        return PopoverPosition.top;
      case 'bottom':
        return PopoverPosition.bottom;
      case 'left':
        return PopoverPosition.left;
      case 'right':
        return PopoverPosition.right;
      case 'center':
        return PopoverPosition.center;
      default:
        return PopoverPosition.bottom;
    }
  }

  static Color _parseColor(String hexColor) {
    String hex = hexColor.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}

/// PopoverController class to manage popover logic.
/// 
/// This controller handles showing, hiding, toggling, and positioning
/// of popovers in the overlay. It works with PopoverState to maintain
/// the current state of all active popovers.
class PopoverController {
  /// The popover state that tracks all active popovers.
  final PopoverState state;

  /// The current popover ID being managed (for single popover operations).
  String? _currentPopoverId;

  /// TickerProvider for animations.
  final TickerProvider? vsync;

  /// Creates a PopoverController with the given state.
  PopoverController({
    required this.state,
    this.vsync,
  });

  /// Shows a popover with the given configuration.
  /// 
  /// [context] - The build context for finding the overlay.
  /// [id] - Unique identifier for the popover.
  /// [builder] - Widget builder for the popover content.
  /// [targetContext] - The context of the trigger widget.
  /// [position] - The desired position relative to the trigger.
  /// [backgroundColor] - Background color of the popover.
  /// [animationDuration] - Duration of the show animation.
  void show({
    required BuildContext context,
    required String id,
    required Widget Function(BuildContext, AnimationController) builder,
    BuildContext? targetContext,
    PopoverPosition position = PopoverPosition.bottom,
    Color backgroundColor = const Color(0xFF333333),
    Duration? animationDuration,
  }) {
    // Don't show if already active
    if (state.isActive(id)) {
      return;
    }

    final overlay = Overlay.of(context);
    final duration = animationDuration ?? popoverAnimationDuration;

    // Create animation controller
    AnimationController? animController;
    if (vsync != null) {
      animController = AnimationController(
        duration: duration,
        vsync: vsync!,
      );
    }

    // Calculate position
    Offset popoverPosition = Offset.zero;
    if (targetContext != null) {
      popoverPosition = _calculatePosition(
        targetContext: targetContext,
        position: position,
        context: context,
      );
    }

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (overlayContext) => builder(overlayContext, animController!),
    );

    overlay.insert(overlayEntry);

    state.addPopover(
      id: id,
      position: popoverPosition,
      overlayEntry: overlayEntry,
      animationController: animController,
    );

    _currentPopoverId = id;

    // Start animation
    animController?.forward();
  }

  /// Hides the currently active popover or a specific popover by ID.
  void hide([String? id]) {
    final targetId = id ?? _currentPopoverId;
    if (targetId == null) return;

    final animController = state.getAnimationController(targetId);
    
    if (animController != null) {
      animController.reverse().then((_) {
        state.removePopover(targetId);
        if (_currentPopoverId == targetId) {
          _currentPopoverId = null;
        }
      });
    } else {
      state.removePopover(targetId);
      if (_currentPopoverId == targetId) {
        _currentPopoverId = null;
      }
    }
  }

  /// Toggles the visibility of a popover.
  /// 
  /// If the popover is currently shown, it will be hidden.
  /// If it's hidden, it will be shown with the provided configuration.
  void toggle({
    required BuildContext context,
    required String id,
    required Widget Function(BuildContext, AnimationController) builder,
    BuildContext? targetContext,
    PopoverPosition position = PopoverPosition.bottom,
    Color backgroundColor = const Color(0xFF333333),
    Duration? animationDuration,
  }) {
    if (state.isActive(id)) {
      hide(id);
    } else {
      show(
        context: context,
        id: id,
        builder: builder,
        targetContext: targetContext,
        position: position,
        backgroundColor: backgroundColor,
        animationDuration: animationDuration,
      );
    }
  }

  /// Returns true if any popover is currently showing.
  bool isShowing([String? id]) {
    if (id != null) {
      return state.isActive(id);
    }
    return state.hasActivePopovers;
  }

  /// Updates the position of the current or specified popover.
  void updatePosition([String? id, Offset? newPosition]) {
    final targetId = id ?? _currentPopoverId;
    if (targetId == null || newPosition == null) return;

    state.updatePopoverPosition(targetId, newPosition);
    
    // Rebuild the overlay entry to reflect the new position
    final entry = state.getOverlayEntry(targetId);
    entry?.markNeedsBuild();
  }

  /// Calculates the position for a popover based on the trigger widget.
  Offset _calculatePosition({
    required BuildContext targetContext,
    required PopoverPosition position,
    required BuildContext context,
  }) {
    final RenderBox? renderBox =
        targetContext.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    switch (position) {
      case PopoverPosition.top:
        return Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy,
        );
      case PopoverPosition.bottom:
        return Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy + targetSize.height,
        );
      case PopoverPosition.left:
        return Offset(
          targetPosition.dx,
          targetPosition.dy + targetSize.height / 2,
        );
      case PopoverPosition.right:
        return Offset(
          targetPosition.dx + targetSize.width,
          targetPosition.dy + targetSize.height / 2,
        );
      case PopoverPosition.center:
        return Offset(
          targetPosition.dx + targetSize.width / 2,
          targetPosition.dy + targetSize.height / 2,
        );
    }
  }

  /// Hides all currently active popovers.
  void hideAll() {
    state.clearAll();
    _currentPopoverId = null;
  }

  /// Disposes of the controller and cleans up resources.
  void dispose() {
    hideAll();
  }
}

/// InheritedWidget to provide PopoverController throughout the widget tree.
class PopoverControllerProvider extends InheritedWidget {
  final PopoverController controller;
  final PopoverState state;

  const PopoverControllerProvider({
    super.key,
    required this.controller,
    required this.state,
    required super.child,
  });

  static PopoverControllerProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PopoverControllerProvider>();
  }

  @override
  bool updateShouldNotify(PopoverControllerProvider oldWidget) {
    return controller != oldWidget.controller || state != oldWidget.state;
  }
}
