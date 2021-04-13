import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:flutter/material.dart';

import 'drag_and_drop_list_target.dart';
import 'drag_and_drop_list_wrapper.dart';
import 'drag_and_drop_page_interface.dart';

class DragAndDropPage implements DragAndDropPageInterface {
  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  final Widget footer;
  /// 
  final List<DragAndDropListInterface> children = <DragAndDropListInterface>[];

  DragAndDropPage({List<DragAndDropListInterface> children, this.footer}) {
    if (children != null) {
      children.forEach((element) => this.children.add(element));
    }
  }

  PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    DragAndDropListTarget dragAndDropListTarget = DragAndDropListTarget(
      parameters: params,
      onDropOnLastTarget: params.internalOnListDropOnLastTarget,
    );

    if (children != null && children.isNotEmpty) {
      List<Widget> contents = [];

      Widget outerListHolder;

      outerListHolder = _buildListView(params, dragAndDropListTarget);

      contents.add(outerListHolder);

      if (footer != null) {
        contents.add(footer);
      }

      if (children.where((e) => e is DragAndDropListExpansionInterface).isNotEmpty) {
        outerListHolder = PageStorage(
          child: Column(
            children: contents,
          ),
          bucket: _pageStorageBucket,
        );
      }
      return outerListHolder;
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

  ListView _buildListView(DragAndDropBuilderParameters parameters, DragAndDropListTarget dragAndDropListTarget) {
    return ListView(
      controller: parameters.listController,
      children: _buildOuterList(dragAndDropListTarget, parameters),
    );
  }

  List<Widget> _buildOuterList(DragAndDropListTarget dragAndDropListTarget,
      DragAndDropBuilderParameters parameters) {
    int childrenCount = _calculateChildrenCount(false);

    return List.generate(childrenCount, (index) {
      return _buildInnerList(index, childrenCount, dragAndDropListTarget,
          false, parameters);
    });
  }

  int _calculateChildrenCount(bool includeSeparators) {
    if (includeSeparators)
      return ((children?.length ?? 0) * 2) -
          (1) +
          1;
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

}