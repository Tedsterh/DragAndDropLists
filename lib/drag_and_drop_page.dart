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

class DragAndDropPage extends Equatable implements DragAndDropPageInterface {
  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  final Widget footer;

  final String tabID;

  ///
  final List<DragAndDropListInterface> children = <DragAndDropListInterface>[];

  DragAndDropPage({List<DragAndDropListInterface> children, this.footer, @required this.tabID}) {
    if (children != null) {
      children.forEach((element) => this.children.add(element));
    }
  }

  @override
  Widget generateWidget(DragAndDropBuilderParameters params, ScrollController scrollController) {
    DragAndDropListTarget dragAndDropListTarget = DragAndDropListTarget(
      parameters: params,
      tabID: tabID,
      onDropOnLastTarget: params.internalOnListDropOnLastTarget,
    );

    if (children != null && children.isNotEmpty) {
      List<Widget> contents = [];

      Widget outerListHolder;

      outerListHolder = _buildListView(params, dragAndDropListTarget, footer, scrollController);

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
          child: outerListHolder,
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

  ListView _buildListView(DragAndDropBuilderParameters parameters,
      DragAndDropListTarget dragAndDropListTarget, Widget footer, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      children: _buildOuterList(dragAndDropListTarget, parameters, footer),
    );
  }

  List<Widget> _buildOuterList(DragAndDropListTarget dragAndDropListTarget,
      DragAndDropBuilderParameters parameters, Widget footer) {
    int childrenCount = _calculateChildrenCount(false);

    return List.generate(childrenCount + 2, (index) {
      if (index == childrenCount) {
        return footer ?? Container();
      }
      if (index == childrenCount + 1) {
        return Container(
          height: 100,
        );
      }
      return _buildInnerList(
          index, childrenCount, dragAndDropListTarget, false, parameters);
    });
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

  @override
  List<Object> get props => [footer, tabID];
}
