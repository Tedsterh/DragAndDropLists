import 'package:drag_and_drop_lists/drag_and_drop_page.dart';
import 'package:example/navigation_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HorizontalExample extends StatefulWidget {
  HorizontalExample({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HorizontalExample createState() => _HorizontalExample();
}

class InnerList {
  final String name;
  List<String> children;
  InnerList({this.name, this.children});
}

class Pages {
  final String name;
  List<InnerList> children;
  Pages({this.name, this.children});
}

class _HorizontalExample extends State<HorizontalExample> {
  List<Pages> _lists;

  @override
  void initState() {
    super.initState();

    _lists = List.generate(9, (outerIndex) {
      return Pages(
        name: 'outerIndex',
        children: List.generate(9, (innerIndex) {
          return InnerList(
            name: innerIndex.toString(),
            children: List.generate(12, (innerInnerList) => '$innerIndex.$innerInnerList'),
          );
        })
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Horizontal'),
      ),
      drawer: NavigationDrawer(),
      body: Container(
        child: DragAndDropLists(
          children: List.generate(_lists.length, (index) => _buildPage(index)),
          onItemReorder: _onItemReorder,
          lastListTargetSize: 50,
          listWidth: 400,
          onListReorder: _onListReorder,
          pageController: PageController(
            keepPage: true,
          ),
          internalListPadding: EdgeInsets.all(0),
          listDecoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black45,
                spreadRadius: 3.0,
                blurRadius: 6.0,
                offset: Offset(2, 3),
              ),
            ],
          ),
          listPadding: EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  DragAndDropPage _buildPage(int pageIndex) {
    var outerList = _lists[pageIndex];
    return DragAndDropPage(
      tabID: pageIndex.toString(),
      scrollController: ScrollController(
        keepScrollOffset: false,
      ),
      children: List.generate(outerList.children.length,
          (index) => _buildList(pageIndex, index)),
      footer: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: Icon(
          Icons.add
        ),
      ),
    );
  }

  DragAndDropList _buildList(int pageIndex, int outerIndex) {
    var innerList = _lists[pageIndex].children[outerIndex];
    return DragAndDropList(
      listID: innerList.name,
      scrollController: ScrollController(
        keepScrollOffset: false,
      ),
      // isSideways: true,
      header: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
                color: Colors.pink,
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                'Header $pageIndex.${innerList.name}',
                style: Theme.of(context).primaryTextTheme.headline6,
              ),
            ),
          ),
        ],
      ),
      footer: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(7.0)),
                color: Colors.pink,
              ),
              padding: EdgeInsets.all(10),
              child: Text(
                'Footer $pageIndex.${innerList.name}',
                style: Theme.of(context).primaryTextTheme.headline6,
              ),
            ),
          ),
        ],
      ),
      leftSide: VerticalDivider(
        color: Colors.pink,
        width: 1.5,
        thickness: 1.5,
      ),
      rightSide: VerticalDivider(
        color: Colors.pink,
        width: 1.5,
        thickness: 1.5,
      ),
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
    );
  }

  _buildItem(String item) {
    return DragAndDropItem(
      taskID: item,
      child: Container(
        width: 50,
        height: 50,
        child: ListTile(
          title: Text(item),
        ),
      ),
    );
  }

  _onItemReorder(String itemID, int oldItemIndex, int oldListIndex, String oldListID, int oldPageIndex, String oldPageID, int newItemIndex, int newListIndex, String newListID, int newPageIndex, String newPageID) {
    setState(() {
      var movedItem = _lists[oldPageIndex].children[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newPageIndex].children[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(String listID, int oldListIndex, int oldPageIndex, String oldPageID, int newListIndex, int newPageIndex, String newPageID) {
    setState(() {
      var movedList = _lists[oldPageIndex].children.removeAt(oldListIndex);
      _lists[newPageIndex].children.insert(newListIndex, movedList);
    });
  }
}
