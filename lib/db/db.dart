import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
// import 'package:oekonomi/tree/utilWidget/myCallback.dart';
import 'package:handle_app/tree/todo/utilWidget/util.dart';
import 'package:rxdart/rxdart.dart';
// import 'dart:math';
import 'package:handle_app/config/attrconfig.dart';
import 'package:handle_app/config/attrconfig_db.dart';

class DataDB {
  static CollectionReference _getCollection({String colPath}) {
    return Firestore.instance.collection(colPath);
  }

  /// returns a `Stream<QuerySnapshot>` for a given Collection
  ///
  /// [required] `colPath`
  static Stream<QuerySnapshot> _getStreamCollectionSnapshot(
      {@required String colPath, String orderBy: "", bool descending: false}) {
    return _getCollection(colPath: colPath).orderBy(orderBy, descending: descending).snapshots();
  }

  /// Returns a `DocumentReference` for the provided [docID].
  /// If no [docID] is provided, an auto-generated one is used.
  ///
  /// [required] colPath
  static DocumentReference _createNewDocument({@required String colPath, String docID}) {
    return _getCollection(colPath: colPath).document(docID);
  }

  /// Updates fields in the document referred to by this [DocumentSnapshot].
  /// If no document exists yet, the update will fail.
  ///
  /// [required] docSnapshot, data
  static Future<void> _updateDocument(
      {@required DocumentSnapshot docSnapshot, Map<String, dynamic> data}) {
    return docSnapshot.reference.updateData(data);
  }

  /// Writes to the document referred to by this [DocumentSnapshot]. If the document does not yet exist, it will be created
  ///
  /// [required] docSnapshot, data
  static Future<void> _setDocument(
      {@required DocumentSnapshot docSnapshot, @required Map<String, dynamic> data}) {
    return docSnapshot.reference.setData(data);
  }

  /// returns `DocumentSnapshot` for the given documentID.
  ///
  /// If no [DocumentSnapshot] exists or its [DocumentSnapshot.data.isEmpty], the read will return null
  static Future<DocumentSnapshot> _getDocument({String colPath, String documentID}) async {
    DocumentSnapshot docSnapshot =
        await _getCollection(colPath: colPath).document(documentID).get();
    Map<String, dynamic> _data = docSnapshot?.data;

    if (_data == null || _data.isEmpty) {
      await docSnapshot.reference.delete();
      return null;
    } else
      return docSnapshot;
  }

  /// Create a new [produkt] docRefBackup, populate it with [data] and retruns it's ID
  ///
  /// [required] `colPath`, `docID` and `data`
  static Future<String> _addNewBackupDoc(
      {@required String colPath,
      @required String docID,
      @required Map<String, dynamic> data}) async {
    DocumentReference _produktBackupDoc = _createNewDocument(colPath: colPath, docID: docID);
    await _produktBackupDoc.setData(data);
    return _produktBackupDoc.documentID;
  }

  //*********************************************************************************************** */
  //*********************************************************************************************** */

  //*************************Public methods******************* */

  /// returns a `Stream<QuerySnapshot>` for a [handel] Collection
  static Stream<QuerySnapshot> getStreamHandleCollectionSnapshot() {
    return _getStreamCollectionSnapshot(colPath: HANDEL_PATH, orderBy: TIMESTAMP, descending: true);
  }

  /// returns a `Stream<QuerySnapshot>` for a [produkt] Collection
  static Stream<QuerySnapshot> getStreamProduktCollectionSnapshot() {
    return _getStreamCollectionSnapshot(colPath: PRODUKT_PATH, orderBy: NAVN);
  }

  /// returns a `Stream<QuerySnapshot>` for a [Chart_data_mn] Collection
  static Stream<QuerySnapshot> getStreamChartDataMNCollectionSnapshot() {
    return _getStreamCollectionSnapshot(colPath: CHART_DATA_MN_PATH, orderBy: "id" , descending: true);
  }
  /// returns a `Stream<QuerySnapshot>` for a [Chart_data_wk] Collection
  static Stream<QuerySnapshot> getStreamChartDataWKCollectionSnapshot() {
    return _getStreamCollectionSnapshot(colPath: CHART_DATA_WK_PATH, orderBy: "id");
  }

  /// returns a `CollectionReference ` for a [produkt] Collection
  static CollectionReference  getProduktCollection() {
    return _getCollection(colPath: PRODUKT_PATH);
  }

  //*************************Public "PRODUKT" methods******************* */

  /// Create a new [produkt] docRef, populate it with [data] and retruns it's ID
  ///
  /// [required] `data`
  static Future<String> addNewProduktDoc({@required Map<String, dynamic> data}) async {
    data.putIfAbsent(TIMESTAMP, () => FieldValue.serverTimestamp());
    var _docID = data[STREKKODE].toString();

    DocumentReference _produktDoc = _createNewDocument(colPath: PRODUKT_PATH, docID: _docID);

    await _addNewBackupDoc(colPath: PRODUKT_PATH, docID: _produktDoc.documentID, data: data);
    await _addNewBackupDoc(colPath: PRODUKT_BACKUP_PATH, docID: _produktDoc.documentID, data: data);

    return _produktDoc.documentID;
  }

  /// Updates fields in [ProduktDoc] referred to by this [DocumentSnapshot].
  /// If no document exists yet, the update will fail.
  ///
  /// [required] `docSnapshot`, `data`

  static Future<String> updateProduktDoc(
      {@required DocumentSnapshot docSnapshot, @required Map<String, dynamic> data}) async {
    String res;
    data.putIfAbsent(TIMESTAMP, () => docSnapshot.data[TIMESTAMP] ?? FieldValue.serverTimestamp());

    try {
      await _updateDocument(docSnapshot: docSnapshot, data: data);

      // Hear we can either fetch the produktBackupDoc and update it or just use <db.collection(_produktPATHBackup).doc(some-id).set(data)>
      await _getCollection(colPath: PRODUKT_BACKUP_PATH)
          .document(docSnapshot.documentID)
          .setData(data);
      res = docSnapshot.documentID;
    } catch (e) {
      print('Err catched at updateProduktDoc: $e');
      res = null;
    }
    return res;
  }

  /// Deletes the [produktdocument] referred to by this [DocumentSnapshot].
  ///
  /// [required] `docSnapshot`
  static Future<void> deleteProduktDocument({@required DocumentSnapshot docSnapshot}) async {
    //Note that <docRef.document(documentID).delete()> returns Future<void> which does NOT throw an exception
    await _getCollection(colPath: PRODUKT_BACKUP_PATH).document(docSnapshot.documentID).delete();
    return docSnapshot.reference.delete();
  }

  //*************************Public "HANDEL" methods******************* */

  /// Create a new [handel] docRef, populate it with [data] and retruns it's ID
  ///
  /// [required] `data`
  static Future<String> addNewHandelDoc({@required Map<String, dynamic> data}) async {
    data.putIfAbsent(TIMESTAMP, () => FieldValue.serverTimestamp());

    DocumentReference _handelDoc = _createNewDocument(colPath: HANDEL_PATH);

    await _handelDoc.setData(data);
    await _addNewBackupDoc(colPath: HANDEL_BACKUP_PATH, docID: _handelDoc.documentID, data: data);

    return _handelDoc.documentID;
  }

  /// Updates fields in [HandelDoc] referred to by this [DocumentSnapshot].
  /// If no document exists yet, the update will fail.
  ///
  /// [docSnapshot] `docRef`, `data`
  static Future<String> updateHandelDoc(
      {@required DocumentSnapshot docSnapshot, @required Map<String, dynamic> data}) async {
    String res;
    data.putIfAbsent(TIMESTAMP, () => docSnapshot.data[TIMESTAMP] ?? FieldValue.serverTimestamp());
    try {
      await _updateDocument(docSnapshot: docSnapshot, data: data);

      // Hear we can either fetch the handelBackupDoc and update it or just use <db.collection(_handelPATHBackup).doc(some-id).set(data)>
      await _getCollection(colPath: HANDEL_BACKUP_PATH)
          .document(docSnapshot.documentID)
          .setData(data);
      res = docSnapshot.documentID;
    } catch (e) {
      print('Err catched at updateHandelDoc: $e');
      res = null;
    }
    return res;
  }

  /// Deletes the [handeldocument] referred to by this [DocumentSnapshot].
  ///
  /// [required] `docSnapshot`
  static Future<void> deleteHandelDocument({@required DocumentSnapshot docSnapshot}) async {
    //Note that <docRef.document(documentID).delete()> returns Future<void> which does NOT throw an exception
    await _getCollection(colPath: HANDEL_BACKUP_PATH).document(docSnapshot.documentID).delete();
    return docSnapshot.reference.delete();
  }



  //*************************Public "CHART_DATA" methods******************* */

  /// Create a new [chart_data_mn] docRef, populate it with [data] and retruns it's ID
  ///
  /// [required] `data`
  static Future<String> addNewChartDataMN({@required String docID , @required Map<dynamic, dynamic> data }) async {
    DocumentReference _chartData = _createNewDocument(colPath: CHART_DATA_MN_PATH, docID: docID);
    await _chartData.setData(data);
    return _chartData.documentID;
  }
  /// Create a new [chart_data_wk] docRef, populate it with [data] and retruns it's ID
  ///
  /// [required] `data`
  static Future<String> addNewChartDataWK({@required String docID , @required Map<dynamic, dynamic> data }) async {
    DocumentReference _chartData = _createNewDocument(colPath: CHART_DATA_WK_PATH, docID: docID);
    await _chartData.setData(data);
    return _chartData.documentID;
  }




  /// Returns `DocumentSnapshot` of a [produkt] if exists, otherwise returns `null`
  ///
  /// [required] `strekkode`
  static Future<DocumentSnapshot> getProduktBystrekkode({@required String strekkode}) async {


    num _strekkode = Util.parseStringtoNum(strekkode);
    List<DocumentSnapshot> listDocumentSnapshot;
    if (_strekkode != null) {
      Query qry = _getCollection(colPath: PRODUKT_PATH).where(STREKKODE, isEqualTo: _strekkode);
      QuerySnapshot querySnapshot = await qry.getDocuments();
      listDocumentSnapshot = querySnapshot.documents;
      if (listDocumentSnapshot != null && listDocumentSnapshot.isNotEmpty)
        return listDocumentSnapshot.first;
    }
    return null;
  }

  /// Checks if the given [STREKKODE] is already registered in some [produktdocument], and Returns `Future<bool>`
  ///
  /// [required] `strekkode`
  static Future<bool> isStrekkodeRegistred({@required String strekkode}) async {
    var prodFromDB = await getProduktBystrekkode(strekkode: strekkode);
    return (prodFromDB != null &&
        prodFromDB[STREKKODE] != null &&
        prodFromDB[STREKKODE].toString() == strekkode);
  }

  /// create a back up for the given [collection]
  ///
  /// [required] `colPath`
  static void backupAll({@required String colPath}) {
    if (colPath != HANDEL_PATH && colPath != PRODUKT_PATH) {
      print(
          "ERR at DataDB.backupAll(colPath): the param colPath have to be either handelPath or produktPath");
      return;
    }
    String backupPath = colPath == HANDEL_PATH ? HANDEL_BACKUP_PATH : PRODUKT_BACKUP_PATH;

    Stream<QuerySnapshot> st =
        _getStreamCollectionSnapshot(colPath: colPath, orderBy: TIMESTAMP, descending: true);

    var ob$ = Observable(st)
        .map((querySnapshot) => querySnapshot.documents)
        .expand((docSnapshotList) => docSnapshotList)
        .map((docSnapshot) => docSnapshot);

    ob$.listen((docSnapshot) {
      print(docSnapshot.documentID);
      String docID = docSnapshot.documentID;
      var data = docSnapshot.data;
      // print(data);
      DocumentReference doc = _createNewDocument(colPath: backupPath, docID: docID);
      doc.setData(data).then((p) {});
    });
  }

  /// converting an open stream to closed one!! 
  /// Note: any docs/snapshot that been created after closing this stream, will not be added. 
  static Observable<List<DocumentSnapshot>> getCollectionSnapshotAsObservable(
      {@required String colPATH}) {
    Stream<List<DocumentSnapshot>> stDocSnapshotList =
        _getStreamCollectionSnapshot(colPath: colPATH, orderBy: TIMESTAMP, descending: true)
            .map((querySnapshot) => querySnapshot.documents);

    // If a stream will be used inside InnerObservable which'll be flattened for ex. concatMap,
    // this could be a problem, becuase concatMap does not rcv a new item from the outer observable until the innerObservable is closed/completed
    // and fireStore stream is always open "lesMer!!"

    // One solution could be by creating a new Stream as the flwg:
    StreamController streamCtrl = StreamController();

    stDocSnapshotList.listen((docSnapshotList) {
      // Notice that the stDocSnapshotList "firestoreStream" has only one elem which is a list of all the docs
      if (!streamCtrl.isClosed) {
        streamCtrl.add(docSnapshotList);
        //after adding all the elem we have to call "close" on the new created stream
        streamCtrl.close();
      }
    });

    return Observable(streamCtrl.stream).map((docSnapshotList) => docSnapshotList);
  }


}
