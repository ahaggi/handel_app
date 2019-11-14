import 'dart:collection';

import 'package:flutter/material.dart';

class UtilUI {
  static void getCustomSnackBar(
      {@required GlobalKey<ScaffoldState> scaffoldKey, String text}) {
    ScaffoldState _scaffoldState = scaffoldKey.currentState;

    _scaffoldState.removeCurrentSnackBar();
    _scaffoldState.showSnackBar(SnackBar(
      content: Text(text),
      // action: SnackBarAction(
      //     label: 'Undo',
      //     onPressed: () {
      //       // Some code to undo the change!
      //     })
    ));
    Future.delayed(
        Duration(seconds: 3), () => _scaffoldState.hideCurrentSnackBar());
  }

  //for alle verdier med unntakk av [matvare] || [erLoesvekt] som er (bool og endring på den vil føre til endring på produktState state)
  static Map<dynamic, dynamic> initTxtCtrlMap(Map<dynamic, dynamic> map) {
    Map<dynamic, dynamic> _ctrlMap = Map<dynamic, dynamic>();
    map.forEach((k, v) {
      if (v is Map) {
        _ctrlMap.addAll(initTxtCtrlMap(v));
      } else if (map[k] is! bool) {
        // (k != ER_MATVARE && k != ER_LEOSVEKT)
        // var txtctrl = TextEditingController()..text = v.toString();
        // _ctrlMap[k] = txtctrl;
        _ctrlMap[k] = null;
      }
    });
    return _ctrlMap;
  }

  static Map<dynamic, dynamic> initZIndexMap(
      Map<dynamic, dynamic> map, prevZind) {
    var _tempmap = {};

    double lastZindex = prevZind.toDouble();

    map.forEach((k, v) {
      if (v is! Map && map[k] is! bool) {
        // map[k] is! bool for eks. (k != ER_MATVARE && k != ER_LEOSVEKT)
        double currentZindex = ++lastZindex;
        _tempmap[k] = currentZindex;
      }

      /// The next line is to reserve the values between lastZindex and lastZindex+4 i.e. 3,4,5,6,7. To be used for the elems of VarerPriceListWidget
      if (map[k] is List) lastZindex = lastZindex + 4;
    });

    return _tempmap;
  }


  static void setFocusOnFirstInvalidNode(
      {@required BuildContext context,
      @required SplayTreeMap<double, dynamic> invalidNodesMap}) {
    double key = invalidNodesMap.firstKey();
    FocusNode firstInvalid = invalidNodesMap[key];
    if (firstInvalid != null) FocusScope.of(context).requestFocus(firstInvalid);
  }

  static void addOrRemoveFromInvalidNodesMapHandler(
      {@required SplayTreeMap<double, dynamic> invalidNodesMap,
      @required bool valid,
      @required FocusNode currentNode,
      @required double zIndex}) {
    if (!valid) {
      invalidNodesMap.putIfAbsent(zIndex, () => currentNode);
    } else if (valid) invalidNodesMap.remove(zIndex);
  }

  ///********************************showDialog****************************************** */
  ///************************************************************************************ */

  // shows Dialog with the suggested "produkt", AND call onSeccessHandler
  static void showMyDialog(
      {@required BuildContext context,
      @required String dialogMsg,
      Widget dialogBody,
      dynamic onYesCallback,
      dynamic onNoCallback}) async {
    //https://kodestat.gitbook.io/flutter/35-flutter-simpledialog

    Widget dialogOptions = Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        SimpleDialogOption(
          child: RaisedButton(
            child: Text('Ja'),
            onPressed: () {
              Navigator.of(context).pop(1);
            },
          ),
        ),
        SimpleDialogOption(
          child: RaisedButton(
            child: Text('Nei'),
            onPressed: () {
              Navigator.of(context).pop(0);
            },
          ),
        ),
      ],
    );

    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            // shape: RoundedRectangleBorder(
            // borderRadius: BorderRadius.all(Radius.circular(32.0))),
            // borderRadius: BorderRadius.only(topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0))),
            title: Center(child: Text(dialogMsg)),
            children: <Widget>[dialogBody ?? Container(), dialogOptions],
          );
        })) {
      case 1:
        {
          onYesCallback != null ? onYesCallback() : null;
        }
        break;
      case 0:
        onNoCallback != null ? onNoCallback() : null;
        break;
      default:
        break;
    }
  }

  static Future selectDate({dynamic onPicked, BuildContext context}) async {
    // BUG IN FLUTTER Sometimes showDatePicker A RenderFlex overflowed by some pixels on the bottom
    // You can modify the flutter file "date_picker.dart" by wrapping _DatePickerDialog with "SingleChildScrollView"
    // Like in the example:
    //   Widget child = SingleChildScrollView(
    //       child: _DatePickerDialog( ...
    // But of course this solution will be overwritten after flutter update/upgrade
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now().add(Duration(days: 3650)),
        selectableDayPredicate: (DateTime val) => val.isBefore(DateTime.now()));

    if (picked != null && onPicked != null) onPicked(picked);
  }

  ///********************************BottomSheet****************************************** */
  ///************************************************************************************ */

  //Show a bottomSheet to scan a barcode AND shows Dialog with the suggested "produkt"
  static void showBottomSheet({
    @required BuildContext context,
    @required GlobalKey<ScaffoldState> scaffoldKey,
    @required Widget childWidget,
    @required onWhenComplete,
  }) {
    FocusScope.of(context)
        .requestFocus(new FocusNode()); // To remoive the keyboard

    PersistentBottomSheetController controller =
        scaffoldKey.currentState.showBottomSheet((context) {
      return childWidget;
    });

    controller.closed.whenComplete(() {
      if (onWhenComplete != null) onWhenComplete();
      print(
          "============================ whenComplete ============================");
    });
  }
}
