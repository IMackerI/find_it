import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:find_it/models/space_model.dart';

import '../theme/app_theme.dart';

class DrawerWidget extends StatelessWidget {
  final SpaceModel drawer;
  final Function(SpaceModel, bool) onDrawerSelected;
  final Function(Offset) onDrawerMoved;
  final bool isEditMode;
  final double size;
  final AppPalette palette;

  DrawerWidget({
    super.key,
    required this.drawer,
    required this.onDrawerSelected,
    required this.onDrawerMoved,
    required this.size,
    required this.isEditMode,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(10);

    return Positioned(
      left: drawer.position.dx,
      top: drawer.position.dy,
      child: LongPressDraggable<SpaceModel>(
        data: drawer,
        feedback: isEditMode
            ? Transform(
                transform: Matrix4.identity()..scale(size),
                child: _visualDrawer(context, borderRadius, dragging: true),
              )
            : const SizedBox.shrink(),
        childWhenDragging: isEditMode ? const SizedBox.shrink() : null,
        onDragStarted: () => HapticFeedback.lightImpact(),
        onDragEnd: (details) {
          if (isEditMode) onDrawerMoved(details.offset);
        },
        child: GestureDetector(
          onTap: () => onDrawerSelected(drawer, false),
          child: _visualDrawer(context, borderRadius),
        ),
      ),
    );
  }

  Widget _visualDrawer(BuildContext context, BorderRadius borderRadius, {bool dragging = false}) {
    final isSelected = drawer.isSelected || dragging;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          colors: isSelected
              ? [palette.accent.withOpacity(0.8), palette.cardGradientEnd.withOpacity(0.8)]
              : [palette.surfaceBright, palette.surfaceDim],
        ),
        border: Border.all(
          color: isSelected ? palette.accent : palette.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        drawer.name,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isSelected ? Colors.white : palette.onSurface,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
