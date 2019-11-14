import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:handle_app/tree/todo/utilWidget/myCallback.dart';
import 'package:handle_app/tree/todo/utilWidget/util.dart';


class GenericFormWidget extends StatefulWidget {
  GenericFormWidget(
      {Key key,
      @required this.scaffoldKey,
      @required this.child,
      @required this.onSubmitToDB,
      @required this.onSetFocusOnFirstInvalidNode,
      @required this.setValidateInputAs,
      @required this.setSubmitAs,
      this.onScrollHandler, })
      : super(key: key);
      
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Widget child;
  final VoidCallback onSubmitToDB;
  final dynamic onSetFocusOnFirstInvalidNode;

  final dynamic setValidateInputAs;
  final MCDynamicVoid setSubmitAs;

  final dynamic onScrollHandler;

  @override
  _GenericFormWidgetState createState() => _GenericFormWidgetState();
}

class _GenericFormWidgetState extends State<GenericFormWidget> {
  final formKey = GlobalKey<FormState>();

  bool formAutovalidate;

  @override
  void initState() {
    formAutovalidate = false;

    widget.setValidateInputAs(validateInputHandler);
    widget.setSubmitAs(submitHandler);
    super.initState();
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      // to invoke each FormField's validate callback
      form.save(); //to invoke each FormField's onSaved callback, witch set new State
      return true;
    }
    return false;
  }

  void submitHandler() {
    if (validateAndSave()) {
      widget.onSubmitToDB();
    } else {
      // UtilUI.getCustomSnackBar(scaffoldKey: widget.scaffoldKey,text: "Oops noe gikk galt!");
      widget.onSetFocusOnFirstInvalidNode();
    }
  }

  String validateRequired(String input) {
    String err = "";
    if (input.isEmpty) err += "Påkrevd felt.\n";
    return err.isEmpty ? null : err;
  }

  String validateIsNumber(String input, {bool required, bool hasToBePos}) {
    String err = "";
    var value = Util.parseStringtoNum(
        input); // Her verdien på felte/txtCtrl kan være int, double eller null
    bool _nan = value == null;
    bool _isLte0 = value !=null && value <= 0;
    switch (required) {
      case true:
        {
          if (hasToBePos && (_isLte0 || _nan))
            err += "må være positivt tall";
          else if (_nan) err += "må være et tall";
        }
        break;
      case false:
        if ((_isLte0 || _nan) && input.isNotEmpty)
          err += "må være positivt tall, eller tomt";
        else if (_nan && input.isNotEmpty) err += "må være et tall, eller tomt";

        break;
    }

    return err.isEmpty ? null : err;
  }

  String validateIsDate(String input, {bool required}) {
    String err = "";

    // parse [formattedString].
    // Works like [parse] except that this function returns null if the input string cannot be parsed
    var value = DateTime.tryParse(input);

    // Her verdien på felte/txtCtrl kan være int eller double
    bool notValidDate = value == null;

    if (!required && input.isNotEmpty && notValidDate)
      err += "Feltet må være en dato, eller tom";

    if (required && notValidDate) err += "Ugyldig dato.";

    return err.isEmpty ? null : err;
  }

  String validateInputHandler(String input,
      {bool required = false,
      bool isNum = false,
      bool hasToBePos = false,
      bool isDate = false}) {
    String err = "";
    if (required && input.isEmpty) err += validateRequired(input) ?? "";

    if (isNum)
      err +=
          validateIsNumber(input, required: required, hasToBePos: hasToBePos) ??
              "";

    if (isDate) err += validateIsDate(input, required: required) ?? "";

    return err.isEmpty ? null : err;
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Widget _form = NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          // print("_form_form_form_form_form_form_form_form_form");
          if (widget.onScrollHandler != null) widget.onScrollHandler();
        },
        child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Form(
                    key: formKey,
                    autovalidate: formAutovalidate,
                    child: widget.child)
              ],
            )));

    return _form;
  }
}
