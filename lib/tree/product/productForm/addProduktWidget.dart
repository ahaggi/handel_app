import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handle_app/tree/product/produktList/subWidgets/produktCardWidget.dart';
import 'package:handle_app/tree/todo/utilWidget/loadingIndicator.dart';
import 'dart:async';
import 'dart:collection';

import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'package:handle_app/tree/todo/utilWidget/utilDigiEyes.dart';

import 'package:handle_app/tree/product/productForm/subWidget/ProduktFormComponentsWidget.dart';
import 'package:handle_app/tree/todo/utilWidget/barCodeReaderWidget.dart';
import 'package:handle_app/tree/todo/utilWidget/utilUI.dart';
import 'package:handle_app/tree/todo/utilWidget/genericFormWidget.dart';

import 'package:handle_app/db/db.dart';
import 'package:handle_app/config/attrconfig.dart';

class AddNewProduktWidget extends StatefulWidget {
  AddNewProduktWidget({Key key, this.strekkode, this.docSnapshotToEdit}) : super(key: key);

  //brukstilfelle1: kun hvis "this" blir init fra homePage dvs (strekkode + produktToEditID + produktToEdit = null)

  //brukstilfelle2: kun hvis "this" blir init fra HandelFormWidget
  final String strekkode;

  //brukstilfelle3: kun hvis "this" blir init fra ProduktCardWidget onEdit
  final DocumentSnapshot docSnapshotToEdit;

  @override
  _AddNewProduktWidgetState createState() => _AddNewProduktWidgetState();
}

class _AddNewProduktWidgetState extends State<AddNewProduktWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<dynamic, dynamic> txtCtrlMap;
  Map<dynamic, dynamic> zIndexMap = {};

  SplayTreeMap<double, dynamic> focusNodeMap =
      SplayTreeMap<double, dynamic>.from({}, (a, b) => a.compareTo(b));

  SplayTreeMap<double, dynamic> invalidNodesMap =
      SplayTreeMap<double, dynamic>.from({}, (a, b) => a.compareTo(b));

  Map<String, dynamic> produktState;
  Map<String, dynamic> naeringsinnholdState;
  Map<String, dynamic> beskrivelseState;

  bool isLoadingIndicatorshown = false;
  bool isSearchProduktInfoBtnActive = false;

  VoidCallback onScrollHandler;
  void setOnScrollHandler(function) {
    onScrollHandler = function;
  }

  @override
  void initState() {
    naeringsinnholdState = {
      NAERINGSINNHOLD: Map<String, dynamic>()
        ..addAll({
          ENERGI: "",
          KALORIER: "",
          FETT: "",
          ENUMETTET: "",
          FLERUMETTET: "",
          METTET_FETT: "",
          KARBOHYDRATER: "",
          SUKKERARTER: "",
          STIVELSE: "",
          KOSTFIBER: "",
          PROTEIN: "",
          SALT: ""
        })
    };

    beskrivelseState = {
      "beskrivelse": "mockInfo",
    };

    produktState = {
      NAVN: "",
      STREKKODE: "",
      NETTOVEKT: "",
      KOMMENTAR: "",
      INFO: {},
      ER_LEOSVEKT: false,
      ER_MATVARE: true
    };

    txtCtrlMap = {};
    zIndexMap = UtilUI.initZIndexMap(produktState, 0);
    zIndexMap
        .addAll(UtilUI.initZIndexMap(naeringsinnholdState[NAERINGSINNHOLD], zIndexMap.length));
    setInitValues();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      txtCtrlMap[STREKKODE].addListener(setSearchProduktInfoBtnActive);
    });
    super.initState();
  }

  void setInitValues() {
    //for brukstilfelle1 + brukstilfellet2 + brukestilfellet3
    produktState[INFO] = produktState[ER_MATVARE] ? naeringsinnholdState : beskrivelseState;

    //for brukstilfelle2
    if (widget.strekkode != null && Util.isBarcodeValid(widget.strekkode)){
      
      produktState[STREKKODE] = Util.parseStringtoNum(widget.strekkode);
      }

    //for brukstilfelle3
    else if (widget.docSnapshotToEdit != null) {
      //for brukstilfelle1 + brukstilfellet2 + brukestilfellet3
      produktState[INFO] =
          widget.docSnapshotToEdit.data[ER_MATVARE] ? naeringsinnholdState : beskrivelseState;
      populateFormData(widget.docSnapshotToEdit.data);
    }
  }

  void setSearchProduktInfoBtnActive() {
    var code = txtCtrlMap[STREKKODE].text;
    isSearchProduktInfoBtnActive = Util.isBarcodeValid(code);
    setState(() {});
  }

  @override
  void dispose() {
    // FocusScope.of(context)
    //     .requestFocus(new FocusNode()); // To remoive the keyboard
    WidgetsBinding.instance.focusManager.rootScope.requestFocus(new FocusNode());
    // Clean up the controller when the Widget is disposed

    super.dispose();
  }

  void attachToTextControllerMapHandler(stateKey, txtCtrl) {
    txtCtrlMap[stateKey] = txtCtrl;
  }

  void removeFromTextControllerMapHandler(stateKey) {
    txtCtrlMap.remove(stateKey);
  }

  void attachToFocusNodeMapHandler(key, focusNode) {
    focusNodeMap[key] = focusNode;
  }

  void removeFromFocusNodeMapHandler(key) {
    focusNodeMap.remove(key);
  }

  void setFocusOnFirstInvalidNode() =>
      UtilUI.setFocusOnFirstInvalidNode(context: context, invalidNodesMap: invalidNodesMap);

  void addOrRemoveFromInvalidNodesHandler(valid, currentNode, zIndex) =>
      UtilUI.addOrRemoveFromInvalidNodesMapHandler(
          invalidNodesMap: invalidNodesMap, valid: valid, currentNode: currentNode, zIndex: zIndex);

  void changeToNextFocusNodeHandler(double zIndex) {
    double nxtKey = focusNodeMap.firstKeyAfter(zIndex);

    if (nxtKey != null) {
      FocusNode currentNode = focusNodeMap[zIndex];
      FocusNode nextFocusNode = focusNodeMap[nxtKey];
      if (!(currentNode == null || nextFocusNode == null)) {
        currentNode.unfocus();
        FocusScope.of(context).requestFocus(nextFocusNode);
      }
    } else
      FocusScope.of(context).unfocus(); // lose focus
  }

/* *****************************persistent bottom sheet******************************* */
/* *********************************************************************************** */
  //Show a bottomSheet to scan a barcode AND shows Dialog with the suggested "produkt"
  void getBottomSheet() {
    dynamic onSeccessfulReadHandler = (code) {
      // Navigator.popUntil(context, ModalRoute.withName('/AddNewProduktWidget')); vil ikke fungrere når this blir init fra produktlisteWidget med res = await navigator.push
      Navigator.pop(context);

      bool validRead = Util.isBarcodeValid(code);
      if (validRead)
        txtCtrlMap[STREKKODE].text = code;
      else {
        print("Err onSeccessfulReadHandler(code) show snackBar");
        UtilUI.getCustomSnackBar(scaffoldKey: _scaffoldKey, text: "Couldn't read the barcode!");
      }
    };

    FocusScope.of(context).requestFocus(new FocusNode()); // To remoive the keyboard

    Widget _childWidget = BarCodeReaderWidget(onSeccessfulReadCallback: onSeccessfulReadHandler);

    UtilUI.showBottomSheet(
        context: context,
        scaffoldKey: _scaffoldKey,
        childWidget: _childWidget,
        onWhenComplete: null);
  }

  ///********************************showDialog****************************************** */
  ///************************************************************************************ */

  // shows Dialog with the suggested "produkt", AND call onSeccessHandler
  void _showMyDialog(Map<String, dynamic> p) async {
    String _dialogMsg = 'Er dette rett produkt? \n ${p[NAVN]}';
    dynamic _onYesCallback = () {
      // if you gonna use this function, we've to update all the txtCtrlMap value by adding listner
      // to modify the txtCtrls' value to be as the scanned "Produkt"
      // except for produktState[ER_MATVARE] and [ER_LEOSVEKT], witch doesn't have a controller
      // Also notice the flwg
      // // the next line is a workaroud for the flwg:
      // // 1- edit a product that is a "Loesvekt"
      // // 2- without changing a thing hit "save"
      // // the produktState[NETTOVEKT] will stay the same init-value  "" ,
      // // because the NETTOVEKT-textInput is not mounted that means onSavedHandler will not run
      // // and we will lose the prev value of snaphshot.data[NETTOVEKT]
      // if (k== ER_LEOSVEKT && p[ER_LEOSVEKT]) produktState[NETTOVEKT] = p[NETTOVEKT];

      // populateFormData(p);

      //   setState(() {});
    };

    Widget preview = ProduktCardWidget(
      produkt: p,
      onDelete: null,
      onEdit: null,
      getImageFromFirebaseStorageCallback: null,
    );
    UtilUI.showMyDialog(
        context: context,
        dialogMsg: _dialogMsg,
        dialogBody: preview,
        onYesCallback: _onYesCallback);
  }

  void populateFormData(dynamic p) {
    p.forEach((k, v) {
      if (k != TIMESTAMP) {
        if (v is Map) {
          // k = info , v = map
          v.forEach((k2, v2) {
            // k2 = naeringsinnhold , v2 = næringsinnhold eller beskrivelse map
            if (v2 is Map && k2 == NAERINGSINNHOLD)
              v2.forEach((k3, v3) => // k = Energi, Kalorier..., v = num
                      naeringsinnholdState[NAERINGSINNHOLD][k3] =
                          (v3 != null) //(p[k] != null && p[k][k2] != null && p[k][k2][k3] != null)
                              ? p[k][k2][k3]
                              : "" //
                  );
          });
        } else if (produktState[k] is bool) {
          // (k == ER_MATVARE || k ==ER_LEOSVEKT)
          produktState[k] = (p[k] ?? true);
        } else
          produktState[k] = (p[k]);
      }
    });

    //  ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    //  _formAutovalidate = true; // For å validere alle data
    // setFocusOnFirstInvalidNode();
  }

  void setShowLoadingIndicatorAs(bool b) {
    setState(() {
      isLoadingIndicatorshown = b;
    });
  }

  void processBarcode(code) async {
    bool validcode = Util.isBarcodeValid(code);

    if (validcode) {
      /************************************************************************************************************************************************************************ */
      //OBS Hvis du sette LoadingIndicator på kun the txtInputstrekkode, da vil brukere ha resten av form tilgjengelig. Noe som ikke er målet.
      //På den andre siden setter du hele "form" i futureBuilder, vil "alle" widget "re-render" på nytt.

      setShowLoadingIndicatorAs(true);
      var allreadyRegistered = false;
      if (!allreadyRegistered) {
        Map<String, dynamic> p = await UtilDigiEyes.processBarCode(code);

        /************************************************************************************************************************************************************************ */
        if (isLoadingIndicatorshown) {
          setShowLoadingIndicatorAs(false);
          // if ((p[navn] != null && p[navn].isNotEmpty) ||
          //     (p[INFO] != null && p[INFO].isNotEmpty))
          _showMyDialog(p);
          // else {
          //   UtilUI.getCustomSnackBar(
          //       scaffoldKey: _scaffoldKey,
          //       text: "Produktinfo kan ikke finnes!");
          // }
        }
      } else {
        setShowLoadingIndicatorAs(
            false); //burde sjekke om brukeren har avbrutt før vi viser the snackbar
        UtilUI.getCustomSnackBar(
            scaffoldKey: _scaffoldKey, text: "Produktet er allerede registerert!");
      }
    } else {
      print("Err processBarcode(code) show snackBar");
      UtilUI.getCustomSnackBar(scaffoldKey: _scaffoldKey, text: "Strekkoden er ikke gyldig!");
    }
  }

  void generateFakeBarcode() async {
    int _fakeBarcode = await Util.generateFakeBarcode();
    txtCtrlMap[STREKKODE].text = _fakeBarcode.toString();
  }

  void _submitToDbHandler() async {
    print("valid, $produktState");
    var id = "";
    String melding = "";
    if (widget.docSnapshotToEdit == null) {
      bool isRegistered =
          await DataDB.isStrekkodeRegistred(strekkode: txtCtrlMap[STREKKODE].text);
      if (isRegistered) {
        UtilUI.getCustomSnackBar(
            scaffoldKey: _scaffoldKey, text: "Felimelding: strekkode e allerede registerert!");
        return;
      } else {
        id = await DataDB.addNewProduktDoc(data: produktState);
        melding = "Produktet $id blir lagret til DB";
      }
    } else {
      id = await DataDB.updateProduktDoc(docSnapshot: widget.docSnapshotToEdit, data: produktState);
      melding = "Produktet $id blir endret";
    }
    UtilUI.getCustomSnackBar(scaffoldKey: _scaffoldKey, text: melding);

    Map<String, dynamic> data = {PRODUKT_ID: id, NAVN: produktState[NAVN]};
    Future.delayed(const Duration(seconds: 3), () => Navigator.pop(context, data));
  }

  void onChangeMatvareHandler(value) {
    setState(() {
      produktState[ER_MATVARE] = value;
      if (value)
        produktState[INFO] = naeringsinnholdState;
      else
        produktState[INFO] = beskrivelseState;
    });
  }

  void onChangeLoesvektHandler(value) {
    if (value)

      /// Notice that the value is saved directrly into the state not into the TxtController,
      /// because NETTOVEKT-textInput is not visible if "erLeosvekt" is true.
      produktState[NETTOVEKT] = "1";
    else

      /// But hear the NETTOVEKT-textInput is visible and mounted,
      /// which means the function "onSavedHandler" will register the value in TxtController into productState
      produktState[NETTOVEKT] = "";

    setState(() {
      produktState[ER_LEOSVEKT] = value;
    });
  }

  ///************************************************************************************ */
  // void _submitHandler() {
  //   if (viktig forutsetning)
  //     UtilUI.getCustomSnackBar(scaffoldKey: _scaffoldKey, text: "sdf!");
  //   this.submitHandler();
  // }

  // implemented in GenericForm to be used in FormComponentsWidget
  dynamic validateInputHandler;
  void setValidateInputAs(func) => validateInputHandler = func;

  dynamic submitHandler;
  void setSubmitAs(func) {
    submitHandler = func;
  }

  ///************************************************************************************ */

  @override
  Widget build(BuildContext context) {
    Widget _formComponents = ProduktFormComponentsWidget(
      produktState: produktState,
      naeringsinnholdState: naeringsinnholdState,
      txtCtrlMap: txtCtrlMap,
      focusNodeMap: focusNodeMap,
      onChangeMatvare: onChangeMatvareHandler,
      onChangeLoesvekt: onChangeLoesvektHandler,
      onPressedReadQRbtn: getBottomSheet,
      onPressedSearchProduketInfoBtn: processBarcode,
      onPressedgenerateFakeBarcode: generateFakeBarcode,
      addOrRemoveFromInvalidNodesHandler: addOrRemoveFromInvalidNodesHandler,
      onSubmit: submitHandler,
      submitBtnLabel: widget.docSnapshotToEdit == null ? "lagre produktet" : "Rediger",
      isSearchProduktInfoBtnActive: isSearchProduktInfoBtnActive,
      attachToFocusNodeMapHandler: attachToFocusNodeMapHandler,
      attachToTextControllerMapHandler: attachToTextControllerMapHandler,
      removeFromFocusNodeMapHandler: removeFromFocusNodeMapHandler,
      removeFromTextControllerMapHandler: removeFromTextControllerMapHandler,
      changeToNextFocusNodeHandler: changeToNextFocusNodeHandler,
      invalidNodesMap: invalidNodesMap,
      validateInputHandler: validateInputHandler,
      zIndexMap: zIndexMap,
    );

    Widget _form = GenericFormWidget(
      child: _formComponents,
      setSubmitAs: setSubmitAs,
      setValidateInputAs: setValidateInputAs,
      onSubmitToDB: _submitToDbHandler,
      onSetFocusOnFirstInvalidNode: setFocusOnFirstInvalidNode,
      scaffoldKey: _scaffoldKey,
    );

    Widget _loadingIndicatorWidget = LoadingIndicatorWidget(
      onCancelCallback: () {
        setShowLoadingIndicatorAs(false);
        UtilUI.getCustomSnackBar(scaffoldKey: _scaffoldKey, text: "Forespørselen blir avbrutt!");
      },
      waitingDur: 5,
    );

    Widget pageBody() {
      return Stack(
        children: <Widget>[
          _form,
          isLoadingIndicatorshown ? _loadingIndicatorWidget : Container(),
        ],
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.black26),
      child: Scaffold(
          key: _scaffoldKey, //nødvendig for persistentBottomSheet
          appBar: AppBar(
            title: const Text('Legg til et nytt produkt'),
            leading: IconButton(
              tooltip: 'Previous choice',
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(produktState);
              },
            ),
          ),
          body: pageBody()),
    );
  }
}
