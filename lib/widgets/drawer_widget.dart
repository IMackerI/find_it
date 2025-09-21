import 'package:flutter/material.dart';

import '../models/space_model.dart';
import '../theme/app_theme.dart';

class DrawerWidget extends StatelessWidget {
  DrawerWidget({
    required this.drawer,
    required this.onDrawerSelected,
    required this.onDrawerMoved,
    required this.size,
    required this.isEditMode,
    super.key,
  });

  final SpaceModel drawer;
  final void Function(SpaceModel, bool) onDrawerSelected;
  final void Function(Offset) onDrawerMoved;
  final double size;
  final bool isEditMode;

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
                child: _buildDrawer(context, dragging: true),
              )
            : const SizedBox.shrink(),
        childWhenDragging: isEditMode ? const SizedBox.shrink() : null,
        onDragEnd: (details) {
          if (isEditMode) {
            onDrawerMoved(details.offset);
          }
        },
        child: GestureDetector(
          onTap: () => onDrawerSelected(drawer, false),
          child: _buildDrawer(context),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, {bool dragging = false}) {
    final theme = Theme.of(context);
    final palette = theme.extension<AppPalette>()!;
    final colorScheme = theme.colorScheme;
    final isSelected = drawer.isSelected && !dragging;

    final baseColor = dragging
        ? palette.surfaceTint
        : isSelected
            ? colorScheme.secondary.withOpacity(0.2)
            : palette.surfaceTint.withOpacity(0.8);
    final borderColor = isSelected ? colorScheme.secondary : palette.outlineMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isSelected ? 1.4 : 1),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        drawer.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}
