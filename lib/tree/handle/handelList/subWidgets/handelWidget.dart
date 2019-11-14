import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:handle_app/tree/todo/utilWidget/utilUI.dart';

import 'package:handle_app/tree/handle/handelList/subWidgets/handelCardWidget.dart';
import 'package:handle_app/config/attrconfig.dart';

class HandelWidget extends StatelessWidget {
  HandelWidget({this.handelDocSnapshot, this.onDelete});
  final DocumentSnapshot handelDocSnapshot;
  final dynamic onDelete;

  @override
  Widget build(BuildContext context) {
    void edithandelHandler() async {
      // Map result = await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => AddnewHandle_PageViewer(

      //           )),
      // );

      // print(result);
      print("onEdit handler!!! ${handelDocSnapshot.documentID}");
    }

    ///********************************showDialog****************************************** */
    void _showMyDialog(dynamic _onYesCallback) async {
      String _butikk = handelDocSnapshot.data[BUTIKK];
      String _dato = handelDocSnapshot.data[DATO];
      String _dialogMsg = 'Er du sikker på at du vil slette kjøpe fra $_butikk på den $_dato ?';
      UtilUI.showMyDialog(
          context: context,
          dialogMsg: _dialogMsg,
          dialogBody: Container(),
          onYesCallback: _onYesCallback);
    }

    void deletehandelHandler() async {
      dynamic _onYesCallback = () async => await this.onDelete(docSnapshot: handelDocSnapshot);
// print("onDelete handler!!! ${handelDocSnapshot.documentID}");
      _showMyDialog(_onYesCallback);
    }

    return HandelCardWidget(
      handel: handelDocSnapshot.data,
      onEdit: edithandelHandler,
      onDelete: deletehandelHandler,
    );
  }
}
