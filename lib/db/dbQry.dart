import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'package:rxdart/rxdart.dart';
import 'package:handle_app/db/db.dart';
import 'package:handle_app/config/attrconfig.dart';
import 'package:handle_app/config/attrconfig_db.dart';

class Qry {
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

  /// returns a "produkt" `Future<DocumentSnapshot>` or `null` for the given documentID.
  ///
  /// If no [DocumentSnapshot] exists or its [DocumentSnapshot.data.isEmpty], this will return null.
  static Future<dynamic> getProduktSnapshotAsFuture(
      {String vareProduktId}) async {
    var produktDocSnapshot =
        await DataDB.getProduktCollection().document(vareProduktId).get();
    Map<String, dynamic> _data = produktDocSnapshot?.data;

    if (_data != null &&
        !_data.isEmpty &&
        produktDocSnapshot.documentID == vareProduktId) {
      return produktDocSnapshot;
    } else {
      return null;
    }
  }

  /// returns a "folded Map" `Observable< Map<String,dynamic> >` that contains
  ///          {produktID: String  , Karbohydrater: num , Fett: num, Protein: num, Kostnad: num , Kalorier:num }
  /// accept a "vare" `Observable<dynamic>` and "produkter" `Map<String,dynamic>`
  ///          obsVare$ Observable<  Map<String, dynamic> >
  ///          memoProdukter {String: prodDocSnapshot.data}
  static Observable<dynamic> _produceChartDataForEachVare(
      {@required Observable obsVare$,
      @required Map<String, dynamic> memoProdukter}) {
    // Observable <Map<String,dynamic>>  {produktID: String  , Karbohydrater: num , Fett: num, Protein: num, Kostnad: num , Kalorier:num , kostnad: num}

    var obs$ = obsVare$.concatMap((vareSnapshot) {
      var obsOneProdukt$;

      var vareProduktId = vareSnapshot[PRODUKT_ID].toString();

      if (memoProdukter[vareProduktId] == null) {
        var prodSnapshotAsFuture =
            getProduktSnapshotAsFuture(vareProduktId: vareProduktId);
        obsOneProdukt$ =
            Observable.fromFuture(prodSnapshotAsFuture).where((prodDataMap) {
          if (prodDataMap == null) //
            print("prodDataMap == null");
          return (prodDataMap != null &&
              prodDataMap.data[ER_MATVARE] != null &&
              prodDataMap[ER_MATVARE]);
        }).map((prodDocSnapshot) {
          // add the "vare" to memoProdukter
          memoProdukter[vareProduktId] = prodDocSnapshot.data;
          return prodDocSnapshot.data;
        });
      } else {
        obsOneProdukt$ = Observable<dynamic>.just(memoProdukter[vareProduktId]);
      }

      return obsOneProdukt$.map((prodDataMap) {
        var data = Map<String, dynamic>();
        var nettovekt = prodDataMap[NETTOVEKT];
        var mengde = vareSnapshot[MENGDE];
        var kostnad = vareSnapshot[TOTALPRIS];

        var energiPerGram = (prodDataMap[INFO][NAERINGSINNHOLD][ENERGI] / 100);

        var kalorierPerGram =
            (prodDataMap[INFO][NAERINGSINNHOLD][KALORIER] / 100);

        var karbohydraterPerGram =
            (prodDataMap[INFO][NAERINGSINNHOLD][KARBOHYDRATER] / 100);
        var fettPerGram = (prodDataMap[INFO][NAERINGSINNHOLD][FETT] / 100);
        var proteinPerGram =
            (prodDataMap[INFO][NAERINGSINNHOLD][PROTEIN] / 100);

        data[PRODUKT_ID] = vareProduktId;

        data[ENERGI] = mengde * (nettovekt * 1000) * energiPerGram;
        data[KALORIER] = mengde * (nettovekt * 1000) * kalorierPerGram;
        data[KARBOHYDRATER] =
            mengde * (nettovekt * 1000) * karbohydraterPerGram;
        data[FETT] = mengde * (nettovekt * 1000) * fettPerGram;
        data[PROTEIN] = mengde * (nettovekt * 1000) * proteinPerGram;
        data[KOSTNAD] = kostnad;
        data[MENGDE] = mengde;

        return data;
      });
    }); //concatMap
    return obs$;
  }

  /// returns a "folded Map" `Map<String,dynamic>` that contains
  ///         {produkter:Map<String,dynamic>  , Karbohydrater: num , Fett: num, Protein: num, Kostnad: num , Kalorier:num }
  /// accept an accumulator `Map<String,dynamic>` and new item `Map<String,dynamic>` .
  ///         accumulator {produkter: Map<String,dynamic>  , Karbohydrater: num , Fett: num, Protein: num, Kostnad: num , Kalorier:num }
  ///         next item {produktID: String  , Karbohydrater: num , Fett: num, Protein: num, Kostnad: num , Kalorier:num , kostnad: num}
  static Map<String, dynamic> foldingFunction(accMap, _data) {
    Map<String, dynamic> produkterMap = (accMap["produkter"]) ?? {};

    produkterMap.update(
        _data[PRODUKT_ID],
        (oldValue) => {
              KARBOHYDRATER: oldValue[KARBOHYDRATER] + _data[KARBOHYDRATER],
              FETT: oldValue[FETT] + _data[FETT],
              PROTEIN: oldValue[PROTEIN] + _data[PROTEIN],
              KALORIER: oldValue[KALORIER] + _data[KALORIER],
              KOSTNAD: oldValue[KOSTNAD] + _data[KOSTNAD],
              MENGDE: oldValue[MENGDE] + _data[MENGDE]
            },
        ifAbsent: () => {KARBOHYDRATER: _data[KARBOHYDRATER], FETT: _data[FETT],PROTEIN: _data[PROTEIN], KALORIER: _data[KALORIER],KOSTNAD: _data[KOSTNAD], MENGDE: _data[MENGDE]});
    accMap["produkter"] = produkterMap;

    accMap.update(KARBOHYDRATER, (oldValue) => oldValue + _data[KARBOHYDRATER],
        ifAbsent: () => _data[KARBOHYDRATER]);
    accMap.update(FETT, (oldValue) => oldValue + _data[FETT],
        ifAbsent: () => _data[FETT]);
    accMap.update(PROTEIN, (oldValue) => oldValue + _data[PROTEIN],
        ifAbsent: () => _data[PROTEIN]);
    accMap.update(KALORIER, (oldValue) => oldValue + _data[KALORIER],
        ifAbsent: () => _data[KALORIER]);
    accMap.update(KOSTNAD, (oldValue) => oldValue + _data[KOSTNAD],
        ifAbsent: () => _data[KOSTNAD]);
    return accMap;
  }


  /// returns a  `Observable < Map<String,dynamic> >` that contains
  ///         {id: String, maaOppdaters:bool , produkter:Map<String,dynamic>  , Karbohydrater: num , Fett: num, Protein: num, Kostnad: num , Kalorier:num }

  static Observable<dynamic> produceChartDataAll({@required groupBy}) {
    var obsvHandle$ = // Stream of <Map handel>
        DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
            .expand((docSnapshotList) => docSnapshotList)
            .map((docSnapshot) => docSnapshot.data);

    var memoProdukter = Map<String, dynamic>();

    // refactore!
    var handelGroupedAsList$ = // Stream of <GroupByObservable<dynamic, Observable>>  i.e  GroupByObservable<group.key , Stream of [handel]>
        obsvHandle$.groupBy((handelDataMap) {
      var _handelDato = DateTime.parse(handelDataMap[DATO].toString());

      if (groupBy == GroupBy.MONTH) {
        String prefix = "${_handelDato.month > 9 ? '' : '0'}";

        return "mnd-${_handelDato.year}-$prefix${_handelDato.month}";
      } else {
        //if (groupBy == GroupBy.WEEK)
        var res = Util.getWeekNumber(_handelDato);
        var weekNr = res[0];
        var year = res[1];
        String prefix = "${weekNr > 9 ? '' : '0'}";

        return "uke-$year-$prefix$weekNr";
      } //
    });

    var obsData$ = // GroupByObservable<handelDataMap, key> groupByObservable
        handelGroupedAsList$.flatMap((handelGroupedBykey) {
      // each event is "groupByObservable" that contains items which is grouped by some key

      var obsVarer$ = // Stream of <vare>
          handelGroupedBykey.map((handelDataMap) {
        if (handelGroupedBykey.key == null)
          print(
              "**Err****Err****Err****Err**\n$handelDataMap\n**Err****Err****Err****Err**\n");

        return handelDataMap[VARER];
      }).expand((vare) => vare);

      var obsChartDateExpanded$ = // Observable <Map<String,dynamic>>  {"produktID": String , Karbohydrater: num , Fett: num, Protein: num, Kostnad: num , Kalorier:num }
          _produceChartDataForEachVare(
        obsVare$: obsVarer$,
        memoProdukter: memoProdukter,
      );

      var obsCharDataFolded$ = obsChartDateExpanded$
          .fold(
              //
              Map<String, dynamic>(),
              (accMap, _data) => foldingFunction(accMap, _data))
          .asObservable();

      return obsCharDataFolded$.map((data) {

        data.putIfAbsent("id", () => handelGroupedBykey.key);
        data.putIfAbsent("maaOppdaters", () => false);
        return data;
      });
    });

    return obsData$;
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

      return {
        "handelInfo": handelInfo,
        "varerObsv": Observable.just(docSnapshot.data[VARER])
      };
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
    var obsHandel$ =
        DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
            .expand((list) => list);

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

    var wrappedHandel$ =
        DataDB.getCollectionSnapshotAsObservable(colPATH: HANDEL_PATH)
            .expand((docSnapshotList) => docSnapshotList)
            .map((docSnapshot) => docSnapshot)
            .map((docSnapshot) {
      return {
        "docSnapshot": docSnapshot,
        "varerObsv": Observable.just(docSnapshot.data[VARER])
      };
    });

    Observable<DocumentSnapshot> obs =
        wrappedHandel$.flatMap((wrappedSnapshotHandel) {
      // bool needToUpdate = false;

      Observable varerObsv = wrappedSnapshotHandel["varerObsv"];

      var isVareUpdated$ = varerObsv.expand((varer) => varer) //
          .concatMap((vare) {
        return DataDB.getCollectionSnapshotAsObservable(colPATH: PRODUKT_PATH)
            .expand((prodSnapshotList) => prodSnapshotList)
            .map((prodSnapshot) {
              if (vare[NAVN] == prodSnapshot.data[NAVN] &&
                  vare[PRODUKT_ID] != prodSnapshot.documentID) {
                DocumentSnapshot handelSnapshot =
                    wrappedSnapshotHandel["docSnapshot"];
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
      print(
          "  &&&&                                     ${docSnapshot.documentID}");
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
          print(
              ' navn: ${docSnapshot.data[NAVN]},  nettovekt: ${docSnapshot.data[NETTOVEKT]} ');
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
      int ukeNr = Util.getWeekNumber(dato)[0];
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

    docSnapshot.reference.updateData(
        {newFieldName: val, oldFieldName: FieldValue.delete()}).then((v) {});
  }
}

enum GroupBy { MONTH, WEEK }
enum ChartDataType { NUMBER_OF_GOODS, NUTRITIONAL_CONTENT }
enum FoldingBy { FOLD, SCAN }
