import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:handle_app/tree/product/produktList/subWidgets/produktCardWidget.dart';
import 'package:handle_app/tree/product/productForm/addProduktWidget.dart';
import 'package:handle_app/tree/todo/utilWidget/utilUI.dart';
import 'package:handle_app/config/attrconfig.dart';

class ProduktWidget extends StatelessWidget {

  ProduktWidget({@required this.produktDocSnapshot,this.onDelete});
  final DocumentSnapshot produktDocSnapshot;
  final dynamic onDelete;

  @override
  Widget build(BuildContext context) {
    // Future<File> _loadImage({String fileName}) async {
    //   final File tempFile = await StorageDB.getImage(fileName);
    //   return tempFile;
    // }

    // Widget _getImageHandler({int strekkode, String navn}) {
    //   String fileName = strekkode != null ? strekkode.toString() : navn;
    //   return FutureBuilder(
    //     future: _loadImage(fileName: "$fileName.jpg"),
    //     builder: (BuildContext context, AsyncSnapshot<File> file) {
    //       if (file.hasData)
    //         return Image.file(
    //           file.data,
    //           fit: BoxFit.cover,
    //         );
    //       else
    //         return Image.asset(
    //           "resources/images/Capture.png",
    //               fit: BoxFit.cover,
    //         );
    //     },
    //   );
    // }

    void editProduktHandler() async {
      Map result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddNewProduktWidget(
                  docSnapshotToEdit: produktDocSnapshot,
                )),
      );

      print(result);
    }

    ///********************************showDialog****************************************** */
    void _showMyDialog(dynamic _onYesCallback) async {
      String _dialogMsg =
          'Er du sikker på at du vil slette ${produktDocSnapshot.data[NAVN]}?';
      UtilUI.showMyDialog(
          context: context,
          dialogMsg: _dialogMsg,
          dialogBody: Container(),
          onYesCallback: _onYesCallback);
    }

    void deleteProduktHandler() async {
      dynamic _onYesCallback = () async =>
          await this.onDelete(docSnapshot: produktDocSnapshot);
      _showMyDialog(_onYesCallback);
    }

    return ProduktCardWidget(
      produkt: produktDocSnapshot.data,
      //getImageFromFirebaseStorageCallback: _getImageHandler,
      onEdit: editProduktHandler,
      onDelete: deleteProduktHandler,
    );
  }
}
