import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:handle_app/tree/todo/utilWidget/genericFormWidget.dart';
import 'package:handle_app/tree/todo/utilWidget/utilUI.dart';
import 'package:handle_app/tree/handle/addHandel/pages/handleFormPage/subWidgets/handelFormComponentsWidget.dart';

class HandelFormWidget extends StatefulWidget {
  HandelFormWidget({
    this.handelState,
    this.varerState,
    this.submitToDbHandler,
  });
  final Map<String, dynamic> handelState;
  final Map<String, dynamic> varerState;
  final VoidCallback submitToDbHandler;

  @override
  _HandelFormWidgetState createState() => _HandelFormWidgetState();
}

class _HandelFormWidgetState extends State<HandelFormWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _fromAutovalidate;

  /// used just for the input of {DATO, SUMMEN and all "price/totalPrice"}
  Map<dynamic, dynamic> txtCtrlMap = Map<dynamic, dynamic>();

  Map<dynamic, dynamic> zIndexMap;
  SplayTreeMap<double, dynamic> focusNodeMap =
      SplayTreeMap<double, dynamic>.from({}, (a, b) => a.compareTo(b));
  SplayTreeMap<double, dynamic> invalidNodesMap =
      SplayTreeMap<double, dynamic>.from({}, (a, b) => a.compareTo(b));

  @override
  void initState() {
    super.initState();

    _fromAutovalidate = false;

    txtCtrlMap = {};

    zIndexMap = UtilUI.initZIndexMap(widget.handelState, 0);
  }

  @override
  void dispose() {
    // all the textCtrls and focusNodes are disposed at it's ¤¤¤ MyTextFormFields
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

  setFocusOnFirstInvalidNode() =>
      UtilUI.setFocusOnFirstInvalidNode(context: context, invalidNodesMap: invalidNodesMap);

  void addOrRemoveFromInvalidNodesHandler(valid, currentNode, zIndex) =>
      UtilUI.addOrRemoveFromInvalidNodesMapHandler(
          invalidNodesMap: invalidNodesMap, valid: valid, currentNode: currentNode, zIndex: zIndex);

  void _submitHandler() {
    if (widget.varerState.isEmpty)
      UtilUI.getCustomSnackBar(scaffoldKey: _scaffoldKey, text: "sdf!");
    this.submitHandler();
  }

  ///************************************************************************************ */

  // implemented in GenericForm to be used in FormComponentsWidget
  dynamic validateInputHandler;
  void setValidateInputAs(func) => validateInputHandler = func;

  dynamic submitHandler;
  void setSubmitAs(func) {
    submitHandler = func;
  }

  ///************************************************************************************ */

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

  /// ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
  /// this is implemented at "TypeAheadTextFormFeild", and will run inside widget, onNotification: (scrollNotification)
  VoidCallback onScrollHandler;

  void setOnScrollHandelFormHandler(function) {
    onScrollHandler = function;
  }

  /// ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

  @override
  Widget build(BuildContext context) {
/****************************************************************************** */
    Widget _handelFormComponentsWidget = HandelFormComponentsWidget(
      handelState: widget.handelState,
      varerState: widget.varerState,
      txtCtrlMap: this.txtCtrlMap,
      zIndexMap: this.zIndexMap,
      focusNodeMap: this.focusNodeMap,
      invalidNodesMap: this.invalidNodesMap,
      changeToNextFocusNodeHandler: changeToNextFocusNodeHandler,
      validateInputHandler: validateInputHandler,
      addOrRemoveFromInvalidNodesHandler: addOrRemoveFromInvalidNodesHandler,
      attachToTextControllerMapHandler: attachToTextControllerMapHandler,
      removeFromTextControllerMapHandler: removeFromTextControllerMapHandler,
      attachToFocusNodeMapHandler: attachToFocusNodeMapHandler,
      removeFromFocusNodeMapHandler: removeFromFocusNodeMapHandler,
      onSubmit: _submitHandler,
      setOnScrollHandelFormHandler: setOnScrollHandelFormHandler,
    );

    Widget _form = GenericFormWidget(
      scaffoldKey: _scaffoldKey,
      child: _handelFormComponentsWidget,
      setSubmitAs: setSubmitAs,
      setValidateInputAs: setValidateInputAs,
      onSubmitToDB: widget.submitToDbHandler,
      onSetFocusOnFirstInvalidNode: setFocusOnFirstInvalidNode,
      onScrollHandler: onScrollHandler,
    );

/****************************************************************************** */

    // Widget form = Material(
    //   child: NestedScrollView(
    // headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
    //   return <Widget>[
    //     new SliverAppBar(
    //       pinned: true,
    //       title: const Text('Legg til et handel'),

    //     ),
    //   ];
    // },
    // body: Form(
    //   key: formKey,
    //   autovalidate: _fromAutovalidate,
    //   child: Padding(
    //     padding: const EdgeInsets.only(left: 20.0, right: 20.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.stretch,
    //       children: <Widget>[
    //         _dato(),
    //         _butikk,
    //         Expanded(
    //           child:
    //         ,
    //         ),
    //         _summen,
    //         _betaltMed,
    //         _submitBtn,
    //       ],
    //     ),
    //   ),
    // )),
    // );

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Legg til et handel'),
        ),
        body: _form);
  }
}
