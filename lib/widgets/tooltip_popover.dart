import 'package:flutter/material.dart';
import '../utils/popover_animations.dart';

/// Enum defining the arrow direction for the tooltip.
enum ArrowDirection {
  up,
  down,
  left,
  right,
}

/// A tooltip popover widget that displays content with an arrow pointer.
/// 
/// This widget creates a tooltip-style popover that points towards its
/// trigger element with an arrow indicator.
class TooltipPopover extends StatefulWidget {
  /// The content to display in the tooltip.
  final String content;

  /// The background color of the tooltip.
  final Color backgroundColor;

  /// The text color of the tooltip content.
  final Color textColor;

  /// The position of the tooltip relative to its trigger.
  final ArrowDirection arrowDirection;

  /// The position where the tooltip should appear.
  final Offset position;

  /// Callback when the tooltip is dismissed.
  final VoidCallback? onDismiss;

  /// Animation controller for the tooltip.
  final AnimationController? animationController;

  /// Maximum width of the tooltip.
  final double maxWidth;

  /// Padding inside the tooltip.
  final EdgeInsets padding;

  /// Border radius of the tooltip.
  final double borderRadius;

  /// Size of the arrow pointer.
  final double arrowSize;

  const TooltipPopover({
    super.key,
    required this.content,
    this.backgroundColor = const Color(0xFF333333),
    this.textColor = Colors.white,
    this.arrowDirection = ArrowDirection.down,
    this.position = Offset.zero,
    this.onDismiss,
    this.animationController,
    this.maxWidth = 250,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.borderRadius = 8,
    this.arrowSize = 8,
  });

  @override
  State<TooltipPopover> createState() => _TooltipPopoverState();
}

class _TooltipPopoverState extends State<TooltipPopover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.animationController ??
        AnimationController(
          duration: popoverAnimationDuration,
          vsync: this,
        );
    
    _fadeAnimation = createFadeAnimation(_controller);
    _scaleAnimation = createScaleAnimation(_controller, begin: 0.9, end: 1.0);

    if (widget.animationController == null) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: _getScaleAlignment(),
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: const Key('tooltip-popover'),
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.arrowDirection == ArrowDirection.up)
                    _buildArrow(isUp: true),
                  Container(
                    padding: widget.padding,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.arrowDirection == ArrowDirection.left)
                          _buildArrow(isLeft: true),
                        Flexible(
                          child: Text(
                            widget.content,
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (widget.arrowDirection == ArrowDirection.right)
                          _buildArrow(isRight: true),
                      ],
                    ),
                  ),
                  if (widget.arrowDirection == ArrowDirection.down)
                    _buildArrow(isDown: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow({
    bool isUp = false,
    bool isDown = false,
    bool isLeft = false,
    bool isRight = false,
  }) {
    return CustomPaint(
      size: Size(widget.arrowSize * 2, widget.arrowSize),
      painter: _ArrowPainter(
        color: widget.backgroundColor,
        direction: isUp
            ? ArrowDirection.up
            : isDown
                ? ArrowDirection.down
                : isLeft
                    ? ArrowDirection.left
                    : ArrowDirection.right,
      ),
    );
  }

  Alignment _getScaleAlignment() {
    switch (widget.arrowDirection) {
      case ArrowDirection.up:
        return Alignment.topCenter;
      case ArrowDirection.down:
        return Alignment.bottomCenter;
      case ArrowDirection.left:
        return Alignment.centerLeft;
      case ArrowDirection.right:
        return Alignment.centerRight;
    }
  }
}

/// Custom painter for drawing the tooltip arrow.
class _ArrowPainter extends CustomPainter {
  final Color color;
  final ArrowDirection direction;

  _ArrowPainter({
    required this.color,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (direction) {
      case ArrowDirection.up:
        path.moveTo(0, size.height);
        path.lineTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.down:
        path.moveTo(0, 0);
        path.lineTo(size.width / 2, size.height);
        path.lineTo(size.width, 0);
        break;
      case ArrowDirection.left:
        path.moveTo(size.width, 0);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width, size.height);
        break;
      case ArrowDirection.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return color != oldDelegate.color || direction != oldDelegate.direction;
  }
}

/// A wrapper widget that provides tooltip functionality to its child.
class TooltipPopoverTrigger extends StatefulWidget {
  /// The child widget that triggers the tooltip.
  final Widget child;

  /// The content to display in the tooltip.
  final String content;

  /// The background color of the tooltip.
  final Color backgroundColor;

  /// The text color of the tooltip content.
  final Color textColor;

  /// The preferred position of the tooltip.
  final ArrowDirection preferredDirection;

  /// Whether to show the tooltip on tap (if false, shows on long press).
  final bool showOnTap;

  /// Duration to show the tooltip before auto-dismissing.
  final Duration? autoDismissDuration;

  const TooltipPopoverTrigger({
    super.key,
    required this.child,
    required this.content,
    this.backgroundColor = const Color(0xFF333333),
    this.textColor = Colors.white,
    this.preferredDirection = ArrowDirection.up,
    this.showOnTap = true,
    this.autoDismissDuration,
  });

  @override
  State<TooltipPopoverTrigger> createState() => _TooltipPopoverTriggerState();
}

class _TooltipPopoverTriggerState extends State<TooltipPopoverTrigger>
    with SingleTickerProviderStateMixin {
  final GlobalKey _triggerKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: popoverAnimationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hideTooltip();
    _animationController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate tooltip position based on preferred direction
    Offset tooltipPosition;
    ArrowDirection actualDirection = widget.preferredDirection;

    switch (widget.preferredDirection) {
      case ArrowDirection.up:
        // Tooltip appears above, arrow points down
        tooltipPosition = Offset(
          position.dx + size.width / 2 - 125, // Center horizontally (assuming 250 max width)
          position.dy - 50, // Above the trigger
        );
        if (tooltipPosition.dy < 0) {
          actualDirection = ArrowDirection.down;
          tooltipPosition = Offset(
            position.dx + size.width / 2 - 125,
            position.dy + size.height + 8,
          );
        }
        break;
      case ArrowDirection.down:
        tooltipPosition = Offset(
          position.dx + size.width / 2 - 125,
          position.dy + size.height + 8,
        );
        if (tooltipPosition.dy + 50 > screenSize.height) {
          actualDirection = ArrowDirection.up;
          tooltipPosition = Offset(
            position.dx + size.width / 2 - 125,
            position.dy - 50,
          );
        }
        break;
      case ArrowDirection.left:
        tooltipPosition = Offset(
          position.dx - 258,
          position.dy + size.height / 2 - 25,
        );
        break;
      case ArrowDirection.right:
        tooltipPosition = Offset(
          position.dx + size.width + 8,
          position.dy + size.height / 2 - 25,
        );
        break;
    }

    // Clamp position to screen bounds
    tooltipPosition = Offset(
      tooltipPosition.dx.clamp(8, screenSize.width - 258),
      tooltipPosition.dy.clamp(8, screenSize.height - 60),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop for dismissing
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideTooltip,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Tooltip
          TooltipPopover(
            content: widget.content,
            backgroundColor: widget.backgroundColor,
            textColor: widget.textColor,
            arrowDirection: actualDirection,
            position: tooltipPosition,
            onDismiss: _hideTooltip,
            animationController: _animationController,
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();

    // Auto-dismiss if duration is set
    if (widget.autoDismissDuration != null) {
      Future.delayed(widget.autoDismissDuration!, _hideTooltip);
    }
  }

  void _hideTooltip() {
    if (_overlayEntry == null) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _triggerKey,
      behavior: HitTestBehavior.opaque,
      onTap: widget.showOnTap ? _showTooltip : null,
      onLongPress: !widget.showOnTap ? _showTooltip : null,
      child: IgnorePointer(
        child: widget.child,
      ),
    );
  }
}
