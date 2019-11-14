import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handle_app/db/db.dart';
import 'package:handle_app/tree/todo/utilWidget//util.dart';
import 'package:handle_app/tree/handle/addHandel/pages/handleFormPage/handelFormWidget.dart';
import 'package:handle_app/tree/handle/addHandel/pages/varerListePage/varerListeWidget.dart';
import 'package:handle_app/config/attrconfig.dart';

class AddnewHandle_PageViewer extends StatefulWidget {
  AddnewHandle_PageViewer({Key key}) : super(key: key);
  @override
  State createState() => AddnewHandle_PageViewerState();
}

class AddnewHandle_PageViewerState extends State<AddnewHandle_PageViewer> {
/********************************FormState******************************* */
  Map<String, dynamic> handelState;
  Map<String, dynamic> varerState;

  @override
  void initState() {
    varerState = Map<String, dynamic>();

    handelState = {DATO: "", BUTIKK: "", VARER: [], SUMMEN: 0, BANKKORT: 0, KONTANT: 0};
    super.initState();
  }

  void submitToDbHandler() {
    handelState[VARER] = varerState.values.toList();

    print(this.handelState);

    var dato = DateTime.parse(handelState[DATO]);
    int ukeNr = Util.getweekNumber(dato);
    handelState[UKE_NR] = ukeNr;

    DataDB.addNewHandelDoc(data: handelState).then((str) {
      print("FormAddHandle onDone : $str");
      Navigator.pop(context);
    });
  }

  /// returns Future<Map<String, dynamic>>
  dynamic getVareBystrekkodeHandler(strekkode) async {
    Map<String, dynamic> vare = {
      MENGDE: 1,
      NAVN: "",
      PRODUKT_ID: UNREGISTERED_PRODUKT + strekkode,
      PRIS: 0,
      TOTALPRIS: 0,
      STREKKODE: strekkode,
      ER_MATVARE: false,
      BRGN_NAERING: false,
      ER_LEOSVEKT: false,
    };

    DocumentSnapshot doc = await DataDB.getProduktBystrekkode(strekkode: strekkode);

    if (doc != null && doc.data != null) {
      vare[MENGDE] = 1;
      vare[NAVN] = (doc.data[NAVN] ?? "");
      vare[PRODUKT_ID] = doc.documentID;
      vare[PRIS] = 0;
      vare[TOTALPRIS] = 0;
      vare[STREKKODE] = doc.data[STREKKODE].toString();
      vare[ER_MATVARE] = doc.data[ER_MATVARE];
      vare[BRGN_NAERING] = doc.data[ER_MATVARE];
      vare[ER_LEOSVEKT] = doc.data[ER_LEOSVEKT];
    } else
      print("\n\n\n\n&&&&&&&&&&&&&&&&//////////////////////////&&&&&&&&&&&&&&&&\n\n\n\n");
    // hvis strekkoden ikke registerert?

    return vare;
  }

  void addToVarerStateHandler(newVare) async {
    // Map<String, dynamic> data = {
    //   MENGDE: 1,
    //   navn: navn,
    //   PRODUKT_ID: prodSnapshot.documentID eller (UNREGISTERED_PRODUKT + strekkode),
    //   PRIS: 0,
    //   TOTALPRIS: 0,
    //   STREKKODE: strekkode,
    //   ER_MATVARE: bool,
    //   BRGN_NAERING: bool,
    //  ER_LEOSVEKT: bool,
    // };

    // hvis Vare blir valgt fra "TypeAheadTextFormFeild"  (produktID != (UNREGISTERED_PRODUKT + strekkode))
    // strekkode != "" DB har registerert produktet med strekkoden, eller
    // strekkode == "" DB har registerert produktet, men strekkode er null

    // Hvis Vare blir skannet (strekkode != ""):
    // produktID == (UNREGISTERED_PRODUKT + strekkode)
    // produktID != (UNREGISTERED_PRODUKT + strekkode)

    String key = newVare[PRODUKT_ID];

    // TODO extract this "if-statement" to be its own function
    /// checking if the "vare" has been added to varerState with (UNREGISTERED_PRODUKT + strekkode),
    /// but after that the user registered a new "produkt" to the db
    if (varerState.containsKey(UNREGISTERED_PRODUKT + key) && !key.contains(UNREGISTERED_PRODUKT)) {
      var oldKey = UNREGISTERED_PRODUKT + key;
      var newKey = key;
      varerState.putIfAbsent(newKey, () => varerState[UNREGISTERED_PRODUKT + key]);
      varerState.remove(oldKey);
    }

    // If the key is present, invokes update with the current value and stores the new value in the map.
    // If the key is not present and ifAbsent is provided, calls ifAbsent and adds the key with the returned value to the map.
    // It's an error if the key is not present and ifAbsent is not provided
    // Map.update(String key,  update,  ifAbsent )
    varerState.update(key, (oldVare) {
      if (!oldVare[ER_LEOSVEKT]) //don't update the value of "løsvekt" item
        oldVare[MENGDE] = (oldVare[MENGDE] ?? 1) + 1;
      return oldVare;
    }, ifAbsent: () => newVare);
    varerState[key][TOTALPRIS] = varerState[key][MENGDE] * varerState[key][PRIS];

    setState(() {});
  }

  bool isEqual_2Maps(oldVare, newVare) {
    bool isEqual = oldVare != null && newVare != null;
    if (isEqual)
      newVare.forEach((k, v) {
        if (isEqual) isEqual = oldVare[k] == newVare[k];
      });
    return isEqual;
  }

  void removeAllFromVarerListeHandler(vare) {
    varerState.removeWhere((k, v) => isEqual_2Maps(v, vare));
    setState(() {});
  }

  void removeOneFromVarerListeHandler(data) {
    // Param blir sendt "by ref" ikke "by value"
    // String key = "";
    // varerState.forEach(
    //     (k, v) => key = key.isEmpty && isEqual_2Maps(v, data) ? k : key);
    // var vare = varerState[key];
    // if (vare != null) if (vare[MENGDE] > 1) {
    //   --vare[MENGDE];
    // }
    if (data != null && varerState.containsValue(data) && data[MENGDE] > 1) {
      --data[MENGDE];
      data[TOTALPRIS] = data[MENGDE] * data[PRIS];

      setState(() {});
    }
  }

  Widget _handelFormWidget() => HandelFormWidget(
        handelState: handelState,
        varerState: varerState,
        submitToDbHandler: submitToDbHandler,
      );

  Widget _varerListePage(_pageController) => VarerListWidget(
      varerState: varerState,
      onAddToVarerState: addToVarerStateHandler,
      onRemoveOneFromVarerList: removeOneFromVarerListeHandler,
      onRemoveAllFromVarerList: removeAllFromVarerListeHandler,
      onGetVareBystrekkode: getVareBystrekkodeHandler,
      pageController: _pageController);

  ///***************************** PageViewer ***************************** */
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _handelFormWidget(),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _varerListePage(_pageController),
      ),
    ];

    return Stack(
      children: <Widget>[
        PageView.builder(
          onPageChanged: (ind) {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          physics:
              AlwaysScrollableScrollPhysics(), //skulle lest fra state AlwaysScrollableScrollPhysics ELLER NeverScrollableScrollPhysics
          controller: _pageController,
          itemCount: _pages.length,
          itemBuilder: (BuildContext context, int index) {
            return _pages[index];
          },
        ),
      ],
    );
  }
}
