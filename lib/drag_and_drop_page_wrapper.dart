import 'dart:math';

import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_page_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DragAndDropPageWrapper extends StatefulWidget {
  final DragAndDropPageInterface dragAndDropPageInterface;
  final DragAndDropBuilderParameters parameters;

  DragAndDropPageWrapper({Key key, this.dragAndDropPageInterface, this.parameters}) : super(key: key);

  @override
  _DragAndDropPageWrapperState createState() => _DragAndDropPageWrapperState();
}

class _DragAndDropPageWrapperState extends State<DragAndDropPageWrapper> {
  ScrollController _scrollController;

  bool _pointerDown = false;
  double _pointerYPosition;
  double _pointerXPosition;
  bool _scrolling = false;

  @override
  void initState() { 
    _scrollController = ScrollController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget dragAndDropPageContents = widget.dragAndDropPageInterface.generateWidget(widget.parameters, _scrollController);
    return Listener(
      onPointerMove: (event) => _onPointerMove(event, context),
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: dragAndDropPageContents,
    );
  }

  _onPointerMove(PointerMoveEvent event, BuildContext context) {
    if (_pointerDown) {
      _pointerYPosition = event.position.dy;
      _pointerXPosition = event.position.dx;

      if (_scrollController.hasClients) {
        _scrollList(context);
      }
    }
  }

  _onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _pointerYPosition = event.position.dy;
    _pointerXPosition = event.position.dx;
  }

  _onPointerUp(PointerUpEvent event) {
    _pointerDown = false;
  }

  _scrollList(context) async {
    if (!_scrolling &&
        _pointerDown &&
        _pointerYPosition != null &&
        _pointerXPosition != null) {
      int duration = 30; // in ms
      int scrollAreaSize = 20;
      double step = 1.5;
      double overDragMax = 20.0;
      double overDragCoefficient = 5.0;
      double newOffset;

      var rb = context.findRenderObject();
      Size size;
      if (rb is RenderBox)
        size = rb.size;
      else if (rb is RenderSliver) size = rb.paintBounds.size;
      var topLeftOffset = localToGlobal(rb, Offset.zero);
      var bottomRightOffset = localToGlobal(rb, size.bottomRight(Offset.zero));

      if (true) {
        double top = topLeftOffset.dy;
        double bottom = bottomRightOffset.dy;

        if (_pointerYPosition < (top + scrollAreaSize) &&
            _scrollController.position.pixels >
                _scrollController.position.minScrollExtent) {
          final overDrag =
              max((top + scrollAreaSize) - _pointerYPosition, overDragMax);
          newOffset = max(
              _scrollController.position.minScrollExtent,
              _scrollController.position.pixels -
                  step * overDrag / overDragCoefficient);
        } else if (_pointerYPosition > (bottom - scrollAreaSize) &&
            _scrollController.position.pixels <
                _scrollController.position.maxScrollExtent) {
          final overDrag = max<double>(
              _pointerYPosition - (bottom - scrollAreaSize), overDragMax);
          newOffset = min(
              _scrollController.position.maxScrollExtent,
              _scrollController.position.pixels +
                  step * overDrag / overDragCoefficient);
        }
      }

      if (newOffset != null) {
        _scrolling = true;
        await _scrollController.animateTo(newOffset,
            duration: Duration(milliseconds: duration), curve: Curves.linear);
        _scrolling = false;
        if (_pointerDown) _scrollList(context);
      }
    }
  }

  static Offset localToGlobal(RenderObject object, Offset point,
      {RenderObject ancestor}) {
    return MatrixUtils.transformPoint(object.getTransformTo(ancestor), point);
  }
}