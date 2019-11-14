import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:handle_app/db/db.dart';
import 'package:handle_app/tree/product/produktList/subWidgets/produktWidget.dart';



class ProduktlistWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    /// recv a [List<DocumentSnaphsot>] and return  a [List<ProductWidget>]
    Widget getList(List<DocumentSnapshot> documents) => ListView.builder(
          itemCount: documents.length,
          itemBuilder: (_, int index) {
            return ProduktWidget(produktDocSnapshot: documents[index], onDelete: DataDB.deleteProduktDocument,);
          },
        );



    return Scaffold(
        appBar: AppBar(
          title: Text('Produktliste'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: DataDB.getStreamProduktCollectionSnapshot(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Container(
                  margin: const EdgeInsets.only(top: 60.0),
                  child: Text('Loading...'));

            print("nr of produkt docs: " +
                snapshot.data.documents.length.toString());
            return getList(snapshot.data.documents);
          },
        ));
  }
}