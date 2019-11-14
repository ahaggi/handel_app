import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:handle_app/tree/product/productForm/addProduktWidget.dart';
import 'package:handle_app/tree/todo/utilWidget/myCallback.dart';
import 'package:handle_app/tree/todo/utilWidget/myTextFormField%20_Draft.dart';
import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'package:handle_app/config/attrconfig.dart';

class VarerPriceListWidget extends StatelessWidget {
  VarerPriceListWidget({
    this.txtCtrlMap,
    this.focusNodeMap,
    this.varerState,
    this.maxZIndex,
    this.minZIndex,
    this.changeToNextFocusNode,
    this.addOrRemoveFromInvalidNodesHandler,
    this.validateInputHandler,
    this.attachToFocusNodeMapHandler,
    this.removeFromFocusNodeMapHandler,
    this.attachToTextControllerMapHandler,
    this.removeFromTextControllerMapHandler,
  });
  final Map<dynamic, dynamic> txtCtrlMap;
  final SplayTreeMap<dynamic, dynamic> focusNodeMap;
  final Map<String, dynamic> varerState;
  final double maxZIndex;
  final double minZIndex;
  final dynamic changeToNextFocusNode;
  final dynamic addOrRemoveFromInvalidNodesHandler;
  final dynamic validateInputHandler;
  final MC2Dynamicvoid attachToTextControllerMapHandler;
  final MCDynamicVoid removeFromTextControllerMapHandler;
  final dynamic attachToFocusNodeMapHandler;
  final MCDynamicVoid removeFromFocusNodeMapHandler;

  @override
  Widget build(BuildContext context) {
    BoxDecoration getboxDecorationVareEntry(bool b) => BoxDecoration(
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

    void calcSummen() {
      num summen = 0;

      txtCtrlMap.forEach((k, txtCtrl) {
        if (k.contains(TOTALPRIS)) {
          num totp = Util.parseStringtoNum(txtCtrl.text);
          totp = totp == null ? 0 : totp;
          summen += totp;
        }
      });

      txtCtrlMap[SUMMEN].text = summen.toDouble().toStringAsFixed(2);
    }

    dynamic onSavedHandlerVareState(String prodID, String stateKey) => (String value) {
          num val = Util.parseStringtoNum(value);

          var statevalue = val != null
              ? val.toDouble()
              : val; // Denne for å prøve å sette et tall som verdien på state

          varerState[prodID][stateKey] = statevalue;
        };

    void calcDependentPrice(String prodID, String stateKey, String fieldKey, focusNode) {
      if (focusNode.hasFocus) {
        num mengde = varerState[prodID][MENGDE];
        num value = Util.parseStringtoNum(txtCtrlMap[fieldKey].text);
        switch (stateKey) {
          case PRIS:
            double dependentValue =
                (value != null && mengde > 0) // mengde != null && mengde != null
                    ? value.toDouble() * mengde.toDouble()
                    : 0.0;
            txtCtrlMap[prodID + TOTALPRIS].text = (dependentValue).toStringAsFixed(2);
            onSavedHandlerVareState(prodID, TOTALPRIS)((dependentValue).toStringAsFixed(2));
            break;
          case TOTALPRIS:
            double dependentValue =
                (value != null && mengde > 0) // mengde != null && mengde != null
                    ? value.toDouble() / mengde.toDouble()
                    : 0.0;
            txtCtrlMap[prodID + PRIS].text = (dependentValue).toStringAsFixed(2);
            onSavedHandlerVareState(prodID, PRIS)((dependentValue).toStringAsFixed(2));

            break;
          default:
        }
      }
    }

    Widget getTextInput(
        {String label, String stateKey, String prodID, double zIndex, dynamic vare}) {
      ///
      /// "key" til  (pris/totalpris feltene) i focusNodeMap og txtCtrlMap, er lik "fieldKey" og ikke "stateKey"
      ///
      String fieldKey = prodID + stateKey;

      Widget _txtFormField = MyTextFormField_draft(
        label: label,
        fieldKey: fieldKey,
        onChanged: (value) => onSavedHandlerVareState(prodID, stateKey)(value),
        value: vare[stateKey]?.toString() ?? "",
        validateInput: (value) => validateInputHandler(value, required: true, isNum: true),
        changeToNextFocusNode: () => changeToNextFocusNode(zIndex),
        addOrRemoveFromInvalidNodes: (valid, focusNode) =>
            addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndex),
        keyboardType: TextInputType.number,
        attachToTextControllerMap: attachToTextControllerMapHandler,
        removeFromTextControllerMap: (fKey) => removeFromTextControllerMapHandler(fKey),
        attachToFocusNodeMap: (node) => attachToFocusNodeMapHandler(zIndex, node),
        removeFromFocusNodeMap: () => removeFromFocusNodeMapHandler(zIndex),
        addListnersToTextController: [
          (FocusNode node) => calcDependentPrice(prodID, stateKey, fieldKey, node),
          //
          () {
            if (stateKey == TOTALPRIS) calcSummen();
          },
        ],
        addListnersToFocusNode: [
          (FocusNode node) {
            if (node.hasFocus)
              txtCtrlMap[fieldKey].selection =
                  TextSelection(baseOffset: 0, extentOffset: txtCtrlMap[fieldKey].text.length);
          }
        ],
      );

      return _txtFormField;
    }

    //kun hvis vare er skannet ,, men ikke hvis vare blir valgt fra TypeaHeadFeild
    void routeToAddNewProduktWidget(dynamic vare, String strekkode) async {
      Map result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddNewProduktWidget(
                  strekkode: strekkode,
                )),
      );
      bool onSeccess = result != null && result[NAVN] != null && result[NAVN].isNotEmpty;

      if (onSeccess) {
        vare[PRODUKT_ID] = result[PRODUKT_ID];
        vare[NAVN] = result[NAVN];
      }
    }

    Widget getPriceRow(Map<String, dynamic> vare, double zIndex) {
      bool isUnregisteredProdukt = (vare[PRODUKT_ID] ?? "").contains("UnregisteredProdukt");
      bool bgColor = ((zIndex * 10) ~/ 1).isOdd;
      return Container(
        // Keys! What are they good for? https://medium.com/flutter/keys-what-are-they-good-for-13cb51742e7d
        key: ValueKey(vare[PRODUKT_ID]),
        padding: EdgeInsets.all(8.0),
        decoration: getboxDecorationVareEntry(bgColor),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: isUnregisteredProdukt
                      ? InkWell(
                          child: Text(
                            'Legg til prod info',
                            style: TextStyle(color: Colors.blue),
                          ),
                          onTap: () {
                            routeToAddNewProduktWidget(vare, vare[STREKKODE]);
                          })
                      : Text(vare[NAVN]),
                ),
                // Text(vare[PRODUKT_ID].toString()),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: getTextInput(
                      label: "Pris",
                      stateKey: PRIS,
                      zIndex: (zIndex + 0.01),
                      prodID: vare[PRODUKT_ID],
                      vare: vare),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                        child: Text(
                            "X" + vare[MENGDE].toString() + (vare[ER_LEOSVEKT] ? "kg" : "")))),
                Expanded(
                  flex: 2,
                  child: getTextInput(
                      label: "TotalPris",
                      stateKey: TOTALPRIS,
                      zIndex: (zIndex + 0.02),
                      prodID: vare[PRODUKT_ID],
                      vare: vare),
                )
              ],
            ),
          ],
        ),
      );
    }

    Widget _getAllPriceRows() {
      double zIndex = this.minZIndex;

      List<Widget> tiles = List<Widget>();

      varerState.forEach((k, v) {
        tiles.add(getPriceRow(v, (zIndex)));
        zIndex += 0.1;
      });
      txtCtrlMap.forEach((k, v) {
        // if (k.toString().contains(PRIS) && txtCtrlMap[k].text.toString().isNotEmpty) {
        //   txtCtrlMap[k].text =  "5";

        // num pris = Util.parseStringtoNum(txtCtrlMap[k]) ?? 0;
        // num mengde = Util.parseStringtoNum(txtCtrlMap[MENGDE]) ?? 0;
        // txtCtrlMap[TOTALPRIS] = (pris * mengde).toString();
        // }
      });

      /// Cleaning up the focusNodeMap:
      /// at this line zIndex will be equal to the last TOTALPRIS element,
      /// if there is any value in focusNodeMap where (minZIndex < value < maxZIndex)
      /// that means there has been removed some elems VARER in the prev build
      focusNodeMap.removeWhere((k, v) => k < this.maxZIndex && k > zIndex);

      return Column(children: tiles);
    }

    return _getAllPriceRows();
  }
}
