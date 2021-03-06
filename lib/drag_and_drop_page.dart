import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_wrapper.dart';
import 'package:drag_and_drop_lists/drag_and_drop_page_interface.dart';
import 'package:visibility_detector/visibility_detector.dart';

export 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
export 'package:drag_and_drop_lists/drag_and_drop_item.dart';
export 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
export 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list_expansion.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list_target.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list_wrapper.dart';
export 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
export 'package:drag_and_drop_lists/drag_and_drop_page_interface.dart';
export 'package:drag_and_drop_lists/drag_and_drop_page_wrapper.dart';

class DragAndDropPage implements DragAndDropPageInterface {
  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  /// The widget that is displayed at the top of the list.
  final Widget header;

  final Widget footer;

  final String tabID;

  final ScrollController _scrollController;

  ///
  final List<DragAndDropListInterface> children = <DragAndDropListInterface>[];

  DragAndDropPage({List<DragAndDropListInterface> children, this.footer, this.header, @required this.tabID, @required ScrollController scrollController})
    : assert(scrollController != null),
      _scrollController = scrollController {
    if (children != null) {
      children.forEach((element) => this.children.add(element));
    }
  }

  bool _pointerDown = false;
  double _pointerYPosition;
  double _pointerXPosition;
  bool _scrolling = false;

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    DragAndDropListTarget dragAndDropListTarget = DragAndDropListTarget(
      parameters: params,
      tabID: tabID,
      onDropOnLastTarget: params.internalOnListDropOnLastTarget,
      lastListTargetSize: params.lastListTargetSize,
    );

    if (children != null && children.isNotEmpty) {
      List<Widget> contents = [];

      Widget outerListHolder;

      outerListHolder = _buildListView(params, dragAndDropListTarget, footer, _scrollController);

      if (children.where((e) => e is DragAndDropListExpansionInterface).isNotEmpty) {
        outerListHolder = Column(
          children: contents,
        );
      }
      return Builder(
        builder: (context) => VisibilityDetector(
          key: Key('$tabID'),
          onVisibilityChanged: (info) {
            var visiblePercentage = info.visibleFraction * 100;
            if (visiblePercentage == 100.0) {
              params.onPageChange?.call(tabID);
            }
          },
          child: Listener(
            onPointerMove: (event) => _onPointerMove(event, context),
            onPointerDown: _onPointerDown,
            onPointerUp: _onPointerUp,
            child: outerListHolder,
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Empty'),
            dragAndDropListTarget,
          ],
        ),
      );
    }
  }

  Column _buildListView(DragAndDropBuilderParameters parameters, DragAndDropListTarget dragAndDropListTarget, Widget footer, ScrollController scrollController) {
    int count = _calculateChildrenCount(false);
    return Column(
      children: [
        header ?? Container(),
        Flexible(
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.all(0),
            cacheExtent: 1000,
            shrinkWrap: true,
            addAutomaticKeepAlives: true,
            children: [
              ListView.builder(
                addAutomaticKeepAlives: true,
                cacheExtent: 1000,
                shrinkWrap: true,
                padding: parameters.listPadding,
                physics: NeverScrollableScrollPhysics(),
                itemCount: count,
                itemBuilder: (context, index) {
                  return _buildInnerList(index, count,
                      dragAndDropListTarget, false, parameters);
                },
              ),
              footer ?? Container(),
              Container(
                height: 100,
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _calculateChildrenCount(bool includeSeparators) {
    if (includeSeparators)
      return ((children?.length ?? 0) * 2) - (1) + 1;
    else
      return (children?.length ?? 0) + 1;
  }

  Widget _buildInnerList(
      int index,
      int childrenCount,
      DragAndDropListTarget dragAndDropListTarget,
      bool includeSeparators,
      DragAndDropBuilderParameters parameters) {
    if (index == childrenCount - 1) {
      return dragAndDropListTarget;
    } else {
      return DragAndDropListWrapper(
        dragAndDropList:
            children[(includeSeparators ? index / 2 : index).toInt()],
        parameters: parameters,
      );
    }
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
