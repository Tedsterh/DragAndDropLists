import 'package:flutter/material.dart';

import 'drag_and_drop_builder_parameters.dart';
import 'drag_and_drop_interface.dart';
import 'drag_and_drop_list_interface.dart';

abstract class DragAndDropPageInterface implements DragAndDropInterface {
  Widget get footer;

  String get tabID;

  List<DragAndDropListInterface> get children;

  Widget generateWidget(DragAndDropBuilderParameters params);
}
