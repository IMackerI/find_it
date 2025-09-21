import 'package:flutter/material.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';

import 'drawer_widget.dart';

class RoomWidget extends StatelessWidget {
  RoomWidget({
    required this.room,
    required this.onRoomSelected,
    required this.onRoomMoved,
    required this.onDrawerSelected,
    required this.onDrawerMoved,
    required this.size,
    required this.isEditMode,
    super.key,
  });

  final SpaceModel room;
  final void Function(SpaceModel, bool) onRoomSelected;
  final void Function(Offset) onRoomMoved;
  final void Function(SpaceModel, bool) onDrawerSelected;
  final void Function(Offset) onDrawerMoved;
  final double size;
  final bool isEditMode;

  final GlobalKey _stackKey = GlobalKey();

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
                    child: _buildRoom(context, dragging: true),
                  )
                : const SizedBox.shrink(),
            childWhenDragging: isEditMode ? const SizedBox.shrink() : null,
            onDragEnd: (details) {
              if (isEditMode) {
                onRoomMoved(details.offset);
              }
            },
            child: GestureDetector(
              onTap: () => onRoomSelected(room, true),
              child: _buildRoom(context),
            ),
          ),
          ...room.mySpaces.map((drawer) {
            return DrawerWidget(
              drawer: drawer,
              onDrawerSelected: onDrawerSelected,
              onDrawerMoved: (offset) {
                onDrawerSelected(drawer, false);
                final renderBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  final localOffset = renderBox.globalToLocal(offset);
                  onDrawerMoved(localOffset);
                }
              },
              size: size,
              isEditMode: isEditMode,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRoom(BuildContext context, {bool dragging = false}) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final colorScheme = theme.colorScheme;

    final isSelected = room.isSelected && !dragging;
    final baseColor = dragging
        ? palette.surfaceTint
        : isSelected
            ? colorScheme.primary.withOpacity(0.18)
            : palette.surfaceTint.withOpacity(0.9);
    final borderColor = dragging
        ? palette.outlineMuted
        : isSelected
            ? colorScheme.primary
            : palette.outlineMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: room.size.width,
      height: room.size.height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 1.6 : 1.1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        room.name,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
