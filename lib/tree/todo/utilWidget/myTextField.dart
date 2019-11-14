import 'package:flutter/material.dart';
import './myCallback.dart';

class MyTextField extends StatefulWidget {
  MyTextField({
    this.value,
    this.enabled = true,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.decoration,
    this.validateInputHandler,
  });

  final String value;
  final bool enabled;
  final MCDynamicVoid onChanged;
  final TextInputType keyboardType;
  final Map decoration;
  final dynamic validateInputHandler;

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool valid = true;
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  @override
  void initState() {
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        textController.selection =
            TextSelection(baseOffset: 0, extentOffset: textController.text.length);
      }
    });
    textController.text = widget.value;
    textController.addListener(() {
      if (widget.validateInputHandler != null)
        setState(() {
          valid = (focusNode.hasFocus && num.tryParse(textController.text) == 0) ||
              (widget.validateInputHandler(textController.text));
        });
    });

    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (text) {
        widget.onChanged(text);
      },
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.decoration["labelText"],
        labelStyle: widget.decoration["labelStyle"],
        errorBorder: !valid ? widget.decoration["errorBorder"] : null,
        errorStyle: !valid ? widget.decoration["errorStyle"] : null,
        errorText: !valid ? widget.decoration["errorText"] : null,
      ),
      enabled: widget.enabled,
      controller: textController,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
    );
  }
}
