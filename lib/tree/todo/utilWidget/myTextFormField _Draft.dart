import 'package:flutter/material.dart';
import './myCallback.dart';

class MyTextFormField_draft extends StatefulWidget {
  MyTextFormField_draft({
    Key key,
    this.label,
    this.autovalidate = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.fieldKey,
    this.onSaved,
    this.validateInput,
    this.changeToNextFocusNode,
    this.addOrRemoveFromInvalidNodes,
    this.attachToTextControllerMap,
    this.removeFromTextControllerMap,
    this.attachToFocusNodeMap,
    this.removeFromFocusNodeMap,
    this.addListnersToFocusNode,
    this.addListnersToTextController, this.onTap, this.onChanged, this.value,
  }) : super(key: key);

  //  keyboardType: TextInputType.number,
  // textInputAction: TextInputAction.next

  final String label;
  final String fieldKey;
  final bool autovalidate;
  final bool enabled;
  final String value;

  final TextInputType keyboardType;
  final MCdynamicDynamic validateInput;
  final MCvoidVoid changeToNextFocusNode;
  final MC2Dynamicvoid addOrRemoveFromInvalidNodes;
  final MCDynamicVoid onSaved;
  final MCDynamicVoid onChanged;
  final MC2Dynamicvoid attachToTextControllerMap;
  final MCDynamicVoid removeFromTextControllerMap;
  final MCDynamicVoid attachToFocusNodeMap;
  final MCvoidVoid removeFromFocusNodeMap;
  final GestureTapCallback onTap;

  /// All the listner has to be of type //TODO
  final List<dynamic> addListnersToFocusNode;
  final List<dynamic> addListnersToTextController;

  @override
  _MyTextFormField_draftState createState() => _MyTextFormField_draftState();
}

class _MyTextFormField_draftState extends State<MyTextFormField_draft> {
  TextEditingController textController;
  FocusNode focusNode;

  @override
  void initState() {
    focusNode = FocusNode(debugLabel: widget.fieldKey);
    //These 2 functions is called at the build function, this way we can have a consistent FocusNodeMap
    // attachToFocusNodeMap();
    // addListnersToFocusNode();

    textController = TextEditingController();

    textController.text = widget.value ?? "";

    attachToTextControllerMap();
    addListnersToTextController();
        // print(
        // "===initState===    ===initState===    ${focusNode.debugLabel}    ${widget.fieldKey}  ===initState===    ===initState===");

    super.initState();
  }

  @override
  void dispose() {
    print(
        "€€€€dispose€€€€    €€€€dispose€€€€    ${focusNode.debugLabel}    ${widget.fieldKey}  €€€€dispose€€€€    €€€€dispose€€€€");

    if (widget.removeFromTextControllerMap != null)
      widget.removeFromTextControllerMap(widget.fieldKey);

    if (widget.removeFromFocusNodeMap != null) widget.removeFromFocusNodeMap();

    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void attachToTextControllerMap() {
    if (widget.attachToTextControllerMap != null)
      widget.attachToTextControllerMap(widget.fieldKey, textController);
  }

  void addListnersToTextController() {
    if (widget.addListnersToTextController != null &&
        widget.addListnersToTextController.isNotEmpty)
      widget.addListnersToTextController.forEach((fn) {
        if (fn is VoidCallback) {
          textController.removeListener(fn);
          textController.addListener(fn);
        } else {
          textController.removeListener(() => fn(focusNode));
          textController.addListener(() => fn(focusNode));
        }
      });
  }

  void attachToFocusNodeMap() {
    if (widget.attachToFocusNodeMap != null)
      widget.attachToFocusNodeMap(focusNode);
  }

  void addListnersToFocusNode() {
    if (widget.addListnersToFocusNode != null &&
        widget.addListnersToFocusNode.isNotEmpty) {
      widget.addListnersToFocusNode.forEach((fn) {
        focusNode.removeListener(() => fn(focusNode));
        focusNode.addListener(() => fn(focusNode));
      });
    }
  }

  void removeListnersFromFocusNode() {
    if (widget.addListnersToFocusNode != null &&
        widget.addListnersToFocusNode.isNotEmpty)
      widget.addListnersToFocusNode
          .forEach((fn) => focusNode.removeListener(() => fn(focusNode)));
  }

  @override
  Widget build(BuildContext context) {
    attachToFocusNodeMap();

    addListnersToFocusNode();

    // print(
    //     "¤¤¤¤¤build¤¤¤¤    ¤¤¤¤¤build¤¤¤¤    ${focusNode.debugLabel}    ${widget.fieldKey}    ¤¤¤¤¤build¤¤¤¤    ¤¤¤¤¤¤¤¤¤¤¤");
    return TextFormField(

      
      keyboardType: widget.keyboardType,
      autovalidate: widget.autovalidate,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(fontSize: 14.0),
      ),
      enabled: widget.enabled,
      controller: textController,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (str) {
        if (widget.changeToNextFocusNode != null)
          widget.changeToNextFocusNode();
      },
      validator: (str) {
        if (widget.validateInput != null) {
          String err = widget.validateInput(str);
          bool valid = err == null;
          if (widget.addOrRemoveFromInvalidNodes != null)
            widget.addOrRemoveFromInvalidNodes(valid, focusNode);
          return err;
        } else
          return null;
      },
      onSaved: widget.onSaved,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
    );
  }
}
