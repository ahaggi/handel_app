import 'package:flutter/material.dart';
import 'package:handle_app/config/attrconfig.dart';


// _vare = [
//       {
//         STREKKODE: 101010103696,
//         MENGDE: 1,
//         PRODUKT_ID: "101010103696",
//         TOTALPRIS: 27.0,
//         navn: "Salat",
//         PRIS: 27.0
//         BRGN_NAERING : true
//       }
//        ,
//       {...
//       }
// ]
class VarerExpansionTile extends StatelessWidget {
  VarerExpansionTile({this.varerList});
  final List<dynamic> varerList; // list with varer

  @override
  Widget build(BuildContext context) {
    var entriesList = List.generate(varerList.length, (index) {
      var _vare = varerList[index];
      return Entry(
        title: (_vare ?? {})[NAVN] != null ? _vare[NAVN] : "",
        subTitle: (_vare ?? {})[TOTALPRIS] != null
            ? _vare[TOTALPRIS].toStringAsFixed(2)
            : "",
        data: _vare,
      );
    });

    final List<Entry> _entriesList = <Entry>[
      Entry(
          title: "Varer (" + varerList.length.toString() + ")",
          children: entriesList)
    ];

    Widget getListVare() => Column(
        children: List.generate(
            _entriesList.length, (int index) => VareItem(_entriesList[index])));

    return getListVare();
  }
}

class VareItem extends StatelessWidget {
  const VareItem(this.entry);

  final Entry entry;

  /// ********************_buildTiles.if(entry.vare != null)*******************/
  List<Widget> vareDetail(Map<dynamic, dynamic> vare) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(children: [Text(vare[NAVN].toString())]),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("Pris"),
            ),
            Text(vare[PRIS].toStringAsFixed(2))
          ]),
          Column(children: <Widget>[Text("X")]),
          Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text((vare[ER_LEOSVEKT]?? true) ? "Vekt(kg)":"Antall"),
            ),
            Text(vare[MENGDE].toStringAsFixed(2))
          ]),
          Column(children: <Widget>[Text("=")]),
          Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text("TotalPris"),
            ),
            Text("kr " + vare[TOTALPRIS].toStringAsFixed(2))
          ]),
        ],
      ),
    ];
  }

//*************************************************************************/
// OBS denne er intern-node i tre, dvs ExpansionTile som ikke innholder andre ExpansionTiles
  Widget getVareExpansionTile(Entry leaf) => ExpansionTile(
        key: PageStorageKey<Entry>(leaf),
        title: Row(
          children: <Widget>[
            Expanded(child: Text(leaf.title)),
            Text(leaf.subTitle)
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left:24.0, right: 24.0),
            child: Column(children: vareDetail(leaf.data)),
          )
        ],
      );

//********************_buildTiles.if(entry.vare == null)*******************/
//OBS foreløpig blir den kun brukt for ExpantionTile som har text "Varer"
  Widget getRootExpansionTile(Entry root) => ExpansionTile(
        key: PageStorageKey<Entry>(root),
        title: Center(
            child: Text(
          root.title,
        )),
        children: root.children.map(_buildTiles).toList(),
      );
  //***********************************************************************/

  Widget _buildTiles(Entry entry) {
    if (entry.data != null) return getVareExpansionTile(entry);
    return getRootExpansionTile(entry); //recursively
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

class Entry {
  Entry(
      {this.title,
      this.subTitle: "",
      this.children: const <Entry>[],
      this.data});
  final String title;
  final String
      subTitle; // if subTitle is empty the title will be centred, otherwise the

  final List<Entry> children; // which will be presented in the ExpansionTile
  final Map<dynamic, dynamic> data; // which will be presented in the Tile
}
