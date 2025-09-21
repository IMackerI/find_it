import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:find_it/models/item_model.dart';
import 'package:find_it/models/space_model.dart';
import 'package:find_it/pages/item.dart';
import 'package:find_it/theme/app_theme.dart';
import 'package:find_it/widgets/room_widget.dart';

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

  Future<void> _showAddRoomDialog() async {
    HapticFeedback.lightImpact();
    final controller = TextEditingController();
    String? errorText;

    final String? roomName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add a new room'),
              content: TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Room name',
                  errorText: errorText,
                ),
                onChanged: (value) {
                  if (errorText != null && value.trim().isNotEmpty) {
                    setDialogState(() {
                      errorText = null;
                    });
                  }
                },
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  if (trimmed.isEmpty) {
                    setDialogState(() {
                      errorText = 'Enter a room name';
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(trimmed);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final trimmed = controller.text.trim();
                    if (trimmed.isEmpty) {
                      setDialogState(() {
                        errorText = 'Enter a room name';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(trimmed);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    if (!mounted || roomName == null || roomName.trim().isEmpty) {
      return;
    }

    final String trimmedName = roomName.trim();
    final mediaSize = MediaQuery.of(context).size;
    const Size defaultRoomSize = Size(120, 120);
    final Offset startPosition = Offset(
      (mediaSize.width - defaultRoomSize.width) / 2,
      (mediaSize.height - defaultRoomSize.height) / 2,
    );

    setState(() {
      for (final room in currentSpace.mySpaces) {
        room.isSelected = false;
        for (final drawer in room.mySpaces) {
          drawer.isSelected = false;
        }
      }
      final newRoom = SpaceModel(
        name: trimmedName,
        position: startPosition,
        size: defaultRoomSize,
      );
      newRoom.parent = currentSpace;
      newRoom.isSelected = true;
      currentSpace.mySpaces = List.from(currentSpace.mySpaces)..add(newRoom);
      selected = newRoom;
      selectedName = 'room';
      selectedIsRoom = true;
    });

    HapticFeedback.selectionClick();

    try {
      await SpaceModel.saveItems();
    } catch (e, stackTrace) {
      debugPrint('Failed to save room: $e\n$stackTrace');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room added but saving changes failed.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar(),
      body: Container(
        decoration: BoxDecoration(gradient: extras.backgroundGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: extras.glassBackground,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: extras.shadowColor,
                        blurRadius: 26,
                        offset: const Offset(0, 18),
                        spreadRadius: -18,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: draggableRooms(context),
                  ),
                ),
              ),
              Positioned(
                right: 32,
                top: 32,
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
              if (_isEditMode && selected != null) optionsBar(),
              if (!_isEditMode && selected != null) itemsBar(),
            ],
          ),
        ),
      ),
    );
  }

  InteractiveViewer draggableRooms(BuildContext context) {
    final theme = Theme.of(context);
    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      constrained: false,
      minScale: 0.1,
      maxScale: 20.0,
      transformationController: _controller,
      onInteractionEnd: (details) {
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
            radius: 2.5,
            colors: [
              theme.colorScheme.surfaceVariant.withOpacity(0.7),
              theme.colorScheme.surface.withOpacity(0.9),
            ],
            stops: const [0.15, 1.0],
          ),
        ),
        key: _stackKey,
        child: Stack(
          children: currentSpace.mySpaces.map((room) {
            return RoomWidget(
              room: room,
              onRoomSelected: _onSelected,
              onRoomMoved: (offset) {
                _onSelected(room, true);
                final RenderBox stackBox =
                    _stackKey.currentContext!.findRenderObject() as RenderBox;
                final Offset localPosition = stackBox.globalToLocal(offset);
                _onMoved(localPosition);
              },
              onRoomResized: _onResized,
              size: _controller.value.getMaxScaleOnAxis(),
              transform: _controller.value,
              onDrawerSelected: _onSelected,
              onDrawerMoved: _onMoved,
              onDrawerResized: _onResized,
              isEditMode: _isEditMode,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget itemsBar() {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.25,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: extras.shadowColor,
              blurRadius: 24,
              offset: const Offset(0, -6),
              spreadRadius: -10,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Items in $selectedName ${selected?.name}',
                    style:
                        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final ItemModel newItem = ItemModel(name: '', description: '');
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDisplayPage(item: newItem),
                      ),
                    );
                    if (newItem.name.isNotEmpty) {
                      setState(() {
                        selected!.items =
                            List<ItemModel>.from(selected!.items)..add(newItem);
                      });
                      await SpaceModel.saveItems();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: selected?.items.length ?? 0,
                itemBuilder: itemBarEntry,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? itemBarEntry(BuildContext context, int index) {
    final theme = Theme.of(context);
    final item = selected!.items[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(item.name),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
          foregroundColor: theme.colorScheme.primary,
          child: item.imagePath == null
              ? Icon(
                  ItemModel.defaultIcons[
                      Random().nextInt(ItemModel.defaultIcons.length)],
                )
              : null,
          backgroundImage:
              item.imagePath != null ? FileImage(File(item.imagePath!)) : null,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
          onPressed: () async {
            HapticFeedback.selectionClick();
            final bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete item'),
                  content: const Text('Do you want to delete this object?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
            if (confirmed == true) {
              setState(() {
                selected!.items.remove(item);
              });
              await SpaceModel.saveItems();
            }
          },
        ),
        onTap: () async {
          HapticFeedback.selectionClick();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDisplayPage(item: item),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
      ),
    );
  }

  Widget optionsBar() {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    final String capitalizedName = selectedName.isEmpty
        ? 'Selection'
        : '${selectedName[0].toUpperCase()}${selectedName.substring(1)}';
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: extras.shadowColor,
              blurRadius: 24,
              offset: const Offset(0, -6),
              spreadRadius: -10,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$capitalizedName options',
              style:
                  theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text('Change width:', style: theme.textTheme.bodyMedium),
            Slider(
              value: selected!.size.width,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 150,
              onChanged: (value) {
                setState(() {
                  _onWidthChanged(value);
                });
              },
            ),
            const SizedBox(height: 12),
            Text('Change height:', style: theme.textTheme.bodyMedium),
            Slider(
              value: selected!.size.height,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 150,
              onChanged: (value) {
                setState(() {
                  _onHeightChanged(value);
                });
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    final bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete selection'),
                          content: Text('Delete this ${selectedName.isEmpty ? 'selection' : selectedName}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: theme.colorScheme.error,
                                foregroundColor: theme.colorScheme.onError,
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmed == true) {
                      setState(() {
                        if (selectedIsRoom) {
                          currentSpace.mySpaces.remove(selected);
                          selected = null;
                        } else {
                          selected!.parent?.mySpaces.remove(selected);
                          selected = null;
                        }
                      });
                      await SpaceModel.saveItems();
                    }
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _renameSelected();
                  },
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Rename'),
                ),
                if (selectedIsRoom)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _addDrawer();
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add drawer'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDrawer() async {
    final controller = TextEditingController();
    final String? drawerName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new drawer'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Drawer name',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (drawerName != null && drawerName.isNotEmpty) {
      setState(() {
        final newDrawer = SpaceModel(
          name: drawerName,
          position: Offset.zero,
          size: const Size(20, 20),
        );
        newDrawer.parent = selected;
        selected!.mySpaces = (List<SpaceModel>.from(selected!.mySpaces)
          ..add(newDrawer));
      });
      await SpaceModel.saveItems();
    }
  }

  void _renameSelected() async {
    final controller = TextEditingController(text: selected?.name ?? '');
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename $selectedName'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'New $selectedName name',
            ),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
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
    );
    controller.dispose();
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        selected!.name = newName;
      });
      await SpaceModel.saveItems();
    }
  }

  AppBar appBar() {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        currentSpace.name,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: const Icon(Icons.save_outlined),
          tooltip: 'Save layout',
          onPressed: () {
            HapticFeedback.selectionClick();
            SpaceModel.saveItems();
          },
        ),
        if (_isEditMode)
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Add room',
            onPressed: _showAddRoomDialog,
          ),
      ],
      leading: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/Arrow - Left 2.svg',
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () {
          HapticFeedback.selectionClick();
          Navigator.of(context).pop();
          SpaceModel.saveItems();
        },
      ),
    );
  }

  void _onSelected(SpaceModel room, bool isRoom) {
    setState(() {
      selectedName = isRoom ? 'room' : 'drawer';
      selectedIsRoom = isRoom;
      selected = room;
      for (final r in currentSpace.mySpaces) {
        r.isSelected = false;
        for (final d in r.mySpaces) {
          d.isSelected = false;
        }
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

  void _onResized(double size) {
    setState(() {
      if (selected != null) {
        selected!.size = Size(size, size);
      }
    });
  }

  void _onHeightChanged(double height) {
    setState(() {
      if (selected != null) {
        selected!.size = Size(selected!.size.width, height);
      }
    });
  }

  void _onWidthChanged(double width) {
    setState(() {
      if (selected != null) {
        selected!.size = Size(width, selected!.size.height);
      }
    });
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isEditMode, required this.onChanged});

  final bool isEditMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extras = theme.extension<AppThemeColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: extras.glassBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: extras.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEditMode ? 'Edit mode' : 'Item mode',
            style: theme.textTheme.bodyMedium,
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
