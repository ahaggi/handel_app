import 'package:flutter/material.dart';
import 'package:handle_app/tree/todo/utilWidget/TypeAheadMixin.dart';

import 'myCallback.dart';

/// ### Example
///     MyTypeAheadTextFormField(
///     attachToFocusNodeMap: (node) =>
///     attachToFocusNodeMapHandler(zIndexMap[BUTIKK], node),
///     // removeFromFocusNodeMap: ,
///     dataStream: DataDB.getStreamHandleCollectionSnapshot(),
///     // onElmHasBeenChoosen: ,
///     setOnScrollHandler: setOnScrollHandler,
///     extractDataFromSnapshot: (snapshot) {
///     Map<String, String> _data = Map<String, String>();
///     snapshot.data.documents.forEach((doc) {
///       if (doc != null && doc[BUTIKK] != null) {
///         String butikk = doc[BUTIKK].toString();
///         _data.putIfAbsent(butikk.toLowerCase(), () => butikk);
///       }
///     });
///     return _data;
///     },
///     childAttirbutes: {
///     "label": "Butikk",
///     "fieldKey": BUTIKK,
///     "validateInput": (value) => validateInputHandler(value, required: true),
///     "changeToNextFocusNode": () => changeToNextFocusNodeHandler(zIndexMap[BUTIKK]),
///     "onSaved": (value) => onSavedHandelStateHandler(BUTIKK)(value),
///     "addOrRemoveFromInvalidNodes": (valid, focusNode) =>
///                                    addOrRemoveFromInvalidNodesHandler(valid, focusNode, zIndexMap[BUTIKK]),
///     "keyboardType": TextInputType.text,
///     },
///     );
class MyTypeAheadTextFormField extends StatefulWidget {
  MyTypeAheadTextFormField({
    Key key,
    this.attachToFocusNodeMap,
    this.removeFromFocusNodeMap,
    this.attachToTextControllerMap,
    this.removeFromTextControllerMap,
    this.addListnersToTextController,
    this.dataStream,
    this.onElmHasBeenChoosen,
    this.setOnScrollHandler,
    this.extractDataFromSnapshot,
    @required this.childAttirbutes, this.value,
  });

  final MCDynamicVoid attachToFocusNodeMap;
  final MCvoidVoid removeFromFocusNodeMap;
  final MC2Dynamicvoid attachToTextControllerMap;
  final MCDynamicVoid removeFromTextControllerMap;

  final List<dynamic> addListnersToTextController;
  final String value ;

  /// usually this stream is of the type Stream<QuerySnapshot>
  final Stream<dynamic> dataStream;
  final MCDynamicVoid onElmHasBeenChoosen;
  final dynamic setOnScrollHandler;
  final dynamic extractDataFromSnapshot;

  final dynamic childAttirbutes;

  @override
  _MyTypeAheadTextFormFieldState createState() =>
      _MyTypeAheadTextFormFieldState();
}

class _MyTypeAheadTextFormFieldState extends State<MyTypeAheadTextFormField> {
  TextEditingController textController;
  FocusNode focusNode;

  @override
  void initState() {
    textController = TextEditingController();
    focusNode = FocusNode();
    textController.text = widget.childAttirbutes["value"] ?? "";

    attachToTextControllerMap();
    addListnersToTextController();
    super.initState();
  }

  @override
  void dispose() {
    print(
        "€€€€dispose€€€€    ${widget.key ?? 'TypeAheadTextFormFeild'}  €€€€dispose€€€€    €€€€dispose€€€€");
    if (widget.removeFromFocusNodeMap != null) widget.removeFromFocusNodeMap();

    textController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  void attachToTextControllerMap() {
    if (widget.attachToTextControllerMap != null)
      widget.attachToTextControllerMap(
          widget.childAttirbutes["fieldKey"], textController);
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

  // void addListnersToFocusNode() {
  //   if (widget.addListnersToFocusNode != null &&
  //       widget.addListnersToFocusNode.isNotEmpty) {
  //     widget.addListnersToFocusNode.forEach((fn) {
  //       focusNode.removeListener(() => fn(focusNode));
  //       focusNode.addListener(() => fn(focusNode));
  //     });
  //   }
  // }

  Widget _inputFeild() => _InnerTextFormField(
        label: widget.childAttirbutes["label"],
        fieldKey: widget.childAttirbutes["fieldKey"],
        validateInput: widget.childAttirbutes["validateInput"],
        changeToNextFocusNode: widget.childAttirbutes["changeToNextFocusNode"],
        onSaved: widget.childAttirbutes["onSaved"],
        addOrRemoveFromInvalidNodes:
            widget.childAttirbutes["addOrRemoveFromInvalidNodes"],
        keyboardType: widget.childAttirbutes["keyboardType"],
        textController: textController,
        focusNode: focusNode,
      );

  @override
  Widget build(BuildContext context) {
    attachToFocusNodeMap();

    return StreamBuilder<dynamic>(
      stream: widget.dataStream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData)
          return _inputFeild();
        else {
          Map<String, String> _data = widget.extractDataFromSnapshot(snapshot);

          return TypeAheadMixin(
            txtCtrl: textController,
            fcsNode: focusNode,
            setOnScroll: widget.setOnScrollHandler,
            data: _data,
            child: _inputFeild(),
          );
        }
      },
    );
  }
}

class _InnerTextFormField extends StatelessWidget {
  _InnerTextFormField({
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
    this.textController,
    this.focusNode,
  }) : super(key: key);

  final String label;
  final String fieldKey;
  final bool autovalidate;
  final bool enabled;
  final TextInputType keyboardType;
  final MCdynamicDynamic validateInput;
  final MCvoidVoid changeToNextFocusNode;
  final MC2Dynamicvoid addOrRemoveFromInvalidNodes;
  final MCDynamicVoid onSaved;

  final TextEditingController textController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType,
      autovalidate: autovalidate,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14.0),
      ),
      enabled: enabled,
      controller: textController,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (str) {
        if (changeToNextFocusNode != null) changeToNextFocusNode();
      },
      validator: (str) {
        if (validateInput != null) {
          String err = validateInput(str);
          bool valid = err == null;
          if (addOrRemoveFromInvalidNodes != null)
            addOrRemoveFromInvalidNodes(valid, focusNode);
          return err;
        } else
          return null;
      },
      onSaved: onSaved,
    );
  }
}
