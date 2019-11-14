import 'package:flutter/material.dart';
import 'package:handle_app/tree/handle/handelList/subWidgets/varerWidget.dart';
import 'package:handle_app/config/attrconfig.dart';

class HandelCardWidget extends StatelessWidget {
  HandelCardWidget({
    @required this.handel,
    @required this.onEdit,
    @required this.onDelete,
  });

  final Map<String, dynamic> handel;
  final dynamic onEdit;
  final dynamic onDelete;

  @override
  Widget build(BuildContext context) {
    final _labelFont = const TextStyle(fontSize: 14.0);
    final _dataFont = const TextStyle(fontSize: 16.0);
    final _dataBoldFont =
        const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

    final _boxDecoration = BoxDecoration(
      color: Theme.of(context).backgroundColor,
      shape: BoxShape.rectangle,
      borderRadius: new BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black12,
          blurRadius: 10.0,
          offset: new Offset(0.0, 10.0),
        ),
      ],
    );

    Widget _iconButtons = (onDelete != null && onEdit != null)
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.delete_forever),
                iconSize: 24.0,
                onPressed: onDelete,
              ),
              IconButton(
                icon: Icon(Icons.edit),
                iconSize: 24.0,
                onPressed: onEdit,
              ),
            ],
          )
        : Container();

    Widget _getTopRowSection({String butikk, String dato}) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Text(
                    "Butikk:",
                    style: _labelFont,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      butikk,
                      style: _dataBoldFont,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  // "00/00/0000",
                  dato.substring(0, 10),
                  style: _dataFont,
                ),
                Text(
                  // "T00:00:00",
                  dato.length > 10 ? dato.substring(11) : "",
                  style: _dataFont,
                )
              ],
            )
          ],
        );

    Widget _getMiddelSection({List<dynamic> varer}) =>
        VarerExpansionTile(varerList: varer);

    Widget _getBottumSection({dynamic summen}) {
      return Row(children: <Widget>[
        _iconButtons,
        Expanded(child: Container()),
        Text("Summen:"),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 40.0),
          child: Text(summen.toStringAsFixed(2), style: _dataBoldFont),
        )
      ]);
    }

    Widget getCard(Map<String, dynamic> data) => new Container(
          child: Column(
            children: <Widget>[
              _getTopRowSection(butikk: data[BUTIKK], dato: data[DATO]),
              // Row(
              //   children: <Widget>[
              //     //Flexible tells the framework to let the ExpansionTile to expand to fill the Row width, alternativly readMore about "Box Constraints"
              //     Flexible(child: getBody(varer: data[VARER]))
              //   ],
              // ),
              _getMiddelSection(varer: data[VARER]),
              _getBottumSection(summen: (data[SUMMEN])),
            ],
          ),
          padding: EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 8.0,
          ),
          decoration: _boxDecoration,
        );

    return getCard(handel);
  }
}
