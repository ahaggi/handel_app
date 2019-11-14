import 'package:flutter/material.dart';
import 'package:handle_app/db/dbQry.dart';
import 'package:handle_app/tree/handle/handelList/subWidgets/handelWidget.dart';
import 'package:handle_app/db/db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handle_app/config/attrconfig.dart';
import 'package:handle_app/config/attrconfig_db.dart';

class HandleListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget getList(List<DocumentSnapshot> documents) {

      // Qry.filterProdukt(qry: (docSnapshot)=> docSnapshot.data[NAVN].toString().toLowerCase().contains("cashew") ).listen((docSnapshot){
      //   print(docSnapshot.documentID);
      // });

      // Qry.filterVarerForGivenCondition(
      //   qryForOuterAttr: (handelDocSnapshot) => true,
      //   qryForVarer: (vare) => vare[PRODUKT_ID].toString().toLowerCase().contains("7033250103972"),
      // ).listen((data) => print(data ));

      // Qry.filterHandelForGivenCondition(
      //         qry: (docSnapshot) => docSnapshot.data[BUTIKK]?.toString()?.toLowerCase().contains("extra")   )
      //     .listen((docSnapshot) => print("${docSnapshot.data[BUTIKK]} +   ${docSnapshot.data[DATO]}"));

      DataDB.backupAll(colPath: HANDEL_PATH);

      // DataDB.getChartData(
      //         groupBy_: GroupBy.MONTH,
      //         chartDataType: ChartDataType.NUTRITIONAL_CONTENT,
      //         foldingby: FoldingBy.SCAN)
      //     .listen((map) => //
      //         Util.printChartDataAsProdukterSortedBy(
      //             inputMap: map, compareBy: "Kostnad", take: 10));
      // DataDB.getChartData(groupBy_: GroupBy.MONTH, chartDataType: ChartDataType.NUTRITIONAL_CONTENT).listen(print);
      // DataDB.getChartData(groupBy_: GroupBy.MONTH, chartDataType: ChartDataType.NUMBER_OF_GOODS).listen(print);
      // DataDB.getChartData(groupBy_: GroupBy.WEEK,  chartDataType: ChartDataType.NUTRITIONAL_CONTENT).listen(print);
      // DataDB.getChartData(groupBy_: GroupBy.WEEK,  chartDataType: ChartDataType.NUMBER_OF_GOODS).listen(print);
      // DataDB.getChartData(groupBy_: GroupBy.SHOP,  chartDataType: ChartDataType.NUTRITIONAL_CONTENT).listen(print);
      // DataDB.getChartData(groupBy_: GroupBy.SHOP,  chartDataType: ChartDataType.NUMBER_OF_GOODS).listen(print);
      return ListView.builder(
        // padding: new EdgeInsets.all(10.0),
        // controller: _scrollController,
        itemCount: documents.length,
        itemBuilder: (_, int index) {
          return HandelWidget(
            handelDocSnapshot: documents[index],
            onDelete: DataDB.deleteHandelDocument,
          );
        },
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Handle'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: DataDB.getStreamHandleCollectionSnapshot(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Container(margin: const EdgeInsets.only(top: 60.0), child: Text('Loading...'));
            print("nr of handel docs: " + snapshot.data.documents.length.toString());
            return getList(snapshot.data.documents);
          },
        ));
  }
}
