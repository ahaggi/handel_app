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
      // Qry.filterProdukt(qry: (docSnapshot)=> docSnapshot.data[ER_MATVARE] && (docSnapshot.data[NETTOVEKT] > 1) ).listen((docSnapshot){
      //   print(docSnapshot.data);
      // });
      // Qry.filterProdukt(qry: (docSnapshot)=> docSnapshot.data[NAVN].toString().contains("chilinøtter") ).listen((docSnapshot){
      //   print(docSnapshot.data);
      // });

      // Qry.filterVarerForGivenCondition(
      //   qryForOuterAttr: (handelDocSnapshot) => (handelDocSnapshot.data[BUTIKK]??"").toString().toLowerCase().contains("rema"),
      //   qryForVarer: (vare) => (vare[NAVN].toString().toLowerCase().contains("barber") ),
      // ).listen((data) => print("DATO:${data['handelInfo'][DATO]}, documentID:${data['handelInfo']['documentID']}, SUMMEN:${data['handelInfo'][SUMMEN]}, BUTIKK:${data['handelInfo'][BUTIKK]}  \n  ${data['vare']['navn']} \n  ${data['vare'][PRODUKT_ID]}\n  ${data['vare'][STREKKODE]}" ));

      // Qry.filterVarerForGivenCondition(
      //   qryForOuterAttr: (handelDocSnapshot) => (DateTime.parse(handelDocSnapshot[DATO]).month == 2 &&
      //         DateTime.parse(handelDocSnapshot[DATO]).year ==
      //             2020),
      //   qryForVarer: (vare) => vare[ER_MATVARE] == true ,
      // ).listen((data) => print("${data['handelInfo'][DATO]}  \n  ${data['vare'][TOTALPRIS]} " ));


// Qry.filterHandelForGivenCondition(qry: (docSnapshot) => (docSnapshot.data[BUTIKK]??"").toString().toLowerCase().contains("posten")  ).listen((docSnapshot)=>print(docSnapshot.data));

//   Stopwatch s = new Stopwatch();
//   s.start();

//       Qry.produceChartDataAll(
//               groupBy: GroupBy.MONTH,
//               )
//               .listen((data) { 
//                 print(data);
//               DataDB.addNewChartDataMN(docID: data["id"], data: data);
//                 print("¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤${s.elapsedMilliseconds}¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤"); // around 3000ms
// });

//   print("¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤${s.elapsedMilliseconds}¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤"); // around 3000ms

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
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Container(
                  margin: const EdgeInsets.only(top: 60.0),
                  child: Text('Loading...'));
            print("nr of handel docs: " +
                snapshot.data.documents.length.toString());
            return getList(snapshot.data.documents);
          },
        ));
  }
}
