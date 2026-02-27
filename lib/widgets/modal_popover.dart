import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../utils/popover_animations.dart';

/// A modal popover widget that displays content in a centered overlay.
/// 
/// This widget creates a modal-style popover with a semi-transparent backdrop
/// that covers the entire screen. It includes a close button and supports
/// custom content.
class ModalPopover extends StatefulWidget {
  /// The title of the modal.
  final String? title;

  /// The content to display in the modal body.
  final Widget? content;

  /// Text content as an alternative to widget content.
  final String? contentText;

  /// The background color of the modal.
  final Color backgroundColor;

  /// The color of the backdrop.
  final Color backdropColor;

  /// The text color of the modal content.
  final Color textColor;

  /// Callback when the modal is dismissed.
  final VoidCallback? onDismiss;

  /// Animation controller for the modal.
  final AnimationController? animationController;

  /// Whether tapping the backdrop dismisses the modal.
  final bool dismissOnBackdropTap;

  /// Whether to show the close button.
  final bool showCloseButton;

  /// Width of the modal.
  final double? width;

  /// Maximum width of the modal.
  final double maxWidth;

  /// Maximum height of the modal.
  final double? maxHeight;

  /// Border radius of the modal.
  final double borderRadius;

  /// Padding inside the modal.
  final EdgeInsets padding;

  /// Optional action buttons for the modal.
  final List<Widget>? actions;

  const ModalPopover({
    super.key,
    this.title,
    this.content,
    this.contentText,
    this.backgroundColor = Colors.white,
    this.backdropColor = const Color(0x80000000),
    this.textColor = Colors.black87,
    this.onDismiss,
    this.animationController,
    this.dismissOnBackdropTap = true,
    this.showCloseButton = true,
    this.width,
    this.maxWidth = 400,
    this.maxHeight,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(24),
    this.actions,
  });

  @override
  State<ModalPopover> createState() => _ModalPopoverState();
}

class _ModalPopoverState extends State<ModalPopover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backdropAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.animationController ??
        AnimationController(
          duration: const Duration(milliseconds: 250),
          vsync: this,
        );

    _fadeAnimation = createFadeAnimation(_controller);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _backdropAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

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
    final screenSize = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Semi-transparent backdrop
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backdropAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: widget.dismissOnBackdropTap ? widget.onDismiss : null,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: widget.backdropColor
                        .withOpacity(widget.backdropColor.opacity * _backdropAnimation.value),
                  ),
                );
              },
            ),
          ),
          // Modal content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  key: const Key('modal-popover'),
                  width: widget.width,
                  constraints: BoxConstraints(
                    maxWidth: widget.maxWidth,
                    maxHeight: widget.maxHeight ?? screenSize.height * 0.8,
                  ),
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with title and close button
                        if (widget.title != null || widget.showCloseButton)
                          _buildHeader(),
                        // Content
                        Flexible(
                          child: SingleChildScrollView(
                            padding: widget.padding,
                            child: widget.content ??
                                (widget.contentText != null
                                    ? Text(
                                        widget.contentText!,
                                        style: TextStyle(
                                          color: widget.textColor,
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      )
                                    : const SizedBox.shrink()),
                          ),
                        ),
                        // Action buttons
                        if (widget.actions != null && widget.actions!.isNotEmpty)
                          _buildActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const Spacer(),
          if (widget.showCloseButton)
            IconButton(
              key: const Key('modal-close-button'),
              icon: Icon(
                Icons.close,
                color: widget.textColor.withOpacity(0.7),
              ),
              onPressed: widget.onDismiss,
              tooltip: 'Close',
            ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: widget.actions!
            .map((action) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: action,
                ))
            .toList(),
      ),
    );
  }
}

/// A trigger widget for showing modal popovers.
class ModalPopoverTrigger extends StatefulWidget {
  /// The child widget that triggers the modal.
  final Widget child;

  /// Title for the modal.
  final String? title;

  /// Content widget for the modal.
  final Widget? content;

  /// Text content for the modal.
  final String? contentText;

  /// Background color of the modal.
  final Color backgroundColor;

  /// Text color of the modal.
  final Color textColor;

  /// Whether to show the close button.
  final bool showCloseButton;

  /// Whether tapping the backdrop dismisses the modal.
  final bool dismissOnBackdropTap;

  /// Optional action buttons.
  final List<Widget>? actions;

  /// Callback when modal is dismissed.
  final VoidCallback? onDismiss;

  const ModalPopoverTrigger({
    super.key,
    required this.child,
    this.title,
    this.content,
    this.contentText,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.showCloseButton = true,
    this.dismissOnBackdropTap = true,
    this.actions,
    this.onDismiss,
  });

  @override
  State<ModalPopoverTrigger> createState() => _ModalPopoverTriggerState();
}

class _ModalPopoverTriggerState extends State<ModalPopoverTrigger>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hideModal();
    _animationController.dispose();
    super.dispose();
  }

  void _showModal() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => ModalPopover(
        title: widget.title,
        content: widget.content,
        contentText: widget.contentText,
        backgroundColor: widget.backgroundColor,
        textColor: widget.textColor,
        showCloseButton: widget.showCloseButton,
        dismissOnBackdropTap: widget.dismissOnBackdropTap,
        onDismiss: _hideModal,
        animationController: _animationController,
        actions: widget.actions,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _hideModal() {
    if (_overlayEntry == null) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _showModal,
      child: IgnorePointer(
        child: widget.child,
      ),
    );
  }
}

/// Helper class for showing modal popovers programmatically.
class ModalPopoverHelper {
  /// Shows a modal popover and returns a function to close it.
  static VoidCallback show({
    required BuildContext context,
    String? title,
    Widget? content,
    String? contentText,
    Color backgroundColor = Colors.white,
    Color textColor = Colors.black87,
    bool showCloseButton = true,
    bool dismissOnBackdropTap = true,
    List<Widget>? actions,
    VoidCallback? onDismiss,
  }) {
    late OverlayEntry overlayEntry;
    late AnimationController animationController;

    // We need a TickerProvider, so we'll use a simple duration-based approach
    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: _DefaultTickerProvider.instance,
    );

    void close() {
      animationController.reverse().then((_) {
        overlayEntry.remove();
        animationController.dispose();
        onDismiss?.call();
      });
    }

    overlayEntry = OverlayEntry(
      builder: (context) => ModalPopover(
        title: title,
        content: content,
        contentText: contentText,
        backgroundColor: backgroundColor,
        textColor: textColor,
        showCloseButton: showCloseButton,
        dismissOnBackdropTap: dismissOnBackdropTap,
        onDismiss: close,
        animationController: animationController,
        actions: actions,
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    animationController.forward();

    return close;
  }
}

/// A simple ticker provider for programmatic modal display.
class _DefaultTickerProvider extends TickerProvider {
  static final _DefaultTickerProvider instance = _DefaultTickerProvider._();
  _DefaultTickerProvider._();

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
