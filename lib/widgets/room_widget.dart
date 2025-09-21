import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:find_it/models/space_model.dart';

import '../theme/app_theme.dart';
import 'drawer_widget.dart';

class RoomWidget extends StatelessWidget {
  final SpaceModel room;
  final Function(SpaceModel, bool) onRoomSelected;
  final Function(Offset) onRoomMoved;
  final Function(SpaceModel, bool) onDrawerSelected;
  final Function(Offset) onDrawerMoved;
  final double size;
  final bool isEditMode;
  final AppPalette palette;

  RoomWidget({
    super.key,
    required this.room,
    required this.onRoomSelected,
    required this.onRoomMoved,
    required this.onDrawerSelected,
    required this.onDrawerMoved,
    required this.size,
    required this.isEditMode,
    required this.palette,
  });

  final GlobalKey _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

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
                    child: _visualRoom(context, borderRadius, dragging: true),
                  )
                : const SizedBox.shrink(),
            childWhenDragging: isEditMode ? const SizedBox.shrink() : null,
            onDragStarted: () => HapticFeedback.lightImpact(),
            onDragEnd: (details) {
              if (isEditMode) onRoomMoved(details.offset);
            },
            child: GestureDetector(
              onTap: () => onRoomSelected(room, true),
              child: _visualRoom(context, borderRadius),
            ),
          ),
          ...room.mySpaces.map((drawer) {
            return DrawerWidget(
              drawer: drawer,
              palette: palette,
              onDrawerSelected: onDrawerSelected,
              onDrawerMoved: (offset) {
                onDrawerSelected(drawer, false);
                RenderBox stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
                Offset localPosition = stackBox.globalToLocal(offset);
                onDrawerMoved(localPosition);
              },
              size: size,
              isEditMode: isEditMode,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _visualRoom(BuildContext context, BorderRadius borderRadius, {bool dragging = false}) {
    final isSelected = room.isSelected || dragging;
    final colors = isSelected
        ? [palette.cardGradientStart.withOpacity(0.85), palette.cardGradientEnd.withOpacity(0.85)]
        : [palette.surfaceBright, palette.surfaceDim];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: room.size.width,
      height: room.size.height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isSelected ? palette.primary : palette.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: palette.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ]
            : const [],
      ),
      alignment: Alignment.center,
      child: Text(
        room.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : palette.onSurface,
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
