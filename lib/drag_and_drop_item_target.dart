import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DragAndDropItemTarget extends StatefulWidget {
  final Widget child;
  final bool isSideways;
  final bool isSmallWidget;
  final bool isLargeWidget;
  final DragAndDropListInterface parent;
  final DragAndDropBuilderParameters parameters;
  final OnItemDropOnLastTarget onReorderOrAdd;

  DragAndDropItemTarget(
      {@required this.child,
      this.isSideways = false,
      @required this.onReorderOrAdd,
      @required this.parameters,
      @required this.isSmallWidget,
      @required this.isLargeWidget,
      this.parent,
      Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DragAndDropItemTarget();
}

class _DragAndDropItemTarget extends State<DragAndDropItemTarget> with TickerProviderStateMixin {
  DragAndDropItem _hoveredDraggable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: widget.parameters.internalListPadding,
          child: Column(
            crossAxisAlignment: widget.parameters.verticalAlignment,
            children: <Widget>[
              AnimatedSize(
                duration: Duration(
                    milliseconds: widget.parameters.itemSizeAnimationDuration),
                vsync: this,
                alignment: Alignment.bottomCenter,
                child: _hoveredDraggable != null
                    ? Opacity(
                        opacity: widget.parameters.itemGhostOpacity,
                        child: widget.parameters.itemGhost ??
                            _hoveredDraggable.child,
                      )
                    : Container(),
              ),
              widget.child ??
                  Container(
                    height: 20,
                  ),
            ],
          ),
        ),
        Positioned.fill(
          child: DragTarget<DragAndDropItem>(
            builder: (context, candidateData, rejectedData) {
              if (candidateData != null && candidateData.isNotEmpty) {}
              return Container();
            },
            onWillAccept: (incoming) {
              bool accept = true;
              if (widget.parameters.itemTargetOnWillAccept != null)
                accept =
                    widget.parameters.itemTargetOnWillAccept(incoming, widget);
              if (accept && mounted) {
                setState(() {
                  _hoveredDraggable = incoming;
                });
              }
              return accept;
            },
            onLeave: (incoming) {
              if (mounted) {
                setState(() {
                  _hoveredDraggable = null;
                });
              }
            },
            onAccept: (incoming) {
              if (mounted) {
                setState(() {
                  if (widget.onReorderOrAdd != null)
                    widget.onReorderOrAdd(incoming, widget.parent, widget);
                  _hoveredDraggable = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
