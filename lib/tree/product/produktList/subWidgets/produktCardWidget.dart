
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:handle_app/tree/product/produktList/subWidgets/expansionTileFromEntryTREE.dart';
import 'package:handle_app/config/attrconfig.dart';

class ProduktCardWidget extends StatelessWidget {
  ProduktCardWidget(
      {@required this.produkt,
      @required this.onEdit,
      @required this.onDelete,
      @required this.getImageFromFirebaseStorageCallback});
  final Map<String, dynamic> produkt;

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final dynamic getImageFromFirebaseStorageCallback;

  final _labelFont = const TextStyle(fontSize: 14.0);
  final _dataFont =
      const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  final _dataFontColored = const TextStyle(
      fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.red);
  final _dataBoldFont =
      const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);

  BoxDecoration _boxDecoration(BuildContext context) => BoxDecoration(
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

  ///******************************************************************************* */

  Widget getProdDesc(
      {String navn, String strekkode, String nettovekt, String kommentar}) {
    Widget _prodName = Text(
      navn,
      style: _dataBoldFont,
              overflow: TextOverflow.ellipsis,

    );
    Widget _barcodeIcon = Image.asset(
      'resources/images/barcode.png',
      width: 24.0,
      height: 24.0,
      fit: BoxFit.cover,
    );
    Widget _barcodeText = Text(
      strekkode.isNotEmpty ? strekkode : "Mangler strekkode",
      style: strekkode.isNotEmpty ? _dataFont : _dataFontColored,
    );
    List<Widget> _nettovektWidget = [
      Text(
        "Nettovekt",
        style: _labelFont,
      ),
      Text(
        nettovekt,
        style: _dataFont,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      )
    ];
    List<Widget> _kommentarWidget = [
      Text(
        "Kommentar",
        style: _labelFont,
      ),
      Text(
        kommentar,
        style: _dataFont,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      )
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _prodName,
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_barcodeIcon, _barcodeText]),
        Container(
          margin: EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Column(
                  children: _nettovektWidget,
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  children: _kommentarWidget,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getImage() {
    // if (getImageFromFirebaseStorageCallback != null)
    //   return getImageFromFirebaseStorageCallback(
    //       strekkode: this.produkt[STREKKODE], navn: this.produkt[navn]);
    // else
    return Image.asset(
      "resources/images/Capture2.png",
      fit: BoxFit.cover,
    );
  }

  List<Widget> getCardTopSection() {
    //card's top

    return <Widget>[
      Expanded(
        flex: 2,
        child: getProdDesc(
            strekkode: this.produkt[STREKKODE] != null
                ? this.produkt[STREKKODE].toString()
                : "",
            navn: this.produkt[NAVN],
            nettovekt: this.produkt[NETTOVEKT].toString(),
            kommentar: this.produkt[KOMMENTAR].toString()
            // erLoesvekt: this.produkt[ER_LEOSVEKT].toString()

            ),
      ),
      Expanded(flex: 1, child: getImage())
    ];
  }

  ///******************************************************************************* */

  LinkedHashMap<dynamic, dynamic> getStructuredNaeringsinnhold(
      Map<dynamic, dynamic> naeringsinnhold) {
    LinkedHashMap<dynamic, dynamic> orderedMap =
        LinkedHashMap<dynamic, dynamic>();
    orderedMap[ENERGI] = naeringsinnhold[ENERGI] ?? 0;
    orderedMap[KALORIER] = naeringsinnhold[KALORIER] ?? 0;

    orderedMap[FETT] = LinkedHashMap<dynamic, dynamic>();
    orderedMap[FETT][ENUMETTET] = naeringsinnhold[ENUMETTET] ?? 0;
    orderedMap[FETT][FLERUMETTET] = naeringsinnhold[FLERUMETTET] ?? 0;
    orderedMap[FETT][METTET_FETT] = naeringsinnhold[METTET_FETT] ?? 0;

    orderedMap[FETT]["totalt"] = naeringsinnhold[FETT] ?? 0;

    orderedMap[KARBOHYDRATER] = LinkedHashMap<dynamic, dynamic>();
    orderedMap[KARBOHYDRATER][SUKKERARTER] =
        naeringsinnhold[SUKKERARTER] ?? 0;
    orderedMap[KARBOHYDRATER][STIVELSE] = naeringsinnhold[STIVELSE] ?? 0;
    orderedMap[KARBOHYDRATER]["totalt"] =
        naeringsinnhold[KARBOHYDRATER] ?? 0;

    orderedMap[KOSTFIBER] = naeringsinnhold[KOSTFIBER] ?? 0;
    orderedMap[PROTEIN] = naeringsinnhold[PROTEIN] ?? 0;
    orderedMap[SALT] = naeringsinnhold[SALT] ?? 0;

    return orderedMap;
  }

  Widget getNaeringsinnhold({LinkedHashMap<dynamic, dynamic> naeringsinnhold}) {
    var orderedMap = getStructuredNaeringsinnhold(naeringsinnhold);
    var data = {"Næringinnhold per 100g ": orderedMap};
    return Column(children: [EntryItem(data)]);
  }

  Widget getExtraInfo({Map<dynamic, dynamic> info}) {
    var orderedMap =
        SplayTreeMap<String, dynamic>.from(info, (a, b) => a.compareTo(b));
    var data = {"Ekstra info!": orderedMap};
    return Column(children: [EntryItem(data)]);
  }

  Widget getCardButtomSection() {
    if (this.produkt[INFO][NAERINGSINNHOLD] != null)
      return getNaeringsinnhold(
          naeringsinnhold: this.produkt[INFO][NAERINGSINNHOLD]);

    return getExtraInfo(info: this.produkt[INFO]);
  }

  ///******************************************************************************* */
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: getCardTopSection()),
          Row(
            children: <Widget>[
              //Flexible tells the framework to let the ExpansionTile to expand to fill the Row width, alternativly readMore about "Box Constraints"
              Flexible(child: getCardButtomSection()),
            ],
          ),
          (onDelete != null && onEdit != null)
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
              : Container()
        ],
      ),
      padding: EdgeInsets.only(top: 16.0, right: 16.0),
      margin: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 8.0,
      ),
      decoration: _boxDecoration(context),
    );
  }
}
