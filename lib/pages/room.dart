import 'dart:io';

import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../models/space_model.dart';
import '../theme/app_theme.dart';
import '../utils/haptics.dart';
import '../widgets/room_widget.dart';
import 'item.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.curSpace});

  final SpaceModel curSpace;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  SpaceModel get currentSpace => widget.curSpace;

  SpaceModel? _selectedSpace;
  bool _selectedIsRoom = false;
  String _selectedLabel = '';
  bool _isEditMode = false;

  final GlobalKey _stackKey = GlobalKey();
  late final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final gradientColors = palette.primaryGradient.colors;

    return Scaffold(
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 2.4,
              colors: [
                gradientColors.first.withOpacity(0.1),
                theme.colorScheme.background,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _buildCanvas(theme, palette)),
              Positioned(
                right: 16,
                top: 16,
                child: _ModeToggleCard(
                  value: _isEditMode,
                  theme: theme,
                  onChanged: (value) async {
                    await AppHaptics.selection();
                    setState(() => _isEditMode = value);
                  },
                ),
              ),
              if (_isEditMode && _selectedSpace != null)
                _OptionsSheet(
                  selectedName: _selectedLabel,
                  isRoom: _selectedIsRoom,
                  size: _selectedSpace!.size,
                  onRename: _renameSelected,
                  onDelete: _deleteSelected,
                  onWidthChanged: _onWidthChanged,
                  onHeightChanged: _onHeightChanged,
                  onAddDrawer: _addDrawer,
                  theme: theme,
                  palette: palette,
                ),
              if (!_isEditMode && _selectedSpace != null)
                _ItemsSheet(
                  space: _selectedSpace!,
                  selectedLabel: _selectedLabel,
                  onAddItem: _addItemToSelected,
                  onDeleteItem: _deleteItem,
                  onOpenItem: _openItem,
                  theme: theme,
                  palette: palette,
                ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme) {
    return AppBar(
      title: Text(widget.curSpace.name),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async {
          await AppHaptics.selection();
          if (!mounted) return;
          Navigator.of(context).pop();
          await SpaceModel.saveItems();
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Save layout',
          icon: const Icon(Icons.save_alt_rounded),
          onPressed: () async {
            await AppHaptics.selection();
            await SpaceModel.saveItems();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Spaces saved successfully')),
            );
          },
        ),
        if (_isEditMode)
          IconButton(
            tooltip: 'Add room',
            icon: const Icon(Icons.add_rounded),
            onPressed: _addRoom,
          ),
      ],
    );
  }

  Widget _buildCanvas(ThemeData theme, AppPalette palette) {
    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      constrained: false,
      minScale: 0.1,
      maxScale: 20.0,
      transformationController: _controller,
      onInteractionEnd: (_) {
        setState(() {
          _selectedSpace?.isSelected = false;
          _selectedSpace = null;
        });
      },
      child: Container(
        key: _stackKey,
        height: MediaQuery.of(context).size.height * 1.5,
        width: MediaQuery.of(context).size.width * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.surfaceTint,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Stack(
          children: currentSpace.mySpaces.map((room) {
            return RoomWidget(
              room: room,
              onRoomSelected: _onSelected,
              onRoomMoved: (offset) {
                _onSelected(room, true);
                final renderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localOffset = renderBox.globalToLocal(offset);
                  _onMoved(localOffset);
                }
              },
              onDrawerSelected: _onSelected,
              onDrawerMoved: _onMoved,
              size: _controller.value.getMaxScaleOnAxis(),
              isEditMode: _isEditMode,
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _addRoom() async {
    await AppHaptics.selection();
    final controller = TextEditingController();
    final roomName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new room'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Room name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (roomName != null && roomName.isNotEmpty) {
      setState(() {
        currentSpace.mySpaces = List.from(currentSpace.mySpaces)
          ..add(
            SpaceModel(
              name: roomName,
              position: Offset(
                MediaQuery.of(context).size.width / 3,
                MediaQuery.of(context).size.height / 3,
              ),
              size: const Size(160, 140),
            ),
          );
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _addDrawer() async {
    if (!_selectedIsRoom || _selectedSpace == null) return;
    await AppHaptics.selection();
    final controller = TextEditingController();
    final drawerName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a new drawer'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Drawer name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (drawerName != null && drawerName.isNotEmpty) {
      setState(() {
        _selectedSpace!.mySpaces = List<SpaceModel>.from(_selectedSpace!.mySpaces)
          ..add(
            SpaceModel(
              name: drawerName,
              position: const Offset(0, 0),
              size: const Size(120, 80),
              parent: _selectedSpace,
            ),
          );
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _renameSelected() async {
    if (_selectedSpace == null) return;
    await AppHaptics.selection();
    final controller = TextEditingController(text: _selectedSpace!.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename $_selectedLabel'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: 'New $_selectedLabel name'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        _selectedSpace!.name = newName;
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedSpace == null) return;
    await AppHaptics.selection();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete $_selectedLabel?'),
          content: Text('Are you sure you want to delete this $_selectedLabel?'),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                AppHaptics.heavyImpact();
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        if (_selectedIsRoom) {
          currentSpace.mySpaces.remove(_selectedSpace);
        } else {
          _selectedSpace!.parent?.mySpaces.remove(_selectedSpace);
        }
        _selectedSpace = null;
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _addItemToSelected() async {
    if (_selectedSpace == null) return;
    await AppHaptics.selection();
    final newItem = ItemModel(name: '', description: '');
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemDisplayPage(item: newItem),
      ),
    );
    if (result == true && newItem.name.isNotEmpty) {
      setState(() {
        newItem.parent = _selectedSpace;
        _selectedSpace!.items = List<ItemModel>.from(_selectedSpace!.items)..add(newItem);
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _deleteItem(ItemModel item) async {
    await AppHaptics.selection();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete item'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                AppHaptics.selection();
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton.tonal(
              onPressed: () {
                AppHaptics.heavyImpact();
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && _selectedSpace != null) {
      setState(() {
        _selectedSpace!.items.remove(item);
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _openItem(ItemModel item) async {
    await AppHaptics.selection();
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemDisplayPage(item: item),
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _onSelected(SpaceModel space, bool isRoom) {
    setState(() {
      _selectedLabel = isRoom ? 'room' : 'drawer';
      _selectedIsRoom = isRoom;
      _selectedSpace = space;
      currentSpace.mySpaces.forEach((room) => room.isSelected = false);
      for (final room in currentSpace.mySpaces) {
        room.mySpaces.forEach((drawer) => drawer.isSelected = false);
      }
      space.isSelected = true;
    });
  }

  void _onMoved(Offset offset) {
    if (_selectedSpace == null) return;
    setState(() {
      _selectedSpace!.position = offset;
    });
  }

  void _onWidthChanged(double width) {
    if (_selectedSpace == null) return;
    setState(() {
      _selectedSpace!.size = Size(width, _selectedSpace!.size.height);
    });
  }

  void _onHeightChanged(double height) {
    if (_selectedSpace == null) return;
    setState(() {
      _selectedSpace!.size = Size(_selectedSpace!.size.width, height);
    });
  }
}

class _ModeToggleCard extends StatelessWidget {
  const _ModeToggleCard({
    required this.value,
    required this.theme,
    required this.onChanged,
  });

  final bool value;
  final ThemeData theme;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value ? Icons.edit_rounded : Icons.interests_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              value ? 'Edit mode' : 'Item mode',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.onPrimary,
              activeTrackColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsSheet extends StatelessWidget {
  const _ItemsSheet({
    required this.space,
    required this.selectedLabel,
    required this.onAddItem,
    required this.onDeleteItem,
    required this.onOpenItem,
    required this.theme,
    required this.palette,
  });

  final SpaceModel space;
  final String selectedLabel;
  final VoidCallback onAddItem;
  final void Function(ItemModel) onDeleteItem;
  final void Function(ItemModel) onOpenItem;
  final ThemeData theme;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.28,
      minChildSize: 0.25,
      maxChildSize: 0.75,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: palette.elevatedSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.outlineMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Items in $selectedLabel',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${space.items.length} item${space.items.length == 1 ? '' : 's'} available',
                            style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: onAddItem,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: space.items.isEmpty
                    ? Center(
                        child: Text(
                          'No items yet',
                          style: theme.textTheme.bodyMedium?.copyWith(color: palette.mutedForeground),
                        ),
                      )
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemBuilder: (context, index) {
                          final item = space.items[index];
                          return _ItemTile(
                            item: item,
                            theme: theme,
                            palette: palette,
                            onOpen: () => onOpenItem(item),
                            onDelete: () => onDeleteItem(item),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: space.items.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  const _OptionsSheet({
    required this.selectedName,
    required this.isRoom,
    required this.size,
    required this.onRename,
    required this.onDelete,
    required this.onWidthChanged,
    required this.onHeightChanged,
    required this.onAddDrawer,
    required this.theme,
    required this.palette,
  });

  final String selectedName;
  final bool isRoom;
  final Size size;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<double> onHeightChanged;
  final VoidCallback onAddDrawer;
  final ThemeData theme;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: palette.elevatedSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.outlineMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${selectedName[0].toUpperCase()}${selectedName.substring(1)} options',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildSlider(
              context,
              label: 'Width',
              value: size.width,
              min: isRoom ? 80 : 40,
              max: isRoom ? 420 : 200,
              onChanged: onWidthChanged,
            ),
            const SizedBox(height: 12),
            _buildSlider(
              context,
              label: 'Height',
              value: size.height,
              min: isRoom ? 80 : 40,
              max: isRoom ? 420 : 200,
              onChanged: onHeightChanged,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRename,
                    icon: const Icon(Icons.drive_file_rename_outline_rounded),
                    label: const Text('Rename'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
            if (isRoom) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onAddDrawer,
                icon: const Icon(Icons.add_box_rounded),
                label: const Text('Add drawer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: palette.outlineMuted,
            thumbColor: theme.colorScheme.primary,
          ),
          child: Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.theme,
    required this.palette,
    required this.onOpen,
    required this.onDelete,
  });

  final ItemModel item;
  final ThemeData theme;
  final AppPalette palette;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: palette.surfaceTint,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (item.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedForeground),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: theme.colorScheme.error,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    const double size = 52;
    if (item.imagePath != null && item.imagePath!.isNotEmpty) {
      final file = File(item.imagePath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        );
      }
    }

    final iconIndex = item.name.isEmpty
        ? 0
        : item.name.hashCode.abs() % ItemModel.defaultIcons.length;
    final iconData = ItemModel.defaultIcons[iconIndex];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: palette.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(iconData, color: theme.colorScheme.onPrimary),
    );
  }
}
