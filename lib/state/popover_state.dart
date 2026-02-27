import 'package:flutter/material.dart';

/// PopoverState class to track the state of active popovers.
/// 
/// This class manages the list of currently active popover IDs and their
/// positions on the screen. It extends ChangeNotifier to provide reactive
/// updates to listeners when the state changes.
class PopoverState extends ChangeNotifier {
  /// List of currently active popover IDs.
  /// Each ID uniquely identifies a popover in the overlay.
  List<String> activePopoverIds = [];

  /// Map of popover IDs to their current positions.
  /// The Offset represents the top-left corner of each popover.
  Map<String, Offset> popoverPositions = {};

  /// Map of popover IDs to their OverlayEntry instances.
  final Map<String, OverlayEntry> _overlayEntries = {};

  /// Map of popover IDs to their associated AnimationControllers.
  final Map<String, AnimationController> _animationControllers = {};

  /// Get the overlay entry for a specific popover ID.
  OverlayEntry? getOverlayEntry(String id) => _overlayEntries[id];

  /// Get the animation controller for a specific popover ID.
  AnimationController? getAnimationController(String id) =>
      _animationControllers[id];

  /// Check if a popover with the given ID is currently active.
  bool isActive(String id) => activePopoverIds.contains(id);

  /// Add a popover to the active state.
  void addPopover({
    required String id,
    required Offset position,
    required OverlayEntry overlayEntry,
    AnimationController? animationController,
  }) {
    if (!activePopoverIds.contains(id)) {
      activePopoverIds.add(id);
    }
    popoverPositions[id] = position;
    _overlayEntries[id] = overlayEntry;
    if (animationController != null) {
      _animationControllers[id] = animationController;
    }
    notifyListeners();
  }

  /// Remove a popover from the active state.
  void removePopover(String id) {
    activePopoverIds.remove(id);
    popoverPositions.remove(id);
    final entry = _overlayEntries.remove(id);
    entry?.remove();
    _animationControllers.remove(id)?.dispose();
    notifyListeners();
  }

  /// Update the position of an existing popover.
  void updatePopoverPosition(String id, Offset newPosition) {
    if (activePopoverIds.contains(id)) {
      popoverPositions[id] = newPosition;
      notifyListeners();
    }
  }

  /// Clear all active popovers.
  void clearAll() {
    for (final id in List.from(activePopoverIds)) {
      removePopover(id);
    }
  }

  /// Get the number of currently active popovers.
  int get activeCount => activePopoverIds.length;

  /// Check if there are any active popovers.
  bool get hasActivePopovers => activePopoverIds.isNotEmpty;

  @override
  void dispose() {
    clearAll();
    super.dispose();
  }
}
