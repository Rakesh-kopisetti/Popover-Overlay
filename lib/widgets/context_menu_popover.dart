import 'package:flutter/material.dart';
import '../utils/popover_animations.dart';

/// A context menu item model.
class ContextMenuItem {
  /// Unique identifier for the item.
  final String id;

  /// Display label for the item.
  final String label;

  /// Optional icon to display.
  final IconData? icon;

  /// Whether the item is enabled.
  final bool enabled;

  /// Optional callback when the item is selected.
  final VoidCallback? onTap;

  /// Whether this is a separator item.
  final bool isSeparator;

  /// Optional keyboard shortcut to display.
  final String? shortcut;

  const ContextMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.enabled = true,
    this.onTap,
    this.isSeparator = false,
    this.shortcut,
  });

  const ContextMenuItem.separator()
      : id = 'separator',
        label = '',
        icon = null,
        enabled = false,
        onTap = null,
        isSeparator = true,
        shortcut = null;
}

/// A context menu popover widget that appears at the location of a gesture.
/// 
/// This widget creates a context menu-style popover that appears at the
/// position of a user gesture (typically long-press or right-click).
class ContextMenuPopover extends StatefulWidget {
  /// List of items to display in the context menu.
  final List<ContextMenuItem> items;

  /// The position where the context menu should appear.
  final Offset position;

  /// The background color of the context menu.
  final Color backgroundColor;

  /// The text color of the context menu items.
  final Color textColor;

  /// The color of the selected/highlighted item.
  final Color highlightColor;

  /// Callback when the context menu is dismissed.
  final VoidCallback? onDismiss;

  /// Callback when an item is selected.
  final void Function(ContextMenuItem)? onItemSelected;

  /// Animation controller for the context menu.
  final AnimationController? animationController;

  /// Minimum width of the context menu.
  final double minWidth;

  /// Maximum width of the context menu.
  final double maxWidth;

  /// Border radius of the context menu.
  final double borderRadius;

  const ContextMenuPopover({
    super.key,
    required this.items,
    required this.position,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.highlightColor = const Color(0xFFE3F2FD),
    this.onDismiss,
    this.onItemSelected,
    this.animationController,
    this.minWidth = 180,
    this.maxWidth = 280,
    this.borderRadius = 8,
  });

  @override
  State<ContextMenuPopover> createState() => _ContextMenuPopoverState();
}

class _ContextMenuPopoverState extends State<ContextMenuPopover>
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
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: const Key('context-menu-popover'),
              constraints: BoxConstraints(
                minWidth: widget.minWidth,
                maxWidth: widget.maxWidth,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildItems(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems() {
    return widget.items.map((item) {
      if (item.isSeparator) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Divider(
            height: 1,
            color: Colors.grey.withOpacity(0.3),
          ),
        );
      }

      return _ContextMenuItemWidget(
        item: item,
        textColor: widget.textColor,
        highlightColor: widget.highlightColor,
        onTap: () {
          widget.onItemSelected?.call(item);
          item.onTap?.call();
          widget.onDismiss?.call();
        },
      );
    }).toList();
  }
}

/// Individual context menu item widget.
class _ContextMenuItemWidget extends StatefulWidget {
  final ContextMenuItem item;
  final Color textColor;
  final Color highlightColor;
  final VoidCallback onTap;

  const _ContextMenuItemWidget({
    required this.item,
    required this.textColor,
    required this.highlightColor,
    required this.onTap,
  });

  @override
  State<_ContextMenuItemWidget> createState() => _ContextMenuItemWidgetState();
}

class _ContextMenuItemWidgetState extends State<_ContextMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.enabled ? widget.onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          color: _isHovered && widget.item.enabled
              ? widget.highlightColor
              : Colors.transparent,
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 18,
                  color: widget.item.enabled
                      ? widget.textColor
                      : widget.textColor.withOpacity(0.4),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    color: widget.item.enabled
                        ? widget.textColor
                        : widget.textColor.withOpacity(0.4),
                    fontSize: 13,
                  ),
                ),
              ),
              if (widget.item.shortcut != null) ...[
                const SizedBox(width: 24),
                Text(
                  widget.item.shortcut!,
                  style: TextStyle(
                    color: widget.textColor.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget that provides context menu functionality to its child.
class ContextMenuPopoverTrigger extends StatefulWidget {
  /// The child widget that triggers the context menu.
  final Widget child;

  /// List of items to display in the context menu.
  final List<ContextMenuItem> items;

  /// The background color of the context menu.
  final Color backgroundColor;

  /// The text color of the context menu items.
  final Color textColor;

  /// Callback when an item is selected.
  final void Function(ContextMenuItem)? onItemSelected;

  const ContextMenuPopoverTrigger({
    super.key,
    required this.child,
    required this.items,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.onItemSelected,
  });

  @override
  State<ContextMenuPopoverTrigger> createState() =>
      _ContextMenuPopoverTriggerState();
}

class _ContextMenuPopoverTriggerState extends State<ContextMenuPopoverTrigger>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  Offset _tapPosition = Offset.zero;

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
    _hideContextMenu();
    _animationController.dispose();
    super.dispose();
  }

  void _showContextMenu() {
    if (_overlayEntry != null) return;

    final screenSize = MediaQuery.of(context).size;

    // Adjust position to keep menu on screen
    double left = _tapPosition.dx;
    double top = _tapPosition.dy;

    // Estimate menu size (will be adjusted by the menu itself)
    const estimatedWidth = 200.0;
    const estimatedHeight = 200.0;

    if (left + estimatedWidth > screenSize.width) {
      left = screenSize.width - estimatedWidth - 8;
    }
    if (left < 8) left = 8;

    if (top + estimatedHeight > screenSize.height) {
      top = screenSize.height - estimatedHeight - 8;
    }
    if (top < 8) top = 8;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop for dismissing
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideContextMenu,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Context menu
          ContextMenuPopover(
            items: widget.items,
            position: Offset(left, top),
            backgroundColor: widget.backgroundColor,
            textColor: widget.textColor,
            onDismiss: _hideContextMenu,
            onItemSelected: widget.onItemSelected,
            animationController: _animationController,
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _hideContextMenu() {
    if (_overlayEntry == null) return;

    _animationController.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) {
        _tapPosition = details.globalPosition;
        _showContextMenu();
      },
      onSecondaryTapDown: (details) {
        _tapPosition = details.globalPosition;
        _showContextMenu();
      },
      child: IgnorePointer(
        child: widget.child,
      ),
    );
  }
}
