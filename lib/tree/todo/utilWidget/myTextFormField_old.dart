import 'package:flutter/material.dart';
import './myCallback.dart';

class MyTextFormField_old extends StatelessWidget {
  MyTextFormField_old({
    this.label,
    this.autovalidate = false,
    this.textController,
    this.currentNode,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.stateKey,
    this.orderIndex,  
    this.onSaved,
    this.validateInput,
    this.changeFieldFocus,
    this.changeFieldFocusByOrderNr,
    this.addOrRemoveFromInvalidNodes,
  });

  //  keyboardType: TextInputType.number,
  // textInputAction: TextInputAction.next

  String label;
  String stateKey;
  bool autovalidate;
  bool enabled;
  double orderIndex;
  TextEditingController textController;
  FocusNode currentNode;
  MCdynamicDynamic validateInput;
  MC2Dynamicvoid changeFieldFocus;
  MCDynamicVoid changeFieldFocusByOrderNr;
  MC3Dynamicvoid addOrRemoveFromInvalidNodes;
  MCDynamicVoid onSaved;
  TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {

    print("¤¤¤¤¤build¤¤¤¤    ¤¤¤¤¤build¤¤¤¤    $label   ¤¤¤¤¤build¤¤¤¤    ¤¤¤¤¤¤¤¤¤¤¤");
    return TextFormField(
      keyboardType: keyboardType,
      autovalidate: autovalidate,
      decoration: InputDecoration(labelText: label),
      enabled: enabled,

      //ikke Nødvendig, verdier vil forbli t.o.m etter validator kall returnerer en err
      // initialValue: produktState[stateKey],
      controller: textController,
      focusNode: currentNode
      // ..addListener(() {
      //   if (label == "Strekkode") if (currentNode.hasFocus) {
      //     this._overlayEntry = this._createOverlayEntry(context);
      //     Overlay.of(context).insert(this._overlayEntry);
      //   } else {
      //     this._overlayEntry.remove();
      //   }
      // })
      ,

      textInputAction: TextInputAction.next,
      onFieldSubmitted: (str) {
        // Implement ENTEN
        // Blir brukt i ProduktForm ;;; Fjern denne!!
        // if (!(currentNode == null || nextFocusNode == null))
        //   changeFieldFocus(currentNode, nextFocusNode);

        //ELLER
        //Blir brukt i HandleForm
        if (changeFieldFocusByOrderNr != null)
          changeFieldFocusByOrderNr(stateKey);
      },
      validator: (str) {
        String err = validateInput(str);
        bool valid = err == null;
        if (currentNode != null)
          addOrRemoveFromInvalidNodes(valid, currentNode, orderIndex);
        return err;
      },
      onSaved: onSaved,
    );
  }
}
