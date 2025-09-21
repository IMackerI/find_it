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
              child: visualRoom(context),
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

  Widget visualRoom(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color fillColor = room.isSelected
        ? colorScheme.primaryContainer.withOpacity(0.7)
        : colorScheme.secondaryContainer.withOpacity(0.45);
    final Color borderColor = room.isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: room.size.width,
      height: room.size.height,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1.6,
        ),
      ),
      child: Center(
        child: Text(
          room.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget visualDraggingRoom(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: room.size.width,
      height: room.size.height,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.primary,
          width: 1.4,
        ),
      ),
      child: Center(
        child: Text(
          room.name,
          style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
