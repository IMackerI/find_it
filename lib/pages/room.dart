import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/item_model.dart';
import '../models/space_model.dart';
import '../theme/app_theme.dart';
import '../widgets/room_widget.dart';
import 'item.dart';

class RoomPage extends StatefulWidget {
  final SpaceModel curSpace;

  RoomPage({super.key, required this.curSpace});

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  SpaceModel get currentSpace => widget.curSpace;
  dynamic selected;
  String selectedName = '';
  bool selectedIsRoom = false;
  bool _isEditMode = false;  // Mode state variable
  
  final GlobalKey _stackKey = GlobalKey();
  late final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Scaffold(
      appBar: _buildAppBar(textStyles),
      body: Stack(
        children: [
            draggableRooms(context),
            Positioned(
              right: 0,
              top: 0,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _isEditMode ? 'Edit Mode' : 'Item Mode',
                      style: textStyles.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 20),
                    child: Transform.scale(
                      scale: 1.5,
                      child: Switch(
                        value: _isEditMode,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _isEditMode = value;
                          });
                        },
                        activeColor: colors.onPrimaryContainer,
                        activeTrackColor: colors.primaryContainer,
                        inactiveTrackColor: context.palette.surfaceComponent,
                        thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Icon(Icons.edit_rounded, color: colors.onPrimaryContainer);
                          }
                          return Icon(Icons.inventory_2_outlined, color: colors.onSurface);
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          (_isEditMode && selected != null) ? optionsBar() : Container(),
          (!_isEditMode && selected != null) ? itemsBar() : Container(),
        ],
      ),
    );
  }

  InteractiveViewer draggableRooms(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    return InteractiveViewer(
      panEnabled: true,
      scaleEnabled: true,
      constrained: false,
      minScale: 0.1,
      maxScale: 20.0,
      transformationController: _controller,
      onInteractionEnd: (details){
        setState(() {
          if(selected != null){
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
              palette.surfaceComponent,
              Color.alphaBlend(colors.primary.withOpacity(0.08), colors.surfaceVariant.withOpacity(0.7)),
            ],
            stops: [0.1, 1.0],
          ),
        ),
        key: _stackKey,
        child: Stack(
          children: currentSpace.mySpaces.map((room) {
            return RoomWidget(
              room: room,
              onRoomSelected: _onSelected,
              onRoomMoved: (offset){
                _onSelected(room, true);
                RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
                Offset localPosition = stackBox.globalToLocal(offset);
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
    final colors = context.colors;
    final palette = context.palette;
    final textStyles = context.textStyles;

    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.26,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: palette.surfaceComponent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Items in $selectedName ${selected?.name}',
                    style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Add item',
                  onPressed: () async {
                    Feedback.forTap(context);
                    final newItem = ItemModel(name: '', description: '');
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDisplayPage(item: newItem),
                      ),
                    );
                    if (result == true && newItem.name.isNotEmpty) {
                      setState(() {
                        selected!.items = List<ItemModel>.from(selected!.items)..add(newItem);
                      });
                      await SpaceModel.saveItems();
                      HapticFeedback.lightImpact();
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

  Widget itemBarEntry(BuildContext context, int index) {
    final colors = context.colors;
    final palette = context.palette;
    final textStyles = context.textStyles;
    final item = selected!.items[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: palette.surfaceComponent,
        borderRadius: BorderRadius.circular(18),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Color.alphaBlend(
              colors.primary.withOpacity(0.12),
              palette.surfaceComponent,
            ),
            child: item.imagePath == null
                ? Icon(
                    ItemModel.defaultIcons[item.name.hashCode.abs() % ItemModel.defaultIcons.length],
                    color: colors.primary,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(item.imagePath!),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          title: Text(
            item.name,
            style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: item.locationSpecification != null && item.locationSpecification!.isNotEmpty
              ? Text(
                  item.locationSpecification!,
                  style: textStyles.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                )
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: colors.onSurfaceVariant,
            onPressed: () async {
              Feedback.forTap(context);
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Remove item?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                setState(() {
                  selected!.items.remove(item);
                });
                await SpaceModel.saveItems();
                HapticFeedback.lightImpact();
              }
            },
          ),
          onTap: () async {
            Feedback.forTap(context);
            final result = await Navigator.push<bool>(
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
      ),
    );
  }

  Positioned optionsBar() {
    final colors = context.colors;
    final palette = context.palette;
    final textStyles = context.textStyles;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surfaceComponent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${selected?.name ?? selectedName} settings',
              style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Width',
              style: textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: selected!.size.width,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 120,
              onChanged: (value) {
                _onWidthChanged(value);
              },
              activeColor: colors.primary,
              inactiveColor: colors.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Height',
              style: textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            Slider(
              value: selected!.size.height,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 120,
              onChanged: (value) {
                _onHeightChanged(value);
              },
              activeColor: colors.primary,
              inactiveColor: colors.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    Feedback.forTap(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Remove $selectedName?'),
                        content: Text('This will delete ${selected?.name} and its contents.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  if (confirmed == true) {
                    setState(() {
                      if (selectedIsRoom) {
                        currentSpace.mySpaces.remove(selected);
                      } else {
                        if (selected!.parent == null) {
                          for (final room in currentSpace.mySpaces) {
                            room.assignParents();
                          }
                        }
                        selected!.parent?.mySpaces.remove(selected);
                      }
                      selected = null;
                    });
                      await SpaceModel.saveItems();
                      HapticFeedback.mediumImpact();
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Feedback.forTap(context);
                    _renameSelected();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Rename'),
                ),
                if (selectedIsRoom)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Feedback.forTap(context);
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

  void _addDrawer() async {
    final controller = TextEditingController();
    String? drawerName = await showDialog<String>(
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
            onSubmitted: (value) {
              Navigator.of(context).pop(value.trim());
            },
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
    if (drawerName != null && drawerName.isNotEmpty) {
      setState(() {
        selected!.mySpaces = (List<SpaceModel>.from(selected!.mySpaces)
          ..add(
            SpaceModel(
              name: drawerName,
              position: Offset(0, 0),
              size: const Size(20, 20),
              parent: selected,
            ) ,
          ));
      });
      await SpaceModel.saveItems();
      HapticFeedback.lightImpact();
    }
  }

  void _renameSelected() async {
    final controller = TextEditingController(text: selected?.name ?? '');
    String? newName = await showDialog<String>(
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
            onSubmitted: (value) {
              Navigator.of(context).pop(value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        selected!.name = newName;
      });
      await SpaceModel.saveItems();
      HapticFeedback.selectionClick();
    }
  }

  AppBar _buildAppBar(TextTheme textStyles) {
    final colors = context.colors;

    return AppBar(
      title: Text(
        currentSpace.name,
        style: textStyles.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () {
          Feedback.forTap(context);
          HapticFeedback.selectionClick();
          Navigator.of(context).pop();
          SpaceModel.saveItems();
        },
      ),
      actions: [
        IconButton(
          tooltip: 'Save layout',
          icon: const Icon(Icons.save_outlined),
          onPressed: () {
            Feedback.forTap(context);
            HapticFeedback.selectionClick();
            SpaceModel.saveItems();
          },
        ),
        if (_isEditMode)
          IconButton(
            tooltip: 'Add room',
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              Feedback.forTap(context);
              final controller = TextEditingController();
              final roomName = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Add a new room'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Room name',
                      ),
                      onSubmitted: (value) {
                        Navigator.of(context).pop(value.trim());
                      },
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
                HapticFeedback.lightImpact();
              }
            },
          ),
      ],
    );
  }

  void _onSelected(SpaceModel room, bool isRoom) {
    HapticFeedback.selectionClick();
    setState(() {
      selectedName = isRoom ? 'room' : 'drawer';
      selectedIsRoom = isRoom;
      selected = room;
      currentSpace.mySpaces.forEach((r) => r.isSelected = false);
      for (var room in currentSpace.mySpaces) {
        room.mySpaces.forEach((d) => d.isSelected = false);
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
