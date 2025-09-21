import 'package:flutter/material.dart';
import 'package:find_it/models/space_model.dart';

class DrawerWidget extends StatelessWidget {
  final SpaceModel drawer;
  final Function(SpaceModel, bool) onDrawerSelected;
  final Function(Offset) onDrawerMoved;
  final Function(double) onDrawerResized;
  bool isEditMode;
  double size;

  DrawerWidget({
    required this.drawer,
    required this.onDrawerSelected,
    required this.onDrawerMoved,
    required this.onDrawerResized,
    required this.size,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: drawer.position.dx,
      top: drawer.position.dy,
      child: LongPressDraggable<SpaceModel>(
        data: drawer,
        feedback: isEditMode ? Transform(
          transform: Matrix4.identity()..scale(size),
          child: visualDraggingDrawer(context),
        ) : Container(),
        childWhenDragging: isEditMode ? Container() : null,
        onDragEnd: (details) {
          if(isEditMode) onDrawerMoved(details.offset);
        },
        child: GestureDetector(
          onTap: () => onDrawerSelected(drawer, false),
          child: visualDrawer(context),
        ),
      ),
    );
  }

  Widget visualDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color fillColor = drawer.isSelected
        ? colorScheme.primaryContainer.withOpacity(0.75)
        : colorScheme.secondaryContainer.withOpacity(0.6);
    final Color borderColor = drawer.isSelected
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1.4,
        ),
      ),
      child: Center(
        child: Text(
          drawer.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget visualDraggingDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.primary,
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          drawer.name,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
