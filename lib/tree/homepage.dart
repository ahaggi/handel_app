import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'dart:async';
import 'package:handle_app/routes.dart';

class HomePage extends StatefulWidget {
  HomePage({this.onSignOutCbk, this.userID});
  final VoidCallback onSignOutCbk;
  final String userID;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<MyTile> _tiles = [
      MyTile(
          label: 'Handle',
          route: handle,
          crossAxisCellCount: 2,
          mainAxisCellCount: 2),
      MyTile(
          label: 'Produkter',
          route: produkter,
          crossAxisCellCount: 2,
          mainAxisCellCount: 1),
      MyTile(
          label: 'Add Produkt',
          route: addProdukt,
          crossAxisCellCount: 2,
          mainAxisCellCount: 2),
      MyTile(
          label: 'Add Handel',
          route: addHandel,
          crossAxisCellCount: 2,
          mainAxisCellCount: 2),
      MyTile(
          label: 'storage',
          route: storage,
          crossAxisCellCount: 2,
          mainAxisCellCount: 1),
      MyTile(
          label: 'Charts',
          route: charts,
          crossAxisCellCount: 3,
          mainAxisCellCount: 1),
      MyTile(
          label: '<T>',
          route: null,
          crossAxisCellCount: 1,
          mainAxisCellCount: 1),
    ]..addAll(List.generate(
        (11 - 7),
        (ind) => MyTile(
            label: '${ind + 1 + 7}',
            route: null,
            crossAxisCellCount: 2,
            mainAxisCellCount: 1),
      ));

    Widget getGrid() => StaggeredGridView.countBuilder(
          crossAxisCount: 4,
          itemCount: _tiles.length,
          itemBuilder: (BuildContext context, int index) {
            MyTile _tile = _tiles[index];
            return InkWell(
              onTap: _tile.route != null
                  ? () => Navigator.of(context).pushNamed(_tile.route)
                  : null,
              child: Card(
                  color: Theme.of(context).backgroundColor,
                  child: Center(
                    child: Text(
                      _tile.label,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  )),
            );
          },
          staggeredTileBuilder: (int index) {
            MyTile _tile = _tiles[index];
            return StaggeredTile.count(
                _tile.crossAxisCellCount, _tile.mainAxisCellCount);
          },
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
        );

    //CaseStudy
    Future<bool> _exitApp(BuildContext context) {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Do you want to exit this application?'),
              content: Text('We hate to see you leave...'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes'),
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
              ],
            );
          });
    }

    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
          appBar: AppBar(title: Text('HomePage'),
              // leading: IconButton(
              //   tooltip: 'Previous choice',
              //   icon: const Icon(Icons.arrow_back),
              //   onPressed: () => Navigator.of(context).pop() ,
              // ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.list), onPressed: widget.onSignOutCbk)
              ]),
          body: getGrid()),
    );
  }
}

class MyTile {
  MyTile({
    this.label,
    this.route,
    this.crossAxisCellCount,
    this.mainAxisCellCount,
    this.icon, //TODO
    this.color, //TODO
  });
  String label;
  String route;
  int crossAxisCellCount;
  int mainAxisCellCount;
  Icon icon;
  Color color;
}
