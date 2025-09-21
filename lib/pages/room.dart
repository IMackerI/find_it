import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';

import '../theme/app_theme.dart';
import '../widgets/room_widget.dart';

class RoomPage extends StatefulWidget {
  final SpaceModel curSpace;

  const RoomPage({super.key, required this.curSpace});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  SpaceModel get currentSpace => widget.curSpace;
  dynamic selected;
  String selectedName = '';
  bool selectedIsRoom = false;
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
    final palette = context.palette;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme, palette),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.surfaceDim, palette.background],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: _buildInteractiveCanvas(palette)),
              Positioned(
                right: 16,
                top: 16,
                child: _ModeToggle(
                  isEditMode: _isEditMode,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _isEditMode = value;
                    });
                  },
                ),
              ),
              if (_isEditMode && selected != null) _optionsBar(palette, theme),
              if (!_isEditMode && selected != null) _itemsBar(palette, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCanvas(AppPalette palette) {
    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      constrained: false,
      minScale: 0.1,
      maxScale: 20.0,
      transformationController: _controller,
      onInteractionEnd: (_) {
        setState(() {
          if (selected != null) {
            selected!.isSelected = false;
          }
          selected = null;
        });
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 1.5,
        width: MediaQuery.of(context).size.width * 2,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 3,
            colors: [
              palette.surfaceBright,
              palette.surfaceDim,
            ],
            stops: const [0.1, 1.0],
          ),
        ),
        key: _stackKey,
        child: Stack(
          children: currentSpace.mySpaces.map((room) {
            return RoomWidget(
              room: room,
              palette: palette,
              onRoomSelected: _onSelected,
              onRoomMoved: (offset) {
                _onSelected(room, true);
                RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
                Offset localPosition = stackBox.globalToLocal(offset);
                _onMoved(localPosition);
              },
              size: _controller.value.getMaxScaleOnAxis(),
              onDrawerSelected: _onSelected,
              onDrawerMoved: _onMoved,
              isEditMode: _isEditMode,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _itemsBar(AppPalette palette, ThemeData theme) {
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.22,
      maxChildSize: 0.8,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surfaceBright,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: palette.shadow, blurRadius: 24, offset: const Offset(0, -12)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: palette.surfaceDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Items in $selectedName ${selected?.name ?? ''}'.trim(),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      ItemModel newItem = ItemModel(name: '', description: '');
                      await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDisplayPage(item: newItem),
                        ),
                      );
                      if (newItem.name.isNotEmpty) {
                        setState(() {
                          selected!.items = List<ItemModel>.from(selected!.items)..add(newItem);
                        });
                        await SpaceModel.saveItems();
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: selected?.items.length ?? 0,
                  itemBuilder: _itemBarEntry,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemBarEntry(BuildContext context, int index) {
    final palette = context.palette;
    final theme = Theme.of(context);
    final item = selected!.items[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDisplayPage(item: item),
              ),
            );
          },
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: palette.shadow, blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: palette.iconBackground,
                  foregroundColor: palette.iconForeground,
                  backgroundImage: item.imagePath != null ? FileImage(File(item.imagePath!)) : null,
                  child: item.imagePath == null
                      ? Icon(
                          ItemModel.defaultIcons[Random().nextInt(ItemModel.defaultIcons.length)],
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete item'),
                          content: const Text('Do you want to delete this item?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  selected!.items.remove(item);
                                });
                                SpaceModel.saveItems();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _optionsBar(AppPalette palette, ThemeData theme) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surfaceBright,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: palette.shadow, blurRadius: 24, offset: const Offset(0, -12)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 48,
                decoration: BoxDecoration(
                  color: palette.surfaceDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$selectedName options',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'Adjust width',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: selected!.size.width,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 100,
              onChanged: (value) {
                setState(() {
                  selected!.size = Size(value, selected!.size.height);
                });
              },
              onChangeEnd: (_) => HapticFeedback.selectionClick(),
            ),
            const SizedBox(height: 8),
            Text(
              'Adjust height',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: selected!.size.height,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 100,
              onChanged: (value) {
                setState(() {
                  selected!.size = Size(selected!.size.width, value);
                });
              },
              onChangeEnd: (_) => HapticFeedback.selectionClick(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete $selectedName'),
                          content: Text('Do you want to delete this $selectedName?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () async {
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  if (selectedIsRoom) {
                                    currentSpace.mySpaces.remove(selected);
                                    selected = null;
                                  } else {
                                    if (selected!.parent == null) {
                                      currentSpace.mySpaces.forEach((room) => room.assignParents());
                                    }
                                    selected!.parent!.mySpaces.remove(selected);
                                    selected = null;
                                  }
                                });
                                await SpaceModel.saveItems();
                                Navigator.of(context).pop();
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
                IconButton.filledTonal(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _renameSelected();
                  },
                  icon: const Icon(Icons.edit_rounded),
                ),
                if (selectedIsRoom)
                  IconButton.filledTonal(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _addDrawer();
                    },
                    icon: const Icon(Icons.add_rounded),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDrawer() async {
    final newDrawer = await _promptForName('Add a new drawer', 'Drawer name');
    if (newDrawer != null && newDrawer.isNotEmpty) {
      setState(() {
        selected!.mySpaces = List<SpaceModel>.from(selected!.mySpaces)
          ..add(
            SpaceModel(
              name: newDrawer,
              position: Offset.zero,
              size: const Size(20, 20),
            ),
          );
      });
      await SpaceModel.saveItems();
    }
  }

  Future<void> _renameSelected() async {
    final updatedName = await _promptForName('Rename $selectedName', 'New $selectedName name', selected!.name);
    if (updatedName != null && updatedName.isNotEmpty) {
      setState(() {
        selected!.name = updatedName;
      });
      await SpaceModel.saveItems();
    }
  }

  Future<String?> _promptForName(String title, String label, [String? initialValue]) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).whenComplete(controller.dispose);
  }

  AppBar _buildAppBar(ThemeData theme, AppPalette palette) {
    return AppBar(
      title: Text(
        currentSpace.name,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: IconButton.filledTonal(
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop();
            SpaceModel.saveItems();
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      leadingWidth: 72,
      actions: [
        IconButton.filledTonal(
          onPressed: () {
            HapticFeedback.selectionClick();
            SpaceModel.saveItems();
          },
          icon: const Icon(Icons.save_rounded),
        ),
        if (_isEditMode)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              onPressed: () async {
                HapticFeedback.lightImpact();
                final roomName = await _promptForName('Add a new room', 'Room name');
                if (roomName != null && roomName.isNotEmpty) {
                  setState(() {
                    currentSpace.mySpaces = List.from(currentSpace.mySpaces)
                      ..add(
                        SpaceModel(
                          name: roomName,
                          position: Offset(
                            MediaQuery.of(context).size.width - 200,
                            MediaQuery.of(context).size.height - 400,
                          ),
                          size: const Size(100, 100),
                        ),
                      );
                  });
                  await SpaceModel.saveItems();
                }
              },
              icon: const Icon(Icons.add_rounded),
            ),
          ),
      ],
    );
  }

  void _onSelected(SpaceModel room, bool isRoom) {
    setState(() {
      selectedName = isRoom ? 'room' : 'drawer';
      selectedIsRoom = isRoom;
      selected = room;
      currentSpace.mySpaces.forEach((r) => r.isSelected = false);
      for (var r in currentSpace.mySpaces) {
        r.mySpaces.forEach((d) => d.isSelected = false);
      }
      room.isSelected = true;
    });
  }

  void _onMoved(Offset offset) {
    setState(() {
      if (selected != null) {
        selected!.position = offset;
      }
    });
  }

}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.isEditMode,
    required this.onChanged,
  });

  final bool isEditMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceBright.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: palette.shadow, blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEditMode ? 'Edit mode' : 'Item mode',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isEditMode,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
