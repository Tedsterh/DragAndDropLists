import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_page_interface.dart';
import 'package:flutter/material.dart';

class DragAndDropPageWrapper extends StatefulWidget {
  final DragAndDropPageInterface dragAndDropPageInterface;
  final DragAndDropBuilderParameters parameters;

  DragAndDropPageWrapper({Key key, this.dragAndDropPageInterface, this.parameters}) : super(key: key);

  @override
  _DragAndDropPageWrapperState createState() => _DragAndDropPageWrapperState();
}

class _DragAndDropPageWrapperState extends State<DragAndDropPageWrapper> {
  @override
  Widget build(BuildContext context) {
    Widget dragAndDropPageContents = widget.dragAndDropPageInterface.generateWidget(widget.parameters);
    return dragAndDropPageContents;
  }
}