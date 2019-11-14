import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handle_app/tree/todo/utilWidget/myTextField.dart';

import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'dart:async';

import 'package:handle_app/tree/todo/utilWidget/barCodeReaderWidget.dart';
import 'package:handle_app/tree/todo/utilWidget/myCallback.dart';
import 'package:handle_app/tree/todo/utilWidget/TypeAheadMixin.dart';
import 'package:handle_app/db/db.dart';
import 'package:handle_app/tree/todo/utilWidget/utilUI.dart';
import 'package:handle_app/config/attrconfig.dart';

class VarerListWidget extends StatefulWidget {
  VarerListWidget(
      {this.varerState,
      this.onAddToVarerState,
      this.onRemoveOneFromVarerList,
      this.onRemoveAllFromVarerList,
      this.onGetVareBystrekkode,
      this.pageController});

  final Map<String, dynamic> varerState;
  final MCDynamicVoid onAddToVarerState;
  final MCDynamicVoid onRemoveOneFromVarerList;
  final MCDynamicVoid onRemoveAllFromVarerList;
  final MCdynamicDynamic onGetVareBystrekkode;
  final PageController pageController;

  @override
  VarerListWidgetState createState() {
    return VarerListWidgetState();
  }
}

class VarerListWidgetState extends State<VarerListWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<dynamic, dynamic> zIndexMap;
  SplayTreeMap<double, dynamic> focusNodeMap =
      SplayTreeMap<double, dynamic>.from({}, (a, b) => a.compareTo(b));

  int toggleTile;
  bool isBottomSheetActive = false;
  bool bottomSheetShownRec = false;

  TextEditingController vareNvnCtrl = TextEditingController();
  FocusNode vareNvnNode = FocusNode();

  VoidCallback onScrollHandler;
  void setOnScrollHandler(function) {
    onScrollHandler = function;
  }

  void processCodeHandler(strekkode) async {
    // fjern bottomSheet if isBottomSheetActive
    if (isBottomSheetActive)
      Navigator.popUntil(context, ModalRoute.withName('/AddnewHandle_PageViewer'));

    Map<String, dynamic> vare = await widget.onGetVareBystrekkode(strekkode);

    // "vare" details ( especially PRODUKT_ID ) can be empty, which means the "produkt" isn't registered in the db
    // we've to check that before submitting!
    widget.onAddToVarerState(vare);
  }

  void getBottomSheet(BuildContext context) {
    /// callbacks
    void _whenCompleteHandler() {
      isBottomSheetActive = false;
      if (bottomSheetShownRec)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) getBottomSheet(context);
        });
      print("============================whenComplete============================");
    }

    void onBottomSheetCancelHandler() {
      bottomSheetShownRec = false;
      setState(() {});
    }

    /// *******************************************
    ///

    isBottomSheetActive = true;
    setState(() {});

    Widget _childWidget = BarCodeReaderWidget(
      onSeccessfulReadCallback: processCodeHandler,
      oncancelCallback: onBottomSheetCancelHandler,
    );
    bottomSheetShownRec = true;

    UtilUI.showBottomSheet(
        context: context,
        scaffoldKey: _scaffoldKey,
        childWidget: _childWidget,
        onWhenComplete: _whenCompleteHandler);

    // .showBottomSheet return PersistentBottomSheetController which extends ScaffoldFeatureController
    // ScaffoldFeatureController.closed return → Future<dynamic>
    // Future.whenComplete
    // future = controller.closed;
    // future.then(...);
    // future.whenComplete(...) https://api.dartlang.org/stable/2.0.0/dart-async/Future/whenComplete.html
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleBtnText = TextStyle(fontSize: 20.0);

    BoxDecoration getBoxDecorationListTile(bool b) => BoxDecoration(
          color: b ? Theme.of(context).backgroundColor : Theme.of(context).cardColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        );

    final _boxDecorationBottomListTile = BoxDecoration(
      color: Theme.of(context).toggleableActiveColor,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10.0,
          offset: Offset(0.0, 10.0),
        ),
      ],
    );

    Widget getLoesVektTextField(vare) {
      return Container(
        child: MyTextField(
          enabled: true,
          value: (vare[MENGDE] ?? 0.0).toString(),
          onChanged: (text) {
            vare[MENGDE] = Util.parseStringtoNum(text) ?? 0.0;
            vare[TOTALPRIS] = vare[MENGDE] * vare[PRIS];
          },
          keyboardType: TextInputType.number,
          decoration: {
            "labelText": 'vekt (kg)',
            "labelStyle": TextStyle(fontSize: 14.0),
            "errorBorder": OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            "errorStyle": TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            "errorText": "wqeqweqwe",
          },
          validateInputHandler: (text) {
            num value = Util.parseStringtoNum(text);
            bool _isGt0 = value != null && value > 0;
            return text.isEmpty || _isGt0;
          },
        ),
        decoration: BoxDecoration(
          color: Colors.brown,
        ),
      );
    }

    Widget getCheckBox(vare) => Container(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('brgnNaer', style: TextStyle(fontSize: 11.0)),
            Checkbox(
                value: vare[BRGN_NAERING],
                onChanged: (bool value) {
                  vare[BRGN_NAERING] = value;
                  setState(() {});
                }),
          ]),
          decoration: BoxDecoration(
            color: Colors.indigo,
          ),
        );

    Widget getListTileForLoesVekt(Map<String, dynamic> vare, int index) {
      return Column(children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: IconButton(
            iconSize: 40.0,
            icon: Icon(Icons.delete_forever),
            color: Theme.of(context).accentColor,
            onPressed: () {
              widget.onRemoveAllFromVarerList(vare);
            },
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                  flex: 11,
                  child: Container(
                    child: Text(
                      vare[NAVN],
                      overflow: TextOverflow.ellipsis,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellow,
                    ),
                  )),

              // sjekk om varen er ER_MATVARE fyrst, hvis ikkje sjul "checkbox"

              Expanded(
                flex: 3,
                child: vare[ER_MATVARE] ? getCheckBox(vare) : Container(),
              ),
              Expanded(flex: 4, child: getLoesVektTextField(vare)),
            ],
          ),
          subtitle: Row(
            children: <Widget>[
              Expanded(child: Text(vare[STREKKODE])),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            if (toggleTile == index)
              setState(() {
                toggleTile = null;
              });
            else
              setState(() {
                toggleTile = index;
              });
          },
        ),
      ]);
    }

    Widget getListTile(Map<String, dynamic> vare, int index) {
      bool isQtyMoreThanOne = vare[MENGDE] > 1;
      return Column(children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: IconButton(
            iconSize: 40.0,
            icon: Icon(Icons.remove_circle),
            color: Theme.of(context).accentColor,
            onPressed: isQtyMoreThanOne
                ? () {
                    widget.onRemoveOneFromVarerList(vare);
                  }
                : null,
          ),
          trailing: IconButton(
            iconSize: 40.0,
            icon: Icon(Icons.add_circle),
            color: Theme.of(context).accentColor,
            onPressed: () {
              widget.onAddToVarerState(vare);
            },
          ),
          title: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  vare[NAVN],
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Text(
                    " X ${vare[MENGDE].toString()}",
                    style: TextStyle(fontSize: 16.0),
                  )),
              Expanded(
                flex: 1,
                child: vare[ER_MATVARE] ? getCheckBox(vare) : Container(),
              )
            ],
          ),
          subtitle: Row(
            children: <Widget>[
              Expanded(child: Text(vare[STREKKODE])),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            if (toggleTile == index)
              setState(() {
                toggleTile = null;
              });
            else
              setState(() {
                toggleTile = index;
              });
          },
        ),
        toggleTile == index
            ? Container(
                decoration: _boxDecorationBottomListTile,
                height: 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.delete),
                      iconSize: 24.0,
                      onPressed: () {
                        widget.onRemoveAllFromVarerList(vare);
                        setState(() {
                          toggleTile = null;
                        });
                      },
                    )
                  ],
                ),
              )
            : Container(),
      ]);
    }

    Widget getCard(Map<String, dynamic> vare, int index) => Container(
          child:
              vare[ER_LEOSVEKT] ? getListTileForLoesVekt(vare, index) : getListTile(vare, index),
          margin: const EdgeInsets.symmetric(
            vertical: 2.0,
          ),
          decoration: getBoxDecorationListTile(index % 2 == 0),
        );

    Widget getVareCardList() {
      // Selvom ListView leser en kopiert liste, vil den stemme med Widget.varer siden denne widget er renderet inni parent.Build(context)
      List<dynamic> varer = (widget.varerState.values).toList();
      return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (onScrollHandler != null) onScrollHandler();
            return true;
          },
          child: ListView.builder(
              itemCount: varer.length,
              itemBuilder: (_, int index) {
                Map<String, dynamic> vare = varer[index];
                return getCard(vare, index);
              }));
    }

    Widget _navnInputFeild = TextField(
      decoration: InputDecoration(
        labelText: 'Varenavn',
      ),
      controller: vareNvnCtrl,
      focusNode: vareNvnNode,
    );

    Widget _navn = StreamBuilder<QuerySnapshot>(
      stream: DataDB.getStreamProduktCollectionSnapshot(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return _navnInputFeild;
        else {
          Map<String, String> _data = Map<String, String>();
          snapshot.data.documents.forEach((doc) {
            if (doc != null && doc[NAVN] != null) {
              String prodNavn = doc[NAVN].toString();
              String produktID = doc.documentID;
              _data.putIfAbsent(produktID, () => prodNavn);
            }
          });

          return TypeAheadMixin(
            txtCtrl: vareNvnCtrl,
            fcsNode: vareNvnNode,
            setOnScroll: setOnScrollHandler,
            data: _data,
            child: _navnInputFeild,
            onElmHasBeenChoosen: (id) {
              if (widget.varerState.length < 50) {
                var prodSnapshot =
                    snapshot.data.documents.firstWhere((doc) => doc.documentID == id);
                if (prodSnapshot != null && prodSnapshot.data != null) {
                  //kan ikke være null
                  String strekkode = prodSnapshot.data[STREKKODE] != null
                      ? prodSnapshot.data[STREKKODE].toString()
                      : "";

                  String navn =
                      prodSnapshot.data[NAVN] != null ? prodSnapshot.data[NAVN].toString() : "";

// &&&&&&&&&&&&&&&&&&&&& skulle sende bare produktID, og hente varedata fra DB gjennom widget.onAddToVarerListe ?????

                  Map<String, dynamic> vare = {
                    // if matvare
                    MENGDE: prodSnapshot.data[ER_LEOSVEKT] == true ? 0.0 : 1,
                    NAVN: navn,
                    PRODUKT_ID: prodSnapshot.documentID,
                    PRIS: 0,
                    TOTALPRIS: 0,
                    STREKKODE: strekkode,
                    ER_MATVARE: prodSnapshot.data[ER_MATVARE],
                    BRGN_NAERING: prodSnapshot.data[ER_MATVARE],
                    ER_LEOSVEKT: prodSnapshot.data[ER_LEOSVEKT],
                  };

                  widget.onAddToVarerState(vare);
                }
              } else {
                FocusScope.of(context).unfocus();
                UtilUI.getCustomSnackBar(
                    scaffoldKey: _scaffoldKey,
                    text: "Det kan ikke legges til mer enn 50 unike varer!");
              }

              vareNvnCtrl.text = "";
            },
          );
        }
      },
    );

    Widget _readQrBtn = RaisedButton(
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text("Les strekkode", style: _textStyleBtnText),
        Icon(Icons.camera_alt),
      ]),
      onPressed: () {
        FocusScope.of(context).requestFocus(new FocusNode()); // To remoive the keyboard

        if (!isBottomSheetActive) getBottomSheet(context);
      },
    );

    // ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    // List.generate(
    //     5,
    //     (ind) => {
    //           MENGDE: 0,
    //           NAVN: "",
    //           PRODUKT_ID: ind.toString(),
    //           PRIS: 0,
    //           TOTALPRIS: 0,
    //           STREKKODE: ind.toString(),
    //           ER_MATVARE: true,
    //           BRGN_NAERING: true,
    //           ER_LEOSVEKT: true,
    //         }) //
    //   ..forEach((v) => widget.onAddToVarerState(v));
    // ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.black26),
      child: Scaffold(
        key: _scaffoldKey, //nødvendig for persistentBottomSheet
        appBar: AppBar(
            title: const Text('Legg til/rediger vareliste'),
            leading: IconButton(
              tooltip: 'Tilbake',
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (isBottomSheetActive) {
                  Navigator.pop(context);
                } else
                  widget.pageController.animateToPage(
                    0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
              },
            )),

        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _navn,
              Padding(
                padding: EdgeInsets.all(16.0),
              ),
              Expanded(child: getVareCardList()),
              isBottomSheetActive ? Container() : _readQrBtn,
            ],
          ),
        ),
      ),
    );
  }
}
