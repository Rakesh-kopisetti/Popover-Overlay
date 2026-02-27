import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/popover_controller.dart';
import 'state/popover_state.dart';
import 'widgets/tooltip_popover.dart';
import 'widgets/dropdown_popover.dart';
import 'widgets/context_menu_popover.dart';
import 'widgets/modal_popover.dart';

void main() {
  runApp(const PopoverProApp());
}

// Professional Color Palette
class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color accent = Color(0xFF06B6D4);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x1A000000);
}

/// The main application widget for PopoverPro.
class PopoverProApp extends StatelessWidget {
  const PopoverProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PopoverPro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const PopoverDemoScreen(),
    );
  }
}

/// The main demo screen showcasing all popover types.
class PopoverDemoScreen extends StatefulWidget {
  const PopoverDemoScreen({super.key});

  @override
  State<PopoverDemoScreen> createState() => _PopoverDemoScreenState();
}

class _PopoverDemoScreenState extends State<PopoverDemoScreen>
    with TickerProviderStateMixin {
  late PopoverState _popoverState;
  late PopoverController _popoverController;
  List<PopoverConfig> _popoverConfigs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _popoverState = PopoverState();
    _popoverController = PopoverController(
      state: _popoverState,
      vsync: this,
    );
    _loadConfiguration();
  }

  @override
  void dispose() {
    _popoverController.dispose();
    _popoverState.dispose();
    super.dispose();
  }

  Future<void> _loadConfiguration() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/popover_config.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> popoversJson = jsonData['popovers'];

      setState(() {
        _popoverConfigs =
            popoversJson.map((json) => PopoverConfig.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading configuration: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Loading PopoverPro...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PopoverControllerProvider(
      controller: _popoverController,
      state: _popoverState,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSection(
                    icon: Icons.chat_bubble_outline,
                    iconColor: AppColors.primary,
                    title: 'Tooltip Popovers',
                    description: 'Tap on items to see tooltips with arrow pointers',
                    content: _buildTooltipDemo(),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.menu_open,
                    iconColor: AppColors.accent,
                    title: 'Dropdown Popovers',
                    description: 'Tap buttons to open dropdown menus',
                    content: _buildDropdownDemo(),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.touch_app,
                    iconColor: AppColors.secondary,
                    title: 'Context Menu Popovers',
                    description: 'Long-press on items to see context menus',
                    content: _buildContextMenuDemo(),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.layers,
                    iconColor: AppColors.success,
                    title: 'Modal Popovers',
                    description: 'Tap buttons to open modal dialogs',
                    content: _buildModalDemo(),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.account_tree,
                    iconColor: AppColors.warning,
                    title: 'Nested Popovers',
                    description: 'Interact with popovers that can trigger other popovers',
                    content: _buildNestedDemo(),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    icon: Icons.settings_applications,
                    iconColor: AppColors.textSecondary,
                    title: 'Configuration',
                    description: 'Popovers loaded from JSON configuration',
                    content: _buildConfigInfo(),
                  ),
                  const SizedBox(height: 40),
                  _buildFooter(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.layers_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PopoverPro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Advanced Overlay Management',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  TooltipPopoverTrigger(
                    content: 'Settings and preferences',
                    backgroundColor: AppColors.textPrimary,
                    child: Container(
                      key: const Key('settings-button'),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white70, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Explore different popover types: tooltips, dropdowns, context menus, and modals',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 1,
              color: AppColors.border,
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildTooltipDemo() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        TooltipPopoverTrigger(
          content: 'This tooltip appears above the button with a smooth animation',
          preferredDirection: ArrowDirection.up,
          backgroundColor: AppColors.textPrimary,
          child: _buildStyledButton(
            key: const Key('tooltip-trigger-up'),
            icon: Icons.north,
            label: 'Tooltip Up',
            color: AppColors.primary,
          ),
        ),
        TooltipPopoverTrigger(
          content: 'This tooltip appears below the button',
          preferredDirection: ArrowDirection.down,
          backgroundColor: AppColors.accent,
          child: _buildStyledButton(
            key: const Key('tooltip-trigger-down'),
            icon: Icons.south,
            label: 'Tooltip Down',
            color: AppColors.accent,
          ),
        ),
        TooltipPopoverTrigger(
          content: 'Helpful information displayed on tap!',
          preferredDirection: ArrowDirection.up,
          backgroundColor: AppColors.success,
          child: Container(
            key: const Key('tooltip-chip'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.success),
                SizedBox(width: 8),
                Text(
                  'Info Chip',
                  style: TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledButton({
    Key? key,
    required IconData icon,
    required String label,
    required Color color,
    bool outlined = false,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: outlined ? 2 : 0),
        boxShadow: outlined
            ? null
            : [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: outlined ? color : Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: outlined ? color : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownDemo() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        DropdownPopoverTrigger(
          items: [
            DropdownItem(
              id: 'option1',
              label: 'Profile',
              icon: Icons.person_outline,
              onTap: () => _showSnackBar('Viewing Profile'),
            ),
            DropdownItem(
              id: 'option2',
              label: 'Settings',
              icon: Icons.settings_outlined,
              onTap: () => _showSnackBar('Opening Settings'),
            ),
            DropdownItem(
              id: 'option3',
              label: 'Notifications',
              icon: Icons.notifications_outlined,
              onTap: () => _showSnackBar('Viewing Notifications'),
            ),
            DropdownItem(
              id: 'option4',
              label: 'Help Center',
              icon: Icons.help_outline,
              onTap: () => _showSnackBar('Opening Help'),
            ),
            DropdownItem(
              id: 'option5',
              label: 'Logout',
              icon: Icons.logout,
              onTap: () => _showSnackBar('Logging out...'),
            ),
          ],
          backgroundColor: Colors.white,
          onItemSelected: (item) => debugPrint('Selected: ${item.label}'),
          child: _buildStyledButton(
            key: const Key('dropdown-trigger'),
            icon: Icons.expand_more,
            label: 'User Menu',
            color: AppColors.primary,
          ),
        ),
        DropdownPopoverTrigger(
          items: [
            DropdownItem(
              id: 'file-new',
              label: 'New File',
              icon: Icons.note_add_outlined,
              onTap: () => _showSnackBar('Creating New File'),
            ),
            DropdownItem(
              id: 'file-open',
              label: 'Open',
              icon: Icons.folder_open_outlined,
              onTap: () => _showSnackBar('Opening File'),
            ),
            DropdownItem(
              id: 'file-save',
              label: 'Save',
              icon: Icons.save_outlined,
              onTap: () => _showSnackBar('Saving File'),
            ),
            DropdownItem(
              id: 'file-saveas',
              label: 'Save As...',
              icon: Icons.save_as_outlined,
              onTap: () => _showSnackBar('Save As Dialog'),
            ),
            DropdownItem(
              id: 'file-export',
              label: 'Export',
              icon: Icons.upload_file_outlined,
              onTap: () => _showSnackBar('Exporting'),
            ),
            DropdownItem(
              id: 'file-print',
              label: 'Print',
              icon: Icons.print_outlined,
              onTap: () => _showSnackBar('Printing'),
            ),
          ],
          width: 180,
          child: _buildStyledButton(
            key: const Key('file-dropdown-trigger'),
            icon: Icons.folder_outlined,
            label: 'File Menu',
            color: AppColors.accent,
          ),
        ),
        DropdownPopoverTrigger(
          items: List.generate(
            15,
            (index) => DropdownItem(
              id: 'item-$index',
              label: 'List Item ${index + 1}',
              icon: Icons.circle_outlined,
              onTap: () => _showSnackBar('Selected Item ${index + 1}'),
            ),
          ),
          maxHeight: 200,
          child: _buildStyledButton(
            key: const Key('scrollable-dropdown-trigger'),
            icon: Icons.format_list_bulleted,
            label: 'Scrollable List',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContextMenuDemo() {
    return ContextMenuPopoverTrigger(
      items: [
        ContextMenuItem(
          id: 'cut',
          label: 'Cut',
          icon: Icons.content_cut_outlined,
          shortcut: 'Ctrl+X',
          onTap: () => _showSnackBar('Cut'),
        ),
        ContextMenuItem(
          id: 'copy',
          label: 'Copy',
          icon: Icons.content_copy_outlined,
          shortcut: 'Ctrl+C',
          onTap: () => _showSnackBar('Copy'),
        ),
        ContextMenuItem(
          id: 'paste',
          label: 'Paste',
          icon: Icons.content_paste_outlined,
          shortcut: 'Ctrl+V',
          onTap: () => _showSnackBar('Paste'),
        ),
        const ContextMenuItem.separator(),
        ContextMenuItem(
          id: 'select-all',
          label: 'Select All',
          icon: Icons.select_all,
          shortcut: 'Ctrl+A',
          onTap: () => _showSnackBar('Select All'),
        ),
        const ContextMenuItem.separator(),
        ContextMenuItem(
          id: 'delete',
          label: 'Delete',
          icon: Icons.delete_outline,
          onTap: () => _showSnackBar('Delete'),
        ),
      ],
      child: Container(
        key: const Key('context-menu-area'),
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary.withOpacity(0.05),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondary.withOpacity(0.2),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.touch_app,
                size: 32,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Long-press or right-click here',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'to open context menu',
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalDemo() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ModalPopoverTrigger(
          title: 'Welcome to PopoverPro!',
          contentText:
              'This is a modal popover that displays important information. '
              'It has a semi-transparent backdrop and can be dismissed by tapping '
              'outside or clicking the close button.\n\n'
              'Modals are useful for confirmations, alerts, and important messages '
              'that require user attention.',
          child: _buildStyledButton(
            key: const Key('modal-trigger'),
            icon: Icons.open_in_new,
            label: 'Info Modal',
            color: AppColors.primary,
          ),
        ),
        ModalPopoverTrigger(
          title: 'Confirm Action',
          contentText:
              'Are you sure you want to proceed with this action? This cannot be undone.',
          actions: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _showSnackBar('Action Confirmed!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
          child: _buildStyledButton(
            key: const Key('confirm-modal-trigger'),
            icon: Icons.warning_amber_outlined,
            label: 'Confirmation',
            color: AppColors.warning,
          ),
        ),
        ModalPopoverTrigger(
          title: 'Success!',
          content: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 48, color: AppColors.success),
              ),
              const SizedBox(height: 20),
              const Text(
                'Operation Complete',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your action was completed successfully.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          child: _buildStyledButton(
            key: const Key('custom-modal-trigger'),
            icon: Icons.check_circle_outline,
            label: 'Success Modal',
            color: AppColors.success,
          ),
        ),
        ModalPopoverTrigger(
          title: 'Error Occurred',
          content: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              const Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again or contact support.',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          child: _buildStyledButton(
            key: const Key('error-modal-trigger'),
            icon: Icons.error_outline,
            label: 'Error Modal',
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _buildNestedDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.warning),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Click "Delete" to see a nested confirmation modal',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DropdownPopoverTrigger(
          items: [
            DropdownItem(
              id: 'nested-view',
              label: 'View Details',
              icon: Icons.visibility_outlined,
              onTap: () => _showSnackBar('Viewing Details'),
            ),
            DropdownItem(
              id: 'nested-edit',
              label: 'Edit Item',
              icon: Icons.edit_outlined,
              onTap: () => _showSnackBar('Editing Item'),
            ),
            DropdownItem(
              id: 'nested-duplicate',
              label: 'Duplicate',
              icon: Icons.content_copy_outlined,
              onTap: () => _showSnackBar('Duplicating Item'),
            ),
            DropdownItem(
              id: 'nested-delete',
              label: 'Delete',
              icon: Icons.delete_outline,
              onTap: () => _showDeleteConfirmationModal(),
            ),
          ],
          child: _buildStyledButton(
            key: const Key('nested-dropdown-trigger'),
            icon: Icons.more_horiz,
            label: 'Actions Menu',
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationModal() {
    late OverlayEntry overlayEntry;
    late AnimationController animationController;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    void closeModal() {
      animationController.reverse().then((_) {
        overlayEntry.remove();
        animationController.dispose();
      });
    }

    overlayEntry = OverlayEntry(
      builder: (context) => ModalPopover(
        key: const Key('nested-modal'),
        title: 'Delete Item?',
        contentText: 'This action cannot be undone. Are you sure you want to delete this item?',
        onDismiss: closeModal,
        animationController: animationController,
        backdropColor: const Color(0x80000000),
        actions: [
          TextButton(
            key: const Key('nested-modal-cancel'),
            onPressed: closeModal,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('nested-modal-confirm'),
            onPressed: () {
              closeModal();
              _showSnackBar('Item deleted successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    animationController.forward();
  }

  Widget _buildConfigInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.code, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'assets/popover_config.json',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${_popoverConfigs.length} configurations loaded:',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _popoverConfigs.map((config) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: config.backgroundColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: config.backgroundColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: config.backgroundColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          config.id,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Built with Flutter',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'PopoverPro - Advanced Overlay Management System',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
