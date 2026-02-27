import 'package:flutter/material.dart';
import '../utils/popover_animations.dart';

/// A dropdown item model for the dropdown popover.
class DropdownItem {
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

  /// Optional nested items for sub-menus.
  final List<DropdownItem>? nestedItems;

  const DropdownItem({
    required this.id,
    required this.label,
    this.icon,
    this.enabled = true,
    this.onTap,
    this.nestedItems,
  });
}

/// A dropdown popover widget that displays a scrollable list of items.
/// 
/// This widget creates a dropdown-style popover with a list of selectable
/// items. It supports scrolling when content exceeds the maximum height.
class DropdownPopover extends StatefulWidget {
  /// List of items to display in the dropdown.
  final List<DropdownItem> items;

  /// The position where the dropdown should appear.
  final Offset position;

  /// The background color of the dropdown.
  final Color backgroundColor;

  /// The text color of the dropdown items.
  final Color textColor;

  /// The color of the selected/highlighted item.
  final Color highlightColor;

  /// Callback when the dropdown is dismissed.
  final VoidCallback? onDismiss;

  /// Callback when an item is selected.
  final void Function(DropdownItem)? onItemSelected;

  /// Animation controller for the dropdown.
  final AnimationController? animationController;

  /// Maximum height of the dropdown.
  final double maxHeight;

  /// Width of the dropdown.
  final double width;

  /// Padding inside the dropdown.
  final EdgeInsets padding;

  /// Border radius of the dropdown.
  final double borderRadius;

  /// Whether to show a divider between items.
  final bool showDividers;

  const DropdownPopover({
    super.key,
    required this.items,
    this.position = Offset.zero,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.highlightColor = const Color(0xFFE3F2FD),
    this.onDismiss,
    this.onItemSelected,
    this.animationController,
    this.maxHeight = 300,
    this.width = 200,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.borderRadius = 8,
    this.showDividers = false,
  });

  @override
  State<DropdownPopover> createState() => _DropdownPopoverState();
}

class _DropdownPopoverState extends State<DropdownPopover>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.animationController ??
        AnimationController(
          duration: popoverAnimationDuration,
          vsync: this,
        );

    _fadeAnimation = createFadeAnimation(_controller);
    _slideAnimation = createSlideAnimation(
      _controller,
      begin: const Offset(0, -0.05),
      end: Offset.zero,
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
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: const Key('dropdown-popover'),
              width: widget.width,
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: SingleChildScrollView(
                  padding: widget.padding,
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
    final List<Widget> widgets = [];

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      widgets.add(_DropdownItemWidget(
        item: item,
        textColor: widget.textColor,
        highlightColor: widget.highlightColor,
        onTap: () {
          widget.onItemSelected?.call(item);
          item.onTap?.call();
          widget.onDismiss?.call();
        },
      ));

      if (widget.showDividers && i < widget.items.length - 1) {
        widgets.add(Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Colors.grey.withOpacity(0.2),
        ));
      }
    }

    return widgets;
  }
}

/// Individual dropdown item widget.
class _DropdownItemWidget extends StatefulWidget {
  final DropdownItem item;
  final Color textColor;
  final Color highlightColor;
  final VoidCallback onTap;

  const _DropdownItemWidget({
    required this.item,
    required this.textColor,
    required this.highlightColor,
    required this.onTap,
  });

  @override
  State<_DropdownItemWidget> createState() => _DropdownItemWidgetState();
}

class _DropdownItemWidgetState extends State<_DropdownItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.item.enabled ? widget.onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: _isHovered && widget.item.enabled
              ? widget.highlightColor
              : Colors.transparent,
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 20,
                  color: widget.item.enabled
                      ? widget.textColor
                      : widget.textColor.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    color: widget.item.enabled
                        ? widget.textColor
                        : widget.textColor.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.item.nestedItems != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: widget.item.enabled
                      ? widget.textColor
                      : widget.textColor.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget that provides dropdown functionality to its child.
class DropdownPopoverTrigger extends StatefulWidget {
  /// The child widget that triggers the dropdown.
  final Widget child;

  /// List of items to display in the dropdown.
  final List<DropdownItem> items;

  /// The background color of the dropdown.
  final Color backgroundColor;

  /// The text color of the dropdown items.
  final Color textColor;

  /// Callback when an item is selected.
  final void Function(DropdownItem)? onItemSelected;

  /// Maximum height of the dropdown.
  final double maxHeight;

  /// Width of the dropdown.
  final double width;

  const DropdownPopoverTrigger({
    super.key,
    required this.child,
    required this.items,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.onItemSelected,
    this.maxHeight = 300,
    this.width = 200,
  });

  @override
  State<DropdownPopoverTrigger> createState() => _DropdownPopoverTriggerState();
}

class _DropdownPopoverTriggerState extends State<DropdownPopoverTrigger>
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
    _hideDropdown();
    _animationController.dispose();
    super.dispose();
  }

  void _showDropdown() {
    if (_overlayEntry != null) return;

    final renderBox =
        _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate dropdown position (below the trigger)
    double left = position.dx;
    double top = position.dy + size.height + 4;

    // Adjust if dropdown would go off-screen
    if (left + widget.width > screenSize.width) {
      left = screenSize.width - widget.width - 8;
    }

    if (top + widget.maxHeight > screenSize.height) {
      // Show above the trigger instead
      top = position.dy - widget.maxHeight - 4;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop for dismissing
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideDropdown,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Dropdown
          DropdownPopover(
            items: widget.items,
            position: Offset(left, top),
            backgroundColor: widget.backgroundColor,
            textColor: widget.textColor,
            onDismiss: _hideDropdown,
            onItemSelected: widget.onItemSelected,
            animationController: _animationController,
            maxHeight: widget.maxHeight,
            width: widget.width,
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }

  void _hideDropdown() {
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
      onTap: _showDropdown,
      child: IgnorePointer(
        child: widget.child,
      ),
    );
  }
}
