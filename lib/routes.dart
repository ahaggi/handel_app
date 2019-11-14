import 'package:flutter/material.dart';


import 'package:handle_app/tree/handle/handelList/handlelistWidget.dart';
import 'package:handle_app/tree/product/produktList/produktlistWidget.dart';
import 'package:handle_app/tree/product/productForm/addProduktWidget.dart';
// import './tree/testStorage/testStorageWidget.dart';
import 'package:handle_app/tree/handle/addHandel/addnewHandle_PageViewer.dart';
import 'package:handle_app/tree/todo/utilWidget/chartWidget.dart';

const String handle = '/HandleListeWidget';
const String produkter = '/ProduktlisteWidget';
const String storage = '/TestStorage';
const String addProdukt = '/AddNewProduktWidget';
const String addHandel = '/AddnewHandle_PageViewer';
const String charts = '/GroupedBarChart';

Map<String, dynamic> routesMap = <String, WidgetBuilder>{
  handle: (BuildContext context) => new HandleListWidget(),
  produkter: (BuildContext context) => new ProduktlistWidget(),
  // storage: (BuildContext context) => new TestStorage(),
  addProdukt: (BuildContext context) => new AddNewProduktWidget(),
  addHandel: (BuildContext context) => new AddnewHandle_PageViewer(),

  charts: (BuildContext context) => ChartWidget(),
};

//Du kan bruke routes sånn


    //Namedroutes
    //1- import routeesMap
    //2- Navigator.of(context).pushNamed('/HandleListeWidget');


    //Eller alt. kan du bruke MaterialPageRoute
    // final route = MaterialPageRoute(
    //   builder: (context) {
    //     return HandleListeWidget();
    //   },
    // );
    // Navigator.of(context).push(route);

