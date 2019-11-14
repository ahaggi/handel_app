import 'package:flutter/material.dart';

class EntryItem extends StatelessWidget {
  EntryItem(final Map<dynamic, dynamic> tree) {
    this.entry = getEntriesList(tree)[0];
  }

  Entry entry;

  List<Entry> getEntriesList(Map<dynamic, dynamic> data) {
    List<Entry> entriesList = <Entry>[];

    data.forEach((k, v) {
      List<Entry> _children = [];
      String subTitle;
      if (v is Map) {
        _children = getEntriesList(v);
        subTitle = (v ?? {})["totalt"] != null ? v["totalt"].toString() : "";
      } else
        subTitle = v != null
            ? v.toString()
            : ""; // subTitle for a listTile is always the value of an entry in a Map

      var _entry = Entry(title: k, subTitle: subTitle, children: _children);
      if (_entry.title != "totalt") entriesList.add(_entry);
    });

    return entriesList;
  }

  Widget _buildTiles(Entry node, {double exrtaMargin = 0.0}) {
    if (node.children.isEmpty)
      return ListTile(
          title: Container(
              margin: EdgeInsets.only(right: 40.0, left: exrtaMargin),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Text(node.title)),
                  Text(node.subTitle.toString())
                ],
              )));
    //node.children.isNotEmpty
    else {
      if (node.subTitle.isNotEmpty)
        return ExpansionTile(
          key: PageStorageKey<Entry>(node),
          title: Container(
              child: Row(children: [
                Expanded(child: Text("${node.title} ")),
                Text(node.subTitle)
              ])),
          children: node.children
              .map((node) => _buildTiles(node, exrtaMargin: 16.0))
              .toList(),
        );
      else
        return ExpansionTile(
          key: PageStorageKey<Entry>(node),
          title: Center(child: Text("${node.title}")),
          children: node.children.map(_buildTiles).toList(),
        );
    }
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
      });
  final String title;
  final String
      subTitle; // if subTitle is empty the title will be centred, otherwise the

  final List<Entry> children; // which will be presented in the ExpansionTile
}
