import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './utilLlevenshteinDistance.dart';
import './myCallback.dart';
import 'Tuple.dart';
/// This mixinm will wrap already biult "TextField" or "TextFormField" inorder to provide suggestion:
///
///    - it can be used directly.
/// 
/// ### Example
///     TypeAheadMixin(
///     txtCtrl: vareNvnCtrl,
///     fcsNode: vareNvnNode,
///     setOnScroll: setOnScrollHandler,
///     data: _data,
///     child: _navnInputFeild,
///     ...
///     )
/// 
///    - or it can be used indirectly. Take a look at `MyTypeAheadTextFormField`
/// 
class TypeAheadMixin extends StatefulWidget {
  TypeAheadMixin({
    Key key,
    @required this.child,
    @required this.txtCtrl,
    @required this.fcsNode,
    @required this.setOnScroll,
    @required this.data,
    this.onElmHasBeenChoosen,
    // this.keyTextFormField,
    // this.curve: Curves.ease,
    // this.duration: const Duration(milliseconds: 100),
  }) : super(key: key);

  final Widget child;
  final TextEditingController txtCtrl;
  final FocusNode fcsNode;
  final MCDynamicVoid setOnScroll;
  final MCDynamicVoid onElmHasBeenChoosen;
  final Map<String, String> data;

  // final Curve curve;
  // final Duration duration;
  // GlobalKey keyTextFormField;

  @override
  _TypeAheadMixinState createState() => _TypeAheadMixinState();
}

class _TypeAheadMixinState extends State<TypeAheadMixin>
    with WidgetsBindingObserver {
  OverlayEntry _overlayEntry;
  bool _overlayEntryIsShown = false;
  String _lastProcessedTxt;
  Future<List<Tuple<String, String>>> res;
  int _nrOfRunningOnChangeListner;

  @override
  void initState() {
    widget.txtCtrl.addListener(_onChangeListner);
    widget.fcsNode.addListener(_onLostFocus);
    WidgetsBinding.instance.addObserver(this);

    _nrOfRunningOnChangeListner = 0;
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // widget.txtCtrl.removeListener(_onChangeListner);
    super.dispose();
  }

  ///
  /// 1- Must extends with WidgetsBinding to implement/override this function  extends State<TypeAheadTextFormFeild> with WidgetsBindingObserver
  /// 2- Add this Widget as observer   WidgetsBinding.instance.addObserver(this),
  /// 3- Implement the needed functions,  we are only interested in being notified when the Screen metrics change (which is the case when
  ///    the keyboard opens or closes).   void didChangeMetrics()
  ///
  @override
  void didChangeMetrics() {
    _removeOverlayEntries();
  }

  List<Widget> _getChipsList(List<Tuple<String, String>> _resList) {


    return List<Widget>.generate(_resList.length, (ind) {
      var item = _resList[ind];
      return InkWell(
          onTap: () {
            _lastProcessedTxt = item.txt;
            _nrOfRunningOnChangeListner = 0;
            _removeOverlayEntries();

            widget.txtCtrl.text = item.txt;
            _moveCursor();
            if (widget.onElmHasBeenChoosen != null)
              widget.onElmHasBeenChoosen(item.id);
          },
          child: Chip(label: Text(item.txt)));
    }); //.toList();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject();
    Offset _textFormFieldOffset = renderBox.localToGlobal(Offset.zero);
    Size _textFormFieldSize = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
              ///
              ///Only two out of the three horizontal values (left, right, width),
              /// and only two out of the three vertical values (top, bottom, height), can be set.
              /// In each case, at least one of the three must be null.
              left: _textFormFieldOffset.dx,
              width: _textFormFieldSize.width,

              top: _textFormFieldOffset.dy + _textFormFieldSize.height,
              // height: _textFormFieldSize.height * 2,

              ///
              child: Material(
                  elevation: 4.0,
                  child: FutureBuilder(
                    future: res,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Tuple<String, String>>> snapshot) {
                      if (snapshot.data != null &&
                          snapshot.data.length > 0 &&
                          !snapshot.hasError)
                        return
                            //To impose maxHeight on SingleChildScrollView which will allow the List to have dynamic heigt depends on the nr of Chips
                            // ALt. we can remove ConstrainedBox and difine a static height at Positioned Widget which is the parent of ConstrainedBox
                            ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: _textFormFieldSize.height * 2,
                          ),
                          child:
                              //Sometimes a layout is designed around the flexible properties of a Column, but there is the concern that in some cases,
                              //there might not be enough room to see the entire contents.Because of devices with small screens, or in landscape mode where the aspect ratio isn't what was originally envisioned, or the app is being shown in split-screen mode.
                              //In any case, as a result, it might make sense to wrap the layout in a SingleChildScrollView.
                              SingleChildScrollView(
                                  child: Wrap(
                            spacing: 8.0, // gap between adjacent chips

                            children: _getChipsList(snapshot.data),
                          )),
                        );
                      else

                        return ListTile(
                          title: Text("No suggestions!!"),
                          onTap: ()=>_removeOverlayEntries(),
                        );
                    },
                  )),
            ));
  }

  void _onLostFocus() {
    if (!widget.fcsNode.hasFocus) _removeOverlayEntries();
  }

  void _onChangeListner() {
    // If there is many inputField which implement this mixin and they are in the same listView,
    // each of the inputFields will have to reset the "setOnScroll" to remove its own overlayEntry on scrolling
    // IF SO, UNCOMMENT THE FLWG LINE
    // if (widget.setOnScroll != null) widget.setOnScroll(_removeOverlayEntries);

    // fetch suggestion and show overlay
    if (widget.txtCtrl.text.length < 2)
      _removeOverlayEntries();
    else if (widget.txtCtrl.text != _lastProcessedTxt) {
      print("_onChangeListner nr. ${++_nrOfRunningOnChangeListner}");

      _lastProcessedTxt = widget.txtCtrl.text;
      List<Tuple<String, String>> sugg = getSuggestions(
          _lastProcessedTxt); //TODO async getSuggestion returnerer en Future

      res = Future.value(sugg);
      _showOverLayEntry();
    }
  }

  void _moveCursor() {
    widget.txtCtrl.selection = new TextSelection.fromPosition(
        new TextPosition(offset: widget.txtCtrl.text.length));
  }

  List<Tuple<String, String>> getSuggestions(String input) {
    return UtilLevDistance.getSuggestions(
        input: input, data: widget.data, nrOfSuggestion: 10);
  }

  void _showOverLayEntry() {
    _removeOverlayEntries();
    _overlayEntry = _createOverlayEntry();

    Overlay.of(context).insert(_overlayEntry);
    _overlayEntryIsShown = true;
  }

  void _removeOverlayEntries() {
    if (_overlayEntryIsShown) {
      _overlayEntry.remove();
      _overlayEntryIsShown = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.setOnScroll != null)
      widget.setOnScroll(_removeOverlayEntries);

    return widget.child;
  }
}


