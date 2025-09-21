import 'package:flutter/material.dart';
import 'package:find_it/models/space_model.dart';
import 'package:flutter/widgets.dart';

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
          child: visualDrawer(),
        ),
      ),
    );
  }

  Container visualDrawer() {
    return Container(
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: drawer.isSelected ?
      BoxDecoration(
      color: Color(0xFF0606c38).withOpacity(0.7),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: Color(0xFFbc6c25),
        width: 1.0,
      ),
      ) :
        BoxDecoration(
        color: Color(0xFFdda15e).withOpacity(0.7),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color(0xFFbc6c25),
          width: 1.0,
        ),
      ),
      child: Center(child: Text(
        drawer.name, 
        style:TextStyle(
            fontSize: 5,
            fontWeight: FontWeight.w100,
          ),
        )),
    );
  }

  Container visualDraggingDrawer(BuildContext context) {
    return Container(
      width: drawer.size.width,
      height: drawer.size.height,
      decoration: BoxDecoration(
        color: Color(0xFFa3b18a).withOpacity(0.7),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: Color(0xFFbc6c25),
          width: 1.0,
        ),
      ),
      child: Center(child: Text(
        drawer.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 5, fontWeight: FontWeight.w100),
        )),
    );
  }
}
