import 'package:flutter/material.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';
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
            feedback: isEditMode
                ? Transform(
                    transform: Matrix4.identity()..scale(size),
                    child: visualDraggingRoom(context),
                  )
                : const SizedBox.shrink(),
            childWhenDragging: isEditMode ? const SizedBox.shrink() : null,
            onDragEnd: (details) {
              if (isEditMode) onRoomMoved(details.offset);
            },
            child: GestureDetector(
              onTap: () {
                Feedback.forTap(context);
                onRoomSelected(room, true);
              },
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
    final colors = context.colors;
    final palette = context.palette;
    final background = room.isSelected
        ? Color.alphaBlend(colors.primary.withOpacity(0.18), palette.surfaceComponent)
        : Color.alphaBlend(colors.primary.withOpacity(isEditMode ? 0.12 : 0.08), palette.surfaceComponent);
    final borderColor = room.isSelected ? colors.primary : colors.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: room.size.width,
      height: room.size.height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: room.isSelected ? 2 : 1),
        boxShadow: room.isSelected
            ? [
                BoxShadow(
                  color: colors.primary.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          room.name,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget visualDraggingRoom(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    final background = Color.alphaBlend(colors.primary.withOpacity(0.18), palette.surfaceComponent);

    return Container(
      width: room.size.width,
      height: room.size.height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.primary, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        room.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
