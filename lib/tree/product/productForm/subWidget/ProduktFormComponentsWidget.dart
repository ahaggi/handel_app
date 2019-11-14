import 'package:flutter/material.dart';
import 'dart:collection';

import 'package:handle_app/tree/todo/utilWidget/myCallback.dart';
import 'package:handle_app/tree/todo/utilWidget/myTextFormField%20_Draft.dart';
import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'package:handle_app/config/attrconfig.dart';

class ProduktFormComponentsWidget extends StatelessWidget {
  ProduktFormComponentsWidget({
    Key key,
    this.produktState,
    this.naeringsinnholdState,
    this.txtCtrlMap,
    this.zIndexMap,
    this.focusNodeMap,
    this.invalidNodesMap,
    this.onChangeMatvare,
    this.onChangeLoesvekt,
    this.onPressedReadQRbtn,
    this.onPressedSearchProduketInfoBtn,
    this.onPressedgenerateFakeBarcode,
    this.changeToNextFocusNodeHandler,
    this.validateInputHandler,
    this.addOrRemoveFromInvalidNodesHandler,
    this.attachToTextControllerMapHandler,
    this.removeFromTextControllerMapHandler,
    this.attachToFocusNodeMapHandler,
    this.removeFromFocusNodeMapHandler,
    this.onSubmit,
    this.submitBtnLabel,
    this.isSearchProduktInfoBtnActive,
  }) : super(key: key);

  final Map<String, dynamic> produktState;
  final Map<String, dynamic> naeringsinnholdState;

  final Map<dynamic, dynamic> txtCtrlMap;
  final Map<dynamic, dynamic> zIndexMap;
  final SplayTreeMap<double, dynamic> focusNodeMap;
  final SplayTreeMap<double, dynamic> invalidNodesMap;

  final MCDynamicVoid onChangeMatvare;
  final MCDynamicVoid onChangeLoesvekt;
  final VoidCallback onPressedReadQRbtn;
  final MCDynamicVoid onPressedSearchProduketInfoBtn;
  final VoidCallback onPressedgenerateFakeBarcode;

  final dynamic changeToNextFocusNodeHandler;
  final dynamic validateInputHandler;
  final dynamic addOrRemoveFromInvalidNodesHandler;

  final dynamic attachToTextControllerMapHandler;
  final dynamic removeFromTextControllerMapHandler;
  final dynamic attachToFocusNodeMapHandler;
  final dynamic removeFromFocusNodeMapHandler;
  final dynamic onSubmit;

  final String submitBtnLabel;

  final bool isSearchProduktInfoBtnActive;

  dynamic onSavedProduktStateHandler(String stateKey,
          {bool saveAsNum = false, bool isInfo = false}) =>
      (value) {
        var statevalue;
        if (saveAsNum) {
          num parsed = Util.parseStringtoNum(value);
          statevalue = parsed == null ? 0 : parsed;
        } else
          statevalue = value;

        if (isInfo)
          produktState[INFO][NAERINGSINNHOLD][stateKey] = statevalue;
        else
          produktState[stateKey] = statevalue;
      };

  ///************************************************************************************ */
  ///************************************************************************************ */

  Widget getSwitchListTile({String label, String stateKey, dynamic onChanged}) => SwitchListTile(
        title: Text(label),
        value: produktState[stateKey],
        onChanged: (bool value) {
          onChanged(value);
        },
        secondary: Icon(Icons.lightbulb_outline),
      );

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleBtnText = TextStyle(fontSize: 20.0);

    Widget _navn = MyTextFormField_draft(
      label: "Navn",
      fieldKey: NAVN,
      onChanged: onSavedProduktStateHandler(NAVN),
      value: produktState[NAVN]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true,
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[NAVN]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[NAVN]),
      keyboardType: TextInputType.text,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[NAVN], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[NAVN]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[NAVN].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[NAVN].text.length);
        }
      ],
    );

    Widget _strekkode = MyTextFormField_draft(
      label: "Strekkode",
      fieldKey: STREKKODE,
      onChanged: onSavedProduktStateHandler(STREKKODE , saveAsNum: true),
      value: produktState[STREKKODE]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[STREKKODE]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[STREKKODE]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[STREKKODE], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[STREKKODE]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[STREKKODE].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[STREKKODE].text.length);
        }
      ],
      addListnersToTextController: [
        () {
                      onSavedProduktStateHandler(STREKKODE, saveAsNum: true)(txtCtrlMap[STREKKODE].text);
        }
      ],
    );

    Widget _kommentar = MyTextFormField_draft(
      label: "Kommentar",
      fieldKey: KOMMENTAR,
      onChanged: onSavedProduktStateHandler(KOMMENTAR),
      value: produktState[KOMMENTAR]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(value),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[KOMMENTAR]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[KOMMENTAR]),
      keyboardType: TextInputType.text,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[KOMMENTAR], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[KOMMENTAR]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[KOMMENTAR].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[KOMMENTAR].text.length);
        }
      ],
    );

    Widget _nettovekt = MyTextFormField_draft(
      label: "Nettovekt",
      fieldKey: NETTOVEKT,
      onChanged: onSavedProduktStateHandler(NETTOVEKT, saveAsNum: (produktState[ER_MATVARE] ?? false)),
      value: produktState[NETTOVEKT]?.toString() ?? "",
      validateInput: (value) =>
          validateInputHandler(value, required: true, isNum: (produktState[ER_MATVARE] ?? false)),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[NETTOVEKT]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[NETTOVEKT]),
      keyboardType: TextInputType.text,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[NETTOVEKT], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[NETTOVEKT]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[NETTOVEKT].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[NETTOVEKT].text.length);
        }
      ],
    );

    Widget _energi = MyTextFormField_draft(
      label: ENERGI,
      fieldKey: ENERGI,
      onChanged: onSavedProduktStateHandler(ENERGI, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][ENERGI]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[ENERGI]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[ENERGI]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[ENERGI], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[ENERGI]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[ENERGI].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[ENERGI].text.length);
        }
      ],
    );

    Widget _kalorier = MyTextFormField_draft(
      label: KALORIER,
      fieldKey: KALORIER,
      onChanged: onSavedProduktStateHandler(KALORIER, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][KALORIER]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[KALORIER]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[KALORIER]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[KALORIER], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[KALORIER]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[KALORIER].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[KALORIER].text.length);
        }
      ],
    );

    Widget _fett = MyTextFormField_draft(
      label: FETT,
      fieldKey: FETT,
      onChanged: onSavedProduktStateHandler(FETT, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][FETT]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[FETT]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[FETT]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[FETT], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[FETT]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[FETT].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[FETT].text.length);
        }
      ],
    );

    Widget _enumettetFett = MyTextFormField_draft(
      label: ENUMETTET,
      fieldKey: ENUMETTET,
      onChanged: onSavedProduktStateHandler(ENUMETTET, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][ENUMETTET]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[ENUMETTET]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[ENUMETTET]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[ENUMETTET], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[ENUMETTET]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[ENUMETTET].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[ENUMETTET].text.length);
        }
      ],
    );

    Widget _flerumettetFett = MyTextFormField_draft(
      label: FLERUMETTET,
      fieldKey: FLERUMETTET,
      onChanged: onSavedProduktStateHandler(FLERUMETTET, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][FLERUMETTET]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[FLERUMETTET]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[FLERUMETTET]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[FLERUMETTET], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[FLERUMETTET]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[FLERUMETTET].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[FLERUMETTET].text.length);
        }
      ],
    );

    Widget _mettetFett = MyTextFormField_draft(
      label: METTET_FETT,
      fieldKey: METTET_FETT,
      onChanged: onSavedProduktStateHandler(METTET_FETT, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][METTET_FETT]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[METTET_FETT]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[METTET_FETT]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[METTET_FETT], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[METTET_FETT]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[METTET_FETT].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[METTET_FETT].text.length);
        }
      ],
    );

    Widget _karbohydrater = MyTextFormField_draft(
      label: KARBOHYDRATER,
      fieldKey: KARBOHYDRATER,
      onChanged: onSavedProduktStateHandler(KARBOHYDRATER, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][KARBOHYDRATER]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[KARBOHYDRATER]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[KARBOHYDRATER]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[KARBOHYDRATER], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[KARBOHYDRATER]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[KARBOHYDRATER].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[KARBOHYDRATER].text.length);
        }
      ],
    );

    Widget _sukkerarter = MyTextFormField_draft(
      label: SUKKERARTER,
      fieldKey: SUKKERARTER,
      onChanged: onSavedProduktStateHandler(SUKKERARTER, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][SUKKERARTER]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[SUKKERARTER]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[SUKKERARTER]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[SUKKERARTER], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[SUKKERARTER]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[SUKKERARTER].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[SUKKERARTER].text.length);
        }
      ],
    );

    Widget _stivelse = MyTextFormField_draft(
      label: STIVELSE,
      fieldKey: STIVELSE,
      onChanged: onSavedProduktStateHandler(STIVELSE, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][STIVELSE]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[STIVELSE]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[STIVELSE]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[STIVELSE], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[STIVELSE]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[STIVELSE].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[STIVELSE].text.length);
        }
      ],
    );

    Widget _kostfiber = MyTextFormField_draft(
      label: KOSTFIBER,
      fieldKey: KOSTFIBER,
      onChanged: onSavedProduktStateHandler(KOSTFIBER, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][KOSTFIBER]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[KOSTFIBER]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[KOSTFIBER]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[KOSTFIBER], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[KOSTFIBER]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[KOSTFIBER].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[KOSTFIBER].text.length);
        }
      ],
    );

    Widget _protein = MyTextFormField_draft(
      label: PROTEIN,
      fieldKey: PROTEIN,
      onChanged: onSavedProduktStateHandler(PROTEIN, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][PROTEIN]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[PROTEIN]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[PROTEIN]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[PROTEIN], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[PROTEIN]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[PROTEIN].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[PROTEIN].text.length);
        }
      ],
    );

    Widget _salt = MyTextFormField_draft(
      label: SALT,
      fieldKey: SALT,
      onChanged: onSavedProduktStateHandler(SALT, saveAsNum: true, isInfo: true),
      value: naeringsinnholdState[NAERINGSINNHOLD][SALT]?.toString() ?? "",
      validateInput: (value) => validateInputHandler(
        value,
        required: true, isNum: true,
//hasToBePos: true
      ),
      changeToNextFocusNode: () => changeToNextFocusNodeHandler(zIndexMap[SALT]),
      addOrRemoveFromInvalidNodes: (valid, focusNode) =>
          addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[SALT]),
      keyboardType: TextInputType.number,
      attachToTextControllerMap: attachToTextControllerMapHandler,
      removeFromTextControllerMap: removeFromTextControllerMapHandler,
      attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndexMap[SALT], node),
      removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndexMap[SALT]),
      addListnersToFocusNode: [
        (FocusNode node) {
          if (node.hasFocus)
            txtCtrlMap[SALT].selection =
                TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[SALT].text.length);
        }
      ],
    );

    Widget _isMatvare =
        getSwitchListTile(label: "Matvare", stateKey: ER_MATVARE, onChanged: onChangeMatvare);
    Widget _isLoesvekt =
        getSwitchListTile(label: "Loesvekt", stateKey: ER_LEOSVEKT, onChanged: onChangeLoesvekt);

    Widget _naeringsInnhold = Container(
      child: Column(
        children: <Widget>[
          _energi,
          _kalorier,
          _fett,
          _enumettetFett,
          _flerumettetFett,
          _mettetFett,
          _karbohydrater,
          _sukkerarter,
          _stivelse,
          _kostfiber,
          _protein,
          _salt,
        ],
      ),
    );

    Widget _beskrivelse = Container();

    Widget _cancelBtn; //TODO?

    Widget _readQrBtn = IconButton(
        tooltip: 'les QR kode',
        icon: const Icon(Icons.camera_alt),
        onPressed: () => //Future.delayed(const Duration(seconds: 3), () =>
            // getBottomSheet()
            onPressedReadQRbtn()
        //),

        );

    Widget _searchProduktInfoBtn = IconButton(
        tooltip: 'Søk prod info på nettet',
        icon: const Icon(Icons.search),
        onPressed: () {
          if (txtCtrlMap[STREKKODE].text.isNotEmpty)
            onPressedSearchProduketInfoBtn(
                    txtCtrlMap[STREKKODE].text) // processBarcode(txtCtrlMap[STREKKODE].text)
                ;
        });

    Widget _submitBtn = Container(
      margin: EdgeInsets.all(16.0),
      child: RaisedButton(
        child: Text(submitBtnLabel, style: _textStyleBtnText),
        onPressed: onSubmit,
      ),
    );

    Widget _formComponents = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _navn,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _strekkode),
            isSearchProduktInfoBtnActive ? _searchProduktInfoBtn : Container(),
            _readQrBtn
          ],
        ),
        Row(
          children: <Widget>[
            InkWell(
                child: new Text('Generer en falsk strekkode'),
                onTap: onPressedgenerateFakeBarcode //generateFakeBarcode
                )
          ],
        ),
        Padding(padding: const EdgeInsets.only(top: 16.0), child: _isLoesvekt),
        Row(
          children: <Widget>[
            Expanded(child: produktState[ER_LEOSVEKT] ? Container() : _nettovekt),
            Expanded(child: _kommentar),
          ],
        ),
        Padding(padding: const EdgeInsets.only(top: 16.0), child: _isMatvare),
        produktState[ER_MATVARE] ? _naeringsInnhold : _beskrivelse,
        _submitBtn,
      ],
    );

    return _formComponents;
  }
}
