import 'package:flutter/material.dart';
import 'package:find_it/models/space_model.dart';

import 'drawer_widget.dart';

class RoomWidget extends StatelessWidget {
  final SpaceModel room;
  final Function(SpaceModel, bool) onRoomSelected;
  final Function(Offset) onRoomMoved;
  final Function(double) onRoomResized;
  final Function(SpaceModel, bool) onDrawerSelected;
  final Function(Offset) onDrawerMoved;
  final Function(double) onDrawerResized;
  final double size;
  final Matrix4 transform;
  bool isEditMode;

  final GlobalKey _stackKey = GlobalKey();

  RoomWidget({
    required this.room,
    required this.onRoomSelected,
    required this.onRoomMoved,
    required this.onRoomResized,
    required this.onDrawerSelected,
    required this.onDrawerMoved,
    required this.onDrawerResized,
    required this.size,
    required this.transform,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: room.position.dx,
      top: room.position.dy,
      child: Stack(
        key: _stackKey,
        children: [
          LongPressDraggable<SpaceModel>(
            data: room,
            feedback: isEditMode ? Transform(
              transform: Matrix4.identity()..scale(size),
              child: visualDraggingRoom(context),
            ) : Container(),
            childWhenDragging: isEditMode ? Container() : null,
            onDragEnd: (details) {
              if(isEditMode) onRoomMoved(details.offset);
            },
            child: GestureDetector(
              onTap: () => onRoomSelected(room, true),
              child: visualRoom(),
            ),
          ),
          ...room.mySpaces.map((drawer) {
            return DrawerWidget(
              drawer: drawer,
              onDrawerSelected: onDrawerSelected,
              onDrawerMoved: (offset){
                onDrawerSelected(drawer, false);
                RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
                Offset localPosition = stackBox.globalToLocal(offset);
                onDrawerMoved(localPosition);
              },
              onDrawerResized: onDrawerResized,
              size: size,
              isEditMode: isEditMode,
            );
          }).toList(),
        ],
      ),
    );
  }

  Container visualRoom() {
    return Container(
      width: room.size.width,
      height: room.size.height,
      decoration: room.isSelected ?
      BoxDecoration(
      color: Color(0xFF0606c38).withOpacity(0.3),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: Color(0xFFbc6c25),
        width: 1.0,
      ),
      ) :
        BoxDecoration(
        color: Color(0xFFdda15e).withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color(0xFFbc6c25),
          width: 1.0,
        ),
      ),
      child: Center(child: Text(room.name)),
    );
  }

  Container visualDraggingRoom(BuildContext context) {
    return Container(
      width: room.size.width,
      height: room.size.height,
      decoration: BoxDecoration(
        color: Color(0xFFa3b18a).withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color(0xFFbc6c25),
          width: 1.0,
        ),
      ),
      child: Center(child: Text(room.name, style: Theme.of(context).textTheme.bodyMedium)),
    );
  }
}
