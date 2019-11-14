
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:handle_app/db/db.dart';
import 'package:handle_app/tree/handle/addHandel/pages/handleFormPage/subWidgets/varerPriceListWidget.dart';

import 'package:handle_app/tree/todo/utilWidget/MyTypeAheadTextFormField.dart';
import 'package:handle_app/tree/todo/utilWidget/myTextFormField%20_Draft.dart';
import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'package:handle_app/tree/todo/utilWidget/utilUI.dart';
import 'package:handle_app/config/attrconfig.dart';

class HandelFormComponentsWidget extends StatelessWidget {
  HandelFormComponentsWidget({
    Key key,
    this.handelState,
    this.varerState,
    this.txtCtrlMap,
    this.zIndexMap,
    this.focusNodeMap,
    this.invalidNodesMap,
    this.changeToNextFocusNodeHandler,
    this.validateInputHandler,
    this.addOrRemoveFromInvalidNodesHandler,
    this.attachToTextControllerMapHandler,
    this.removeFromTextControllerMapHandler,
    this.attachToFocusNodeMapHandler,
    this.removeFromFocusNodeMapHandler,
    this.onSubmit,
    this.setOnScrollHandelFormHandler,
  }) : super(key: key);

  final Map<String, dynamic> handelState;
  final Map<String, dynamic> varerState;

  final Map<dynamic, dynamic> txtCtrlMap;
  final Map<dynamic, dynamic> zIndexMap;
  final SplayTreeMap<double, dynamic> focusNodeMap;
  final SplayTreeMap<double, dynamic> invalidNodesMap;

  final dynamic changeToNextFocusNodeHandler;
  final dynamic validateInputHandler;
  final dynamic addOrRemoveFromInvalidNodesHandler;

  final dynamic attachToTextControllerMapHandler;
  final dynamic removeFromTextControllerMapHandler;
  final dynamic attachToFocusNodeMapHandler;
  final dynamic removeFromFocusNodeMapHandler;
  final dynamic onSubmit;

  dynamic setOnScrollHandelFormHandler;

  /// this is implemented at "TypeAheadTextFormFeild", and will run inside widget, onNotification: (scrollNotification)
  VoidCallback onScrollHandler;

  void setOnScrollHandler(function) {
    onScrollHandler = function;
    // To bubble up the notification, and allow it to continue to be dispatched to further ancestors(FormHandler)
    setOnScrollHandelFormHandler(function);
  }

  dynamic onSavedHandelStateHandler(String stateKey, {bool saveAsNum = false}) => (String value) {
        // Value blir lagret i State,
        // itilfelle (feltet er num + ikkeValid), vil "value" blir = null i State men ikke i TextFormField/txtCtrl
        var statevalue = saveAsNum
            ? Util.parseStringtoNum(value)
            : value; // Denne for å prøve å sette et tall som verdien på state for de feltene merkert isNum

        handelState[stateKey] = statevalue;
      };

  Widget _butikk() => MyTypeAheadTextFormField(
        attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[BUTIKK], node),
        // removeFromFocusNodeMap: ,
        dataStream: DataDB.getStreamHandleCollectionSnapshot(),
        // onElmHasBeenChoosen: ,
        setOnScrollHandler: setOnScrollHandler,

        extractDataFromSnapshot: (snapshot) {
          Map<String, String> _data = Map<String, String>();
          snapshot.data.documents.forEach((doc) {
            if (doc != null && doc[BUTIKK] != null) {
              String butikk = doc[BUTIKK].toString();
              _data.putIfAbsent(butikk.toLowerCase(), () => butikk);
            }
          });
          return _data;
        },
        attachToTextControllerMap: attachToTextControllerMapHandler,
        removeFromTextControllerMap: removeFromTextControllerMapHandler,
        addListnersToTextController: [
          () {
            String value = txtCtrlMap[BUTIKK].text;
            onSavedHandelStateHandler(BUTIKK)(value);
          }
        ],

        childAttirbutes: {
          "label": "Butikk",
          "value": handelState[BUTIKK]?.toString() ?? "",
          "fieldKey": BUTIKK,
          "validateInput": (value) => validateInputHandler(value, required: true),
          "changeToNextFocusNode": () => changeToNextFocusNodeHandler(zIndexMap[BUTIKK]),
          "onSaved": null,
          "addOrRemoveFromInvalidNodes": (valid, focusNode) =>
              addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[BUTIKK]),
          "keyboardType": TextInputType.text,
        },
      );

  @override
  Widget build(BuildContext context) {
    void selectDateListner([FocusNode node]) {
      double zIndex = zIndexMap[DATO];
      FocusNode focusNode = node ?? focusNodeMap[zIndex];

      if ((focusNode?.hasFocus) ?? false) {
        FocusScope.of(context).unfocus();
      }
      UtilUI.selectDate(
          context: context,
          onPicked: (picked) => txtCtrlMap[DATO].text = picked.toString().substring(0, 10));
    }

    Widget _dato() {
      Widget dt = Row(children: <Widget>[
        Expanded(
          flex: 3,
          child: MyTextFormField_draft(
            label: "Dato",
            fieldKey: DATO,
            onTap: selectDateListner,
            // instead of onChange, this uses txtController.listner(onSavedHandelStateHandler..)
            // onChanged: (value) =>
            //     onSavedHandelStateHandler(DATO)(value),
            value: handelState[DATO]?.toString() ?? "",
            validateInput: (value) => validateInputHandler(value, required: true, isDate: true),
            changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[DATO]),

            addOrRemoveFromInvalidNodes: (valid, focusNode) =>
                addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[DATO]),
            attachToTextControllerMap: attachToTextControllerMapHandler,
            removeFromTextControllerMap: removeFromTextControllerMapHandler,
            attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[DATO], node),
            removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[DATO]),
            addListnersToFocusNode: [
              (node) {
                if ((node?.hasFocus) ?? false) FocusScope.of(context).unfocus();
              }
            ],
            addListnersToTextController: [
              () {
                String value = txtCtrlMap[DATO].text;
                onSavedHandelStateHandler(DATO)(value);
              }
            ],
          ),
        ),
      ]);

      return dt;
    }

    Widget _summen() => MyTextFormField_draft(
          label: "Summen",
          fieldKey: SUMMEN,
          // enabled: false,

          value: handelState[SUMMEN]?.toString() ?? "",

          validateInput: (value) =>
              validateInputHandler(value, required: true, isNum: true, hasToBePos: true),
          // changeToNextFocusNode: null,

          // addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          //     addOrRemoveFromInvalidNodesHandler(
          //         valid, focusNode, zIndexMap[DATO]),
          attachToTextControllerMap: attachToTextControllerMapHandler,
          removeFromTextControllerMap: removeFromTextControllerMapHandler,
          addListnersToFocusNode: [
            (node) {
              if ((node?.hasFocus) ?? false) FocusScope.of(context).unfocus();
            }
          ],
          addListnersToTextController: [
            () {
              String value = txtCtrlMap[SUMMEN].text;
              onSavedHandelStateHandler(SUMMEN, saveAsNum: true)(value);
            }
          ],
        );
    Widget _betaltMed() => Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: MyTextFormField_draft(
                  label: "betalt med bankkort",
                  fieldKey: BANKKORT,
                  onChanged: (value) =>
                      onSavedHandelStateHandler(BANKKORT, saveAsNum: true)(value),
                  value: handelState[BANKKORT]?.toString() ?? "",
                  validateInput: (value) {
                    String errMsg = validateInputHandler(value, required: true, isNum: true);
                    if (errMsg == null) {
                      if (handelState[SUMMEN] != handelState[BANKKORT] + handelState[KONTANT])
                        // txtCtrlMap[SUMMEN].text = txtCtrlMap[BANKKORT].text + txtCtrlMap[KONTANT].text;
                        errMsg = "verdien er inkonsistent\n med summenfeltet!";
                    }
                    return errMsg;
                  },
                  changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[BANKKORT]),
                  addOrRemoveFromInvalidNodes: (valid, focusNode) =>
                      addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[BANKKORT]),
                  keyboardType: TextInputType.number,
                  attachToTextControllerMap: attachToTextControllerMapHandler,
                  removeFromTextControllerMap: removeFromTextControllerMapHandler,
                  attachToFocusNodeMap: (node) =>
                      attachToFocusNodeMapHandler(zIndexMap[BANKKORT], node),
                  removeFromFocusNodeMap: () =>
                      removeFromFocusNodeMapHandler(zIndexMap[BANKKORT]),
                  addListnersToFocusNode: [
                    (FocusNode node) {
                      if (node.hasFocus)
                        txtCtrlMap[BANKKORT].selection = TextSelection(
                            baseOffset: 0, extentOffset: txtCtrlMap[BANKKORT].text.length);
                    }
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: MyTextFormField_draft(
                  label: "betalt kontant",
                  fieldKey: KONTANT,
                  onChanged: (value) =>
                      onSavedHandelStateHandler(KONTANT, saveAsNum: true)(value),
                  value: handelState[KONTANT]?.toString() ?? "",
                  validateInput: (value) {
                    String errMsg = validateInputHandler(value, required: true, isNum: true);
                    if (errMsg == null) {
                      num bankkort =
                          handelState[BANKKORT] is num ? handelState[BANKKORT] : null;
                      num kontant = handelState[KONTANT] is num ? handelState[KONTANT] : null;
                      num summen = handelState[SUMMEN] is num ? handelState[SUMMEN] : null;
                      if ((bankkort != null && kontant != null && summen != null) &&
                          (summen != bankkort + kontant))
                        // txtCtrlMap[SUMMEN].text = txtCtrlMap[BANKKORT].text + txtCtrlMap[KONTANT].text;
                        errMsg = "verdien er inkonsistent\n med summenfeltet!";
                    }
                    return errMsg;
                  },
                  changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[KONTANT]),
                  addOrRemoveFromInvalidNodes: (valid, focusNode) =>
                      addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[KONTANT]),
                  keyboardType: TextInputType.number,
                  attachToTextControllerMap: attachToTextControllerMapHandler,
                  removeFromTextControllerMap: removeFromTextControllerMapHandler,
                  attachToFocusNodeMap: (node) =>
                      attachToFocusNodeMapHandler(zIndexMap[KONTANT], node),
                  removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[KONTANT]),
                  addListnersToFocusNode: [
                    (FocusNode node) {
                      if (node.hasFocus)
                        txtCtrlMap[KONTANT].selection = TextSelection(
                            baseOffset: 0, extentOffset: txtCtrlMap[KONTANT].text.length);
                    }
                  ],
                ),
              )
            ],
          ),
        );

    Widget _cancelBtn;

    Widget _submitBtn() => Container(
          margin: EdgeInsets.all(16.0),
          child: RaisedButton(
            child: Text("Legg til", style: TextStyle(fontSize: 20.0)),
            onPressed: onSubmit,
          ),
        );

    Widget _varerPriceListViewWidget = NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (onScrollHandler != null) onScrollHandler();
          print((scrollNotification is OverscrollNotification));

          return (scrollNotification is OverscrollNotification);
        },
        child: ListView(
          children: [
            VarerPriceListWidget(
              txtCtrlMap: txtCtrlMap,
              focusNodeMap: focusNodeMap,
              varerState: varerState,
              minZIndex: zIndexMap[VARER],
              maxZIndex: zIndexMap[SUMMEN],
              changeToNextFocusNode: changeToNextFocusNodeHandler,
              addOrRemoveFromInvalidNodesHandler: addOrRemoveFromInvalidNodesHandler,
              validateInputHandler: validateInputHandler,
              attachToTextControllerMapHandler: attachToTextControllerMapHandler,
              removeFromTextControllerMapHandler: removeFromTextControllerMapHandler,
              attachToFocusNodeMapHandler: attachToFocusNodeMapHandler,
              removeFromFocusNodeMapHandler: removeFromFocusNodeMapHandler,
            )
          ],
        ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _dato(),
        _butikk(),
        Container(
          height: ((MediaQuery.of(context).size.height) -
                  (MediaQuery.of(context).padding.top) -
                  kToolbarHeight) /
              2.5,
          color: Colors.blueGrey,
          margin: EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0),
          child: _varerPriceListViewWidget,
        ),
        _summen(),
        _betaltMed(),
        _submitBtn(),
      ],
    );
  }
}

