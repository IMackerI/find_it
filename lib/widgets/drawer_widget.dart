import 'package:flutter/material.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';

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
        feedback: isEditMode
            ? Transform(
                transform: Matrix4.identity()..scale(size),
                child: visualDraggingDrawer(context),
              )
            : const SizedBox.shrink(),
        childWhenDragging: isEditMode ? const SizedBox.shrink() : null,
        onDragEnd: (details) {
          if (isEditMode) onDrawerMoved(details.offset);
        },
        child: GestureDetector(
          onTap: () {
            Feedback.forTap(context);
            onDrawerSelected(drawer, false);
          },
          child: visualDrawer(context),
        ),
      ),
    );
  }

  Widget visualDrawer(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    final background = drawer.isSelected
        ? Color.alphaBlend(colors.secondary.withOpacity(0.24), palette.surfaceComponent)
        : Color.alphaBlend(colors.secondary.withOpacity(isEditMode ? 0.18 : 0.12), palette.surfaceComponent);
    final borderColor = drawer.isSelected ? colors.secondary : colors.outlineVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: drawer.isSelected ? 1.5 : 1),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          drawer.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget visualDraggingDrawer(BuildContext context) {
    final colors = context.colors;
    final palette = context.palette;
    final background = Color.alphaBlend(colors.secondary.withOpacity(0.24), palette.surfaceComponent);

    return Container(
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.secondary, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        drawer.name,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
