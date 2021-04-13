import 'package:example/horizontal_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag and Drop Lists',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        // '/': (context) => BasicExample(),
        // '/list_tile_example': (context) => ListTileExample(),
        // '/expansion_tile_example': (context) => ExpansionTileExample(),
        // '/sliver_example': (context) => SliverExample(),
        '/': (context) => HorizontalExample(),
        // '/drag_into_list_example': (context) => DragIntoListExample(),
        // '/fixed_example': (context) => FixedExample(),
        // '/drag_handle_example': (context) => DragHandleExample(),
      },
    );
  }
}
