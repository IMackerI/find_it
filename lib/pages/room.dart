import 'dart:io';
import 'dart:math';

import 'package:find_it/colors.dart';
import 'package:find_it/models/item_model.dart';
import 'package:find_it/pages/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:find_it/models/space_model.dart';
import 'package:find_it/widgets/room_widget.dart';

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
  TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
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
                      style: TextStyle(color: AppColors.textPrimary),
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
                          setState(() {
                            _isEditMode = value;
                          });
                        },
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.secondary,
                        activeColor: AppColors.iconBackground,
                        inactiveThumbColor: AppColors.iconBackground,
                        thumbIcon: WidgetStateProperty.resolveWith<Icon?>((Set<WidgetState> states) {
                          if (_isEditMode) {
                              return const Icon(Icons.edit, color: AppColors.iconColor);
                          } else {
                            return const Icon(Icons.interests, color: AppColors.iconColor);
                          }
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
              AppColors.background,
              Colors.black,
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
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        color: AppColors.secondary,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Items in $selectedName ${selected?.name}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    ItemModel newItem = ItemModel(name: '', description: '');
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDisplayPage(item: newItem),
                      ),
                    );
                    if (newItem.name.isNotEmpty) {
                      setState(() {
                        selected!.items = List<ItemModel>.from(selected!.items)..add(newItem);
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.iconBackground,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      color: AppColors.iconColor,
                    ),
                  ),
                )
              ],
            ),
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

  Widget? itemBarEntry(context, index) {
    final item = selected!.items[index];
    return ListTile(
      title: Text(item.name),
      leading: CircleAvatar(
        child: item.imagePath == null ? ItemModel.defaultIcons[Random().nextInt(ItemModel.defaultIcons.length)] : null,
        backgroundImage: item.imagePath != null ? FileImage(File(item.imagePath!)) : null,
        backgroundColor: AppColors.iconBackground,
      ),
      trailing: GestureDetector(
        onTap: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Do you want to delete this object?'),
              actions: [
                TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                ),
                TextButton(
                child: Text('Delete'),
                onPressed: () {
                  setState(() {
                    selected!.items.remove(item);
                  });
                  SpaceModel.saveItems();
                  Navigator.of(context).pop();
                },
                ),
              ],
              );
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(10)
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.delete,
            color: AppColors.iconColor,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDisplayPage(item: item),
          ),
        );
      },
    );
  }

  Positioned optionsBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: AppColors.secondary,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              '$selectedName options',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              'Change width of the $selectedName:',
                style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
            Slider(
              value: selected!.size.width,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 100,
              onChanged: (value) {
                _onWidthChanged(value);
              },
              activeColor: AppColors.primary,
              inactiveColor: AppColors.iconBackground,
            ),
            Text(
              'Change height of the $selectedName:',
                style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
            Slider(
              value: selected!.size.height,
              min: selectedIsRoom ? 50 : 10,
              max: selectedIsRoom ? 300 : 100,
              onChanged: (value) {
                _onHeightChanged(value);
              },
              activeColor: AppColors.primary,
              inactiveColor: AppColors.iconBackground,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  alignment: Alignment.center,
                    child: IconButton(
                    icon: Icon(Icons.delete, color: AppColors.iconColor),
                    onPressed: () {
                      showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                        title: Text('Are you sure?'),
                        content: Text('Do you want to delete this $selectedName?'),
                        actions: [
                          TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          ),
                          TextButton(
                          child: Text('Delete'),
                          onPressed: () async {
                            setState(() {
                              if(selectedIsRoom){
                                currentSpace.mySpaces.remove(selected);
                                selected = null;
                              }
                              else{
                                if(selected!.parent == null){
                                  currentSpace.mySpaces.forEach((room) {room.assignParents();});
                                }
                                selected!.parent!.mySpaces.remove(selected);
                                selected = null;
                              }
                            });
                            await SpaceModel.saveItems();
                            Navigator.of(context).pop();
                          },
                          ),
                        ],
                        );
                      },
                      );
                    },
                    ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: AppColors.iconColor),
                    onPressed: () {
                      _renameSelected();
                    },
                  ),
                ),
                selectedIsRoom ? Container(
                  margin: const EdgeInsets.all(10),
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.iconBackground,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: Icon(Icons.add, color: AppColors.iconColor),
                    onPressed: () {
                      _addDrawer();
                    },
                  ),
                ) : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addDrawer() async {
    String? drawerName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new drawer'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Drawer name',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
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
            ) ,
          ));
      });
    }
  }

  void _renameSelected() async {
    String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename $selectedName'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'New $selectedName name',
            ),
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
          ),
        );
      },
    );
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        selected!.name = newName;
      });
    }
  }

  AppBar appBar() {
    return AppBar(
      title: Text(
        currentSpace.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          SpaceModel.saveItems();
        },
        child: Container(
          margin: const EdgeInsets.all(10),
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(10)
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SvgPicture.asset('assets/icons/Arrow - Left 2.svg'),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(10),
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.iconBackground,
            borderRadius: BorderRadius.circular(10)
          ),
          alignment: Alignment.center,
          child: IconButton(
            icon: Icon(Icons.save, color: AppColors.iconColor),
            onPressed: () {
              SpaceModel.saveItems();
            },
          ),
        ),
        _isEditMode ? GestureDetector(
          onTap: () async {
            String? roomName = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Add a new room'),
                  content: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Room name',
                    ),
                    onSubmitted: (value) {
                      Navigator.of(context).pop(value);
                    },
                  ),
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
            }
          },
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.iconBackground,
              borderRadius: BorderRadius.circular(10)
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.add,
              color: AppColors.iconColor,
            ),
          ),
        ) : Container(),
      ],
    );
  }

  void _onSelected(SpaceModel room, bool isRoom) {
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
