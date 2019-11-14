

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:handle_app/db/db.dart';
import 'package:handle_app/config/attrconfig.dart';
import 'package:handle_app/config/attrconfig_db.dart';

class Qry{
  // // /**
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  */


  static Observable<dynamic> _produceChartDataForEachVare(
      {@required Observable obsVare$, @required ChartDataType chartDataType}) {
    var obs$ = obsVare$.concatMap((vareSnapshot) {
      var obsOneProdukt$ = DataDB.getCollectionSnapshotAsObservable(colPATH: PRODUKT_PATH)
          .expand((prodDocSnapshotList) => prodDocSnapshotList)
          .map((prodDocSnapshot) => prodDocSnapshot)
          //OBS "firstWhere" does NOT filter events as "where", and it has to return (elem or err)
          .firstWhere(
              //Stops listening to this stream after the first matching element or error has been received.
              (prodDocSnapshot) {
            return (vareSnapshot[PRODUKT_ID].toString() == prodDocSnapshot.documentID);
          }, orElse: () {
            // This is to avoid throwing an exception
            print(vareSnapshot[PRODUKT_ID].toString());
            return null;
          })
          .asObservable()
          .where(// checks whether firstWhere found matching "produkt" and its ER_MATVARE
              (prodDataMap) {
            if (prodDataMap == null) //
              print("prodDataMap == null");
            return (prodDataMap != null &&
                prodDataMap.data[ER_MATVARE] != null &&
                prodDataMap[ER_MATVARE]);
          })
          .map((prodDocSnapshot) => prodDocSnapshot.data);

      if (chartDataType == ChartDataType.NUTRITIONAL_CONTENT) {
        return obsOneProdukt$.map((prodDataMap) {
          var data = Map<String, dynamic>();
          var nettovekt = prodDataMap[NETTOVEKT];
          var mengde = vareSnapshot[MENGDE];
          var pris = vareSnapshot[TOTALPRIS];

          var andelEnergi = (prodDataMap[INFO][NAERINGSINNHOLD][ENERGI] / 100);

          var andelKalorier = (prodDataMap[INFO][NAERINGSINNHOLD][KALORIER] / 100);

          var andelKarbohydrater = (prodDataMap[INFO][NAERINGSINNHOLD][KARBOHYDRATER] / 100);
          var andelFett = (prodDataMap[INFO][NAERINGSINNHOLD][FETT] / 100);
          var andelProtein = (prodDataMap[INFO][NAERINGSINNHOLD][PROTEIN] / 100);

          data["produkt"] = prodDataMap[NAVN];

          data[ENERGI] = mengde * (nettovekt * 1000) * andelEnergi;
          data[KALORIER] = mengde * (nettovekt * 1000) * andelKalorier;
          data[KARBOHYDRATER] = mengde * (nettovekt * 1000) * andelKarbohydrater;
          data[FETT] = mengde * (nettovekt * 1000) * andelFett;
          data[PROTEIN] = mengde * (nettovekt * 1000) * andelProtein;
          data["Kostnad"] = pris;

          return data;
        });
      } else {
        return obsOneProdukt$.map((prodDataMap) {
          return 1;
        });
      } // else
    }); //concatMap
    return obs$;
  }

  static Observable<dynamic> getChartData(
      {month_todo,
      year_todo,
      @required groupBy_,
      @required ChartDataType chartDataType,
      FoldingBy foldingby: FoldingBy.FOLD}) {
    var obsvHandle$ = // Stream of <Map handel>
        DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
            .expand((docSnapshotList) => docSnapshotList)
            .map((docSnapshot) => docSnapshot.data)
            .where((handelDataMap) {
      var _dato = DateTime.parse(handelDataMap[DATO].toString());
      var _month = _dato.month;
      var _year = _dato.year;
      return (_year == 2019); 
    });

    var handelGroupedAsList$ = // Stream of <GroupByObservable<dynamic, Observable>>  i.e  GroupByObservable<group.key , Stream of [handel]>
        obsvHandle$.groupBy((handelDataMap) {
      if (groupBy_ == GroupBy.MONTH)
        return DateTime.parse(handelDataMap[DATO].toString()).month;
      else if (groupBy_ == GroupBy.WEEK)
        return handelDataMap[UKE_NR];
      else
        return handelDataMap[BUTIKK];
    });

    var obsData$ = // GroupByObservable<handelDataMap, key> groupByObservable
        handelGroupedAsList$.flatMap((handelGroupedBykey) {
      // each event is "groupByObservable" that contains all the items with the same key

      var obsVarer$ = // Stream of <vare>
          handelGroupedBykey.map((handelDataMap) {
        if (handelGroupedBykey.key == null)
          print("**Err****Err****Err****Err**\n$handelDataMap**Err****Err****Err****Err**\n");

        return handelDataMap[VARER];
      }).expand((vare) => vare);

      var obsChartDateExpanded$ =
          _produceChartDataForEachVare(obsVare$: obsVarer$, chartDataType: chartDataType);

      var obsCharDataFolded$;
      if (chartDataType == ChartDataType.NUTRITIONAL_CONTENT) {
        switch (foldingby) {
          case FoldingBy.FOLD:
            obsCharDataFolded$ = obsChartDateExpanded$
                .fold(
                    //
                    Map<String, dynamic>(),
                    (accMap, _data) => foldingFunction(accMap, _data))
                .asObservable();
            break;
          case FoldingBy.SCAN:
            obsCharDataFolded$ = obsChartDateExpanded$ //
                .scan(
                    //
                    (accMap, _data, i) => foldingFunction(accMap, _data),
                    Map<String, dynamic>());

            break;
          default:
        }
      } else {
        obsCharDataFolded$ = obsChartDateExpanded$.fold(0, (acc, nr) {
          return acc + nr;
        }).asObservable();
      }
      return obsCharDataFolded$.map((data) => {"key": handelGroupedBykey.key, "data": data});
    });
    return obsData$;
  }

  static Map<String, dynamic> foldingFunction(accMap, _data) {
    // 2  {Karbohydrater: 7241.405000000002, Fett: 2605.313, Protein: 3409.118, Kostnad: 1609.85 ,
    //      produkter:{...}}

    Map<String, dynamic> produkterMap = (accMap["produkter"]) ?? {};

    produkterMap.update(_data["produkt"], (oldMap) {
      oldMap[KARBOHYDRATER] = (oldMap[KARBOHYDRATER] ?? 0) + _data[KARBOHYDRATER];
      return oldMap;
    }, ifAbsent: () => {KARBOHYDRATER: _data[KARBOHYDRATER]});

    produkterMap.update(_data["produkt"], (oldMap) {
      oldMap[FETT] = (oldMap[FETT] ?? 0) + _data[FETT];
      return oldMap;
    }, ifAbsent: () => {FETT: _data[FETT]});

    produkterMap.update(_data["produkt"], (oldMap) {
      oldMap[PROTEIN] = (oldMap[PROTEIN] ?? 0) + _data[PROTEIN];
      return oldMap;
    }, ifAbsent: () => {PROTEIN: _data[PROTEIN]});

    produkterMap.update(_data["produkt"], (oldMap) {
      oldMap["Kostnad"] = (oldMap["Kostnad"] ?? 0) + _data["Kostnad"];
      return oldMap;
    }, ifAbsent: () => {"Kostnad": _data["Kostnad"]});

    accMap["produkter"] = produkterMap;

    accMap.update(KARBOHYDRATER, (oldValue) => oldValue + _data[KARBOHYDRATER],
        ifAbsent: () => _data[KARBOHYDRATER]);
    accMap.update(FETT, (oldValue) => oldValue + _data[FETT], ifAbsent: () => _data[FETT]);
    accMap.update(PROTEIN, (oldValue) => oldValue + _data[PROTEIN], ifAbsent: () => _data[PROTEIN]);
    accMap.update("Kostnad", (oldValue) => oldValue + _data["Kostnad"],
        ifAbsent: () => _data["Kostnad"]);
    accMap.update("Kostnad", (oldValue) => oldValue + _data["Kostnad"],
        ifAbsent: () => _data["Kostnad"]);
    return accMap;
  }

// // /**
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  */

/*
  Qry.filterProdukt(qry: (docSnapshot)=> docSnapshot.data[NAVN].toString().toLowerCase().contains("munn") ).listen((docSnapshot)=>print(docSnapshot.documentID));
  Qry.filterProdukt(qry:  (docSnapshot)=> (docSnapshot.data["erLoesvekt"] == true && docSnapshot.data[ER_MATVARE] == true)).listen((docSnapshot)=>print(docSnapshot.data));
*/
  static Observable<dynamic> filterProdukt({dynamic qry}) {
    return DataDB.getCollectionSnapshotAsObservable(colPATH: PRODUKT_PATH)
        .expand((docSnapshotList) => docSnapshotList)
        .map((docSnapshot) => docSnapshot)
        .where(qry);
  }

//  Qry.filterVarerForGivenCondition(
//   qryForOuterAttr: (handelDocSnapshot) => handelDocSnapshot.data[BUTIKK]?.toString()?.toLowerCase() == "rema",
//   qryForVarer: (vare) => vare[NAVN].toString().toLowerCase().contains("snus"),
//   ).listen((vare)=> print(vare));

//  Qry.filterVarerForGivenCondition(
//   qryForOuterAttr: (handelDocSnapshot) => true,
//   qryForVarer: (vare) => vare[NAVN].toString().toLowerCase().contains("snus"),
//   ).listen((vare)=> print(vare));

//  Qry.filterVarerForGivenCondition(
//   qryForOuterAttr: (handelDocSnapshot) => (handelDocSnapshot.data[BUTIKK]??"").toString().toLowerCase().contains("bunn"),
//   qryForVarer: (vare) => vare[NAVN].toString().toLowerCase().contains("snus"),
//   ).fold(0, (acc , _)=> acc+1).asObservable().listen(print);

  static Observable<dynamic> filterVarerForGivenCondition(
      {dynamic qryForOuterAttr, dynamic qryForVarer}) {
    ///
    /// How can we get "handel-documentID" of the result?
    ///

    //   return getCollectionSnapshotAsObservable(colPATH: _handelPATH)
    //       .expand((docSnapshotList) => docSnapshotList)
    //       .where(qryForOuterAttr)
    //       .map((docSnapshot) => docSnapshot.data[VARER])
    //       .expand((varer) => varer)
    //       .where(qryForVarer);

    /// qryForOuterAttr: initial filtering, that is based on fields which not a list (NOT the VARER field) i.e. BUTIKK, DATO ... 
    /// qryForVarer: filtering based on the value of each elem in the list (VARER field)
    return DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
        .expand((docSnapshotList) => docSnapshotList)
        .where(qryForOuterAttr)

        /// Hear we could use groupBy,, but actualy we don't need to group the data, what needed is more info about the filtered "vare",
        /// like what the BUTIKK, "documentID" or DATO for the filtered "vare" is.
        /// a solution can be by wrapping the needed info in a Map and adding an observable of (VARER list) to that map.
        .map((docSnapshot) {
      Map<String, dynamic> handelInfo = {
        "documentID": docSnapshot.documentID,
        BUTIKK: docSnapshot.data[BUTIKK],
        DATO: docSnapshot.data[DATO],
        SUMMEN: docSnapshot.data[SUMMEN],
      };

      return {"handelInfo": handelInfo, "varerObsv": Observable.just(docSnapshot.data[VARER])};
    }).flatMap((wrappedData) {
      Observable varerObsv = wrappedData["varerObsv"];
      return varerObsv
          .expand((varer) => varer) //
          .where(qryForVarer) //
          .map((vare) => {
                "handelInfo": wrappedData["handelInfo"],
                "vare": vare,
              });
    });

    
  }

// Qry.filterHandelForGivenCondition(qry: (docSnapshot) => docSnapshot.data[BUTIKK]?.toString()?.toLowerCase() == "rema").listen((docSnapshot)=>print(docSnapshot.data));
// Qry.filterHandelForGivenCondition(qry: (docSnapshot) =>  ( DateTime.parse(docSnapshot.data[DATO]).isAfter(DateTime.parse("2019-03-10"))   && docSnapshot.data[SUMMEN] != ( (docSnapshot.data[KONTANT]??0) + (docSnapshot.data[BANKKORT]??0) ))).listen((docSnapshot)=>print(docSnapshot.data));
  static Observable<dynamic> filterHandelForGivenCondition({dynamic qry}) {
    return DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
        .expand((docSnapshotList) => docSnapshotList)
        .where(qry)
        .map((docSnapshot) => docSnapshot);
  }

  static void getAvgVarerLength() {
    var ob$ = DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
        .groupBy((docSnapshotList) => docSnapshotList.length)
        .flatMap((grouped) {
      return grouped
          .expand((docSnapshotList) => docSnapshotList)
          .map((docSnapshot) => docSnapshot.data[VARER].length)
          .fold(0, (acc, len) => acc + len)
          .asObservable()
          .map((val) => val / grouped.key);
    });

    ob$.listen((val) => print('value is  ###################### $val'));
    //  I/flutter (13055):        value is  ###################### 3.01       This is the avg nr of "produkt/vare" per "handel"
    //     produkt docs: 232
    //     handel docs:  265
    //     8fvqwGgaKFo8nzLPybC5
  }

// // /**
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  *
// //  */

  static void addBrgnNaeringToVarer() {
    var obsHandel$ = DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH).expand((list) => list);

    var obs$ = obsHandel$.concatMap((handelSnapShot) {
      List varer = handelSnapShot[VARER];

      return DataDB.getCollectionSnapshotAsObservable(colPATH: PRODUKT_PATH)
          .expand((prodSnapshotList) => prodSnapshotList)
          .map((prodSnapshot) => prodSnapshot)
          .fold(true, (a, prodSnapshot) {
            varer.forEach((v) {
              if (v[PRODUKT_ID] == prodSnapshot.documentID)
                v[BRGN_NAERING] = prodSnapshot.data[ER_MATVARE];
            });
            return a;
          })
          .asObservable()
          .map((v) => handelSnapShot);
    });
    obs$.listen((handelSnapShot) {
      // _updateDocument(docSnapshot: handelSnapShot, data: handelSnapShot.data).then((p) {});
    });
  }

  static void varerWithwrongProduktID() {
    Stopwatch perf = new Stopwatch();
    perf.start();

    var wrappedHandel$ = DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
        .expand((docSnapshotList) => docSnapshotList)
        .map((docSnapshot) => docSnapshot)
        .map((docSnapshot) {
      return {"docSnapshot": docSnapshot, "varerObsv": Observable.just(docSnapshot.data[VARER])};
    });

    Observable<DocumentSnapshot> obs = wrappedHandel$.flatMap((wrappedSnapshotHandel) {
      // bool needToUpdate = false;

      Observable varerObsv = wrappedSnapshotHandel["varerObsv"];

      var isVareUpdated$ = varerObsv.expand((varer) => varer) //
          .concatMap((vare) {
        return DataDB.getCollectionSnapshotAsObservable(colPATH: PRODUKT_PATH)
            .expand((prodSnapshotList) => prodSnapshotList)
            .map((prodSnapshot) {
              if (vare[NAVN] == prodSnapshot.data[NAVN] &&
                  vare[PRODUKT_ID] != prodSnapshot.documentID) {
                DocumentSnapshot handelSnapshot = wrappedSnapshotHandel["docSnapshot"];
                print(
                    " handel_documentID ${handelSnapshot.documentID} vare ${vare[NAVN]} : \n\t oldValue: ${vare[PRODUKT_ID]}\n\t newValue: ${prodSnapshot.documentID}");
                vare[PRODUKT_ID] = prodSnapshot.documentID;
                return true;
              } else
                return false;
            })
            .fold(false, (acc, isVareUpdated) => acc || isVareUpdated)
            .asObservable();
      });

      var needToUpdateHandelSnapshot$ = isVareUpdated$
          .fold(false, (acc, isAnyVareUpdated) => acc || isAnyVareUpdated)
          .asObservable();

      return needToUpdateHandelSnapshot$ //
          .where((needToUpdate) => needToUpdate)
          .map((_bool) => wrappedSnapshotHandel["docSnapshot"]);
    });

    obs.listen((docSnapshot) {
      print("  &&&&                                     ${docSnapshot.documentID}");

    }).onDone(() {
      print("The Total amount of cal. time is ${perf.elapsed.inSeconds}sec");
      perf.stop();
    });
  }

  static void updateNettovektToBeInt() {
    var ob$ = DataDB.getCollectionSnapshotAsObservable(colPATH: PRODUKT_PATH)
        .expand((docSnapshotList) => docSnapshotList)
        .map((docSnapshot) => docSnapshot);

    ob$.listen((docSnapshot) {
      if (docSnapshot.data[ER_MATVARE]) {
        var nettovekt = docSnapshot.data[NETTOVEKT];
        if (nettovekt is! num || nettovekt > 1) {
          print(' **********************************************');
          print(' produktID is ${docSnapshot.documentID} ');
          print(' navn: ${docSnapshot.data[NAVN]},  nettovekt: ${docSnapshot.data[NETTOVEKT]} ');
          print(' **********************************************');
          // var nettovektNum = Util.parseStringtoNum(docSnapshot.data[NETTOVEKT].toString());
          // docSnapshot.data[NETTOVEKT] = nettovektNum;
          // updateProduktDoc(docSnapshot.documentID, docSnapshot.data).then((v){});
        }
      }
    });
  }

  static void addWeekNrField() {

    var ob$ = DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
        .expand((docSnapshotList) => docSnapshotList)
        .map((docSnapshot) => docSnapshot)
        .where((doc) => doc[UKE_NR] == null);

    ob$.listen((docSnapshot) {
      var data = docSnapshot.data;

      var dato = DateTime.parse(docSnapshot.data[DATO]);
      int ukeNr = Util.getweekNumber(dato);
      data[UKE_NR] = ukeNr;

      print(data);
      DataDB.updateHandelDoc(docSnapshot: docSnapshot, data: data).then((p) {});
    });
  }

  static void _changeFieldName(
      {@required DocumentSnapshot docSnapshot,
      @required String oldFieldName,
      @required String newFieldName}) {
    var val = docSnapshot[oldFieldName];

    // if (val == 1)
    //   val = "1";
    // else if(val.toString().toLowerCase() == "kg" )
    //   val = "Løsvekt";

    docSnapshot.reference
        .updateData({newFieldName: val, oldFieldName: FieldValue.delete()}).then((v) {});
  }
}

enum GroupBy { MONTH, WEEK, SHOP }
enum ChartDataType { NUMBER_OF_GOODS, NUTRITIONAL_CONTENT }
enum FoldingBy { FOLD, SCAN }
