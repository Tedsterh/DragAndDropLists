import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';

class DragAndDropList extends Equatable implements DragAndDropListInterface {
  /// The widget that is displayed at the top of the list.
  final Widget header;

  final bool isSideways;

  /// The widget that is displayed at the bottom of the list.
  final Widget footer;

  /// The widget that is displayed to the left of the list.
  final Widget leftSide;

  /// The widget that is displayed to the right of the list.
  final Widget rightSide;

  /// The widget to be displayed when a list is empty.
  /// If this is not null, it will override that set in [DragAndDropLists.contentsWhenEmpty].
  final Widget contentsWhenEmpty;

  /// The widget to be displayed as the last element in the list that will accept
  /// a dragged item.
  final Widget lastTarget;

  /// The decoration displayed around a list.
  /// If this is not null, it will override that set in [DragAndDropLists.listDecoration].
  final Decoration decoration;

  /// The vertical alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.verticalAlignment].
  final CrossAxisAlignment verticalAlignment;

  /// The horizontal alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.horizontalAlignment].
  final MainAxisAlignment horizontalAlignment;

  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  final List<DragAndDropItem> children = <DragAndDropItem>[];

  final String listID;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  final bool canDrag;

  final bool isSmallWidget;

  final bool isLargeWidget;

  ScrollController _scrollController = ScrollController();
  bool _pointerRight = false;
  double _pointerYPosition;
  double _pointerXPosition;
  bool _scrolling = false;

  DragAndDropList(
      {List<DragAndDropItem> children,
      this.header,
      this.footer,
      this.leftSide,
      this.rightSide,
      this.contentsWhenEmpty,
      this.lastTarget,
      this.decoration,
      this.isSideways = false,
      this.horizontalAlignment = MainAxisAlignment.start,
      this.verticalAlignment = CrossAxisAlignment.start,
      this.canDrag = true,
      this.isSmallWidget = false,
      this.isLargeWidget = false,
      @required this.listID}) {
    if (children != null) {
      children.forEach((element) => this.children.add(element));
    }
  }

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    var contents = <Widget>[];
    if (header != null) {
      contents.add(Flexible(child: header));
    }
    Widget intrinsicHeight = IntrinsicHeight(
      child: Row(
        mainAxisAlignment: horizontalAlignment,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _generateDragAndDropListInnerContents(params),
      ),
    );
    if (isSideways) {
      intrinsicHeight = Container(
        width: params.listWidth,
        child: intrinsicHeight,
      );
    }
    if (params.axis == Axis.horizontal) {
      intrinsicHeight = Container(
        width: params.listWidth,
        child: intrinsicHeight,
      );
    }
    if (params.listInnerDecoration != null) {
      intrinsicHeight = Container(
        decoration: params.listInnerDecoration,
        child: intrinsicHeight,
      );
    }
    contents.add(intrinsicHeight);

    if (footer != null) {
      contents.add(Flexible(child: footer));
    }

    if (isSideways) {
      // return Container(
      //   width: 300,
      //   decoration: decoration ?? params.listDecoration,
      //   height: 80,
      //   child: Row(
      //     mainAxisSize: MainAxisSize.min,
      //     crossAxisAlignment: verticalAlignment,
      //     children: [
      //       ListTile(),
      //     ],
      //   ),
      // );
    }
    return Container(
      width: params.axis == Axis.vertical
          ? double.infinity
          : params.listWidth - params.listPadding.horizontal,
      clipBehavior: Clip.none,
      decoration: decoration ?? params.listDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: verticalAlignment,
        children: contents,
      ),
    );
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters params) {
    var contents = <Widget>[];
    if (leftSide != null) {
      contents.add(leftSide);
    }
    if (children != null && children.isNotEmpty) {
      List<Widget> allChildren = <Widget>[];
      if (params.addLastItemTargetHeightToTop) {
        allChildren.add(Padding(
          padding: EdgeInsets.only(top: params.lastItemTargetHeight),
        ));
      }
      for (int i = 0; i < children.length; i++) {
        allChildren.add(DragAndDropItemWrapper(
          isSideways: isSideways,
          child: children[i],
          parameters: params,
        ));
        if (params.itemDivider != null && i < children.length - 1) {
          allChildren.add(params.itemDivider);
        }
      }
      if (isSideways) {
        allChildren.add(DragAndDropItemTarget(
          isSideways: isSideways,
          parent: this,
          isLargeWidget: isLargeWidget,
          parameters: params,
          isSmallWidget: isSmallWidget,
          onReorderOrAdd: params.onItemDropOnLastTarget,
          child: lastTarget ??
              Container(
                width: params.lastItemTargetHeight,
              ),
        ));
      } else {
        allChildren.add(DragAndDropItemTarget(
          isSideways: isSideways,
          parent: this,
          isLargeWidget: isLargeWidget,
          parameters: params,
          isSmallWidget: isSmallWidget,
          onReorderOrAdd: params.onItemDropOnLastTarget,
          child: lastTarget ??
              Container(
                height: params.lastItemTargetHeight,
              ),
        ));
      }
      if (isSideways) {
        contents.add(
          Expanded(
            child: Builder(
              builder: (context) {
                return Listener(
                  onPointerMove: (event) => _onPointerMove(event, context),
                  onPointerDown: _onPointerRight,
                  onPointerUp: _onPointerLeft,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    physics: ClampingScrollPhysics(),
                    child: Row(
                      crossAxisAlignment: verticalAlignment,
                      mainAxisSize: MainAxisSize.min,
                      children: allChildren,
                    ),
                  ),
                );
              }
            ),
          ),
        );
      } else {
        contents.add(
          Expanded(
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: verticalAlignment,
                mainAxisSize: MainAxisSize.max,
                children: allChildren,
              ),
            ),
          ),
        );
      }
    } else {
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                contentsWhenEmpty ??
                    Text(
                      'Empty list',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                DragAndDropItemTarget(
                  isSideways: isSideways,
                  isSmallWidget: isSmallWidget,
                  isLargeWidget: isLargeWidget,
                  parent: this,
                  parameters: params,
                  onReorderOrAdd: params.onItemDropOnLastTarget,
                  child: lastTarget ??
                      Container(
                        height: params.lastItemTargetHeight,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (rightSide != null) {
      contents.add(rightSide);
    }
    return contents;
  }

  _onPointerMove(PointerMoveEvent event, context) {
    if (_pointerRight) {
      _pointerYPosition = event.position.dy;
      _pointerXPosition = event.position.dx;

      if (_scrollController.hasClients) {
        _scrollList(context);
      }
    }
  }

  _onPointerRight(PointerDownEvent event) {
    _pointerRight = true;
    _pointerYPosition = event.position.dy;
    _pointerXPosition = event.position.dx;
  }

  _onPointerLeft(PointerUpEvent event) {
    _pointerRight = false;
  }

  _scrollList(context) async {
    if (_scrollController != null) {
      if (!_scrolling &&
          _pointerRight &&
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

        double left = topLeftOffset.dx;
        double right = bottomRightOffset.dx;

        if (_pointerXPosition < (left + scrollAreaSize) &&
            _scrollController.position.pixels >
                _scrollController.position.minScrollExtent) {
          final overDrag =
              max((left + scrollAreaSize) - _pointerXPosition, overDragMax);
          newOffset = max(
              _scrollController.position.minScrollExtent,
              _scrollController.position.pixels -
                  step * overDrag / overDragCoefficient);
        } else if (_pointerXPosition > (right - scrollAreaSize) &&
            _scrollController.position.pixels <
                _scrollController.position.maxScrollExtent) {
          final overDrag = max<double>(
              _pointerYPosition - (right - scrollAreaSize), overDragMax);
          newOffset = min(
              _scrollController.position.maxScrollExtent,
              _scrollController.position.pixels +
                  step * overDrag / overDragCoefficient);
        }

        if (newOffset != null) {
          _scrolling = true;
          await _scrollController.animateTo(newOffset,
              duration: Duration(milliseconds: duration), curve: Curves.linear);
          _scrolling = false;
          if (_pointerRight && _scrollController.hasClients) _scrollList(context);
        }
      }
    }
  }

  static Offset localToGlobal(RenderObject object, Offset point,
      {RenderObject ancestor}) {
    return MatrixUtils.transformPoint(object.getTransformTo(ancestor), point);
  }

  @override
  List<Object> get props {
    return [
      header,
      isSideways,
      footer,
      leftSide,
      rightSide,
      contentsWhenEmpty,
      lastTarget,
      decoration,
      verticalAlignment,
      horizontalAlignment,
      listID,
      canDrag,
      isSmallWidget,
      isLargeWidget,
      _pointerRight,
      _pointerYPosition,
      _pointerXPosition,
      _scrolling,
    ];
  }
}
