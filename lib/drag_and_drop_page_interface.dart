import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:flutter/material.dart';

abstract class DragAndDropPageInterface implements DragAndDropInterface {
  Widget get footer;

  String get tabID;

  List<DragAndDropListInterface> get children;

  Widget generateWidget(DragAndDropBuilderParameters params, ScrollController scrollController);
}
