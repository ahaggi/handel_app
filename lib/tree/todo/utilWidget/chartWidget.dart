import 'dart:math';

import 'package:charts_flutter/flutter.dart' hide TextStyle;
import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as chartsFlutter;
import 'package:charts_flutter/flutter.dart'
    show
        Series,
        BarChart,
        BarGroupingType,
        SeriesLegend,
        BehaviorPosition,
        MaterialPalette;

import 'dart:async';
import 'package:handle_app/db/db.dart';
import 'package:handle_app/db/dbQry.dart';
import 'package:handle_app/tree/todo/utilWidget/loadingIndicator.dart';
import 'package:handle_app/config/attrconfig.dart';

/**
  List<Series<OrdinalMeasurment, String>> dummyData() {
    final desktopSalesData = [
      new OrdinalMeasurment(xLabelDomain: '2014', dataMeasure: 5),
      new OrdinalMeasurment(xLabelDomain: '2015', dataMeasure: 25),
      new OrdinalMeasurment(xLabelDomain: '2016', dataMeasure: 100),
      new OrdinalMeasurment(xLabelDomain: '2017', dataMeasure: 75),
    ];

    final tableSalesData = [
      new OrdinalMeasurment(xLabelDomain: '2014', dataMeasure: 25),
      new OrdinalMeasurment(xLabelDomain: '2015', dataMeasure: 50),
      new OrdinalMeasurment(xLabelDomain: '2016', dataMeasure: 10),
      new OrdinalMeasurment(xLabelDomain: '2017', dataMeasure: 20),
    ];

    final mobileSalesData = [
      new OrdinalMeasurment(xLabelDomain: '2014', dataMeasure: 10),
      new OrdinalMeasurment(xLabelDomain: '2015', dataMeasure: 15),
      new OrdinalMeasurment(xLabelDomain: '2016', dataMeasure: 50),
      new OrdinalMeasurment(xLabelDomain: '2017', dataMeasure: 45),
    ];

    return [
      new Series<OrdinalMeasurment, String>(
        id: 'Desktop',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: desktopSalesData,
      ),
      new Series<OrdinalMeasurment, String>(
        id: 'Tablet',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: tableSalesData,
      ),
      new Series<OrdinalMeasurment, String>(
        id: 'Mobile',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: mobileSalesData,
        fillColorFn: (_, __) => MaterialPalette.blue.shadeDefault.darker,
      ),
    ];
  }

 */
class OrdinalMeasurment {
  final String xLabelDomain;
  final num dataMeasure;
  OrdinalMeasurment({@required this.xLabelDomain, @required this.dataMeasure});
}

class GroupedBarChartWidget extends StatelessWidget {
  GroupedBarChartWidget({
    Key key,
    @required this.karbohydraterList,
    @required this.fettList,
    @required this.proteinList,
    @required this.kalorierList,
    @required this.kostnadList,
  }) : super(key: key);

  final List<OrdinalMeasurment> karbohydraterList;
  final List<OrdinalMeasurment> fettList;
  final List<OrdinalMeasurment> proteinList;
  final List<OrdinalMeasurment> kalorierList;
  final List<OrdinalMeasurment> kostnadList;

  // Disable animations for image tests.
  final bool animate = true;

  List<Series<OrdinalMeasurment, String>> getChartSeries() {
    Series<OrdinalMeasurment, String> karbohydraterSeries;
    Series<OrdinalMeasurment, String> fettSeries;
    Series<OrdinalMeasurment, String> proteinSeries;
    Series<OrdinalMeasurment, String> kalorierSeries;
    Series<OrdinalMeasurment, String> kostnadSeries;

    karbohydraterSeries = Series<OrdinalMeasurment, String>(
        id: 'Karbohydrater',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: karbohydraterList);

    fettSeries = Series<OrdinalMeasurment, String>(
        id: 'Fett',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: fettList);

    proteinSeries = Series<OrdinalMeasurment, String>(
        id: 'Protein',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: proteinList);

    kalorierSeries = Series<OrdinalMeasurment, String>(
        id: 'Kalorier',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: kalorierList,
        fillColorFn: (_, __) => MaterialPalette.blue.shadeDefault.darker);

    kostnadSeries = Series<OrdinalMeasurment, String>(
        id: 'Kostnad',
        domainFn: (OrdinalMeasurment measures, _) => measures.xLabelDomain,
        measureFn: (OrdinalMeasurment measures, _) => measures.dataMeasure,
        data: kostnadList,
        fillColorFn: (_, __) => MaterialPalette.blue.shadeDefault.darker);

    return [
      karbohydraterSeries,
      fettSeries,
      proteinSeries,
      kalorierSeries,
      kostnadSeries,
    ];
  }

  Widget _getChart() => Center(
        child: BarChart(
          getChartSeries(),
          animate: animate,
          barGroupingType: BarGroupingType.grouped,
          behaviors: [SeriesLegend()],
          domainAxis: OrdinalAxisSpec(
            renderSpec: SmallTickRendererSpec(labelRotation: 60),
          ),

          // behaviors: [
          //   new SeriesLegend(
          //     // Positions for "start" and "end" will be left and right respectively
          //     // for widgets with a build context that has directionality ltr.
          //     // For rtl, "start" and "end" will be right and left respectively.
          //     // Since this example has directionality of ltr, the legend is
          //     // positioned on the right side of the chart.
          //     position: BehaviorPosition.end,
          //     // By default, if the position of the chart is on the left or right of
          //     // the chart, [horizontalFirst] is set to false. This means that the
          //     // legend entries will grow as new rows first instead of a new column.
          //     horizontalFirst: false,
          //     // This defines the padding around each legend entry.
          //     cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
          //     // Set show measures to true to display measures in series legend,
          //     // when the datum is selected.
          //     showMeasures: true,
          //     // Optionally provide a measure formatter to format the measure value.
          //     // If none is specified the value is formatted as a decimal.
          //     measureFormatter: (num value) {
          //       return value == null ? '-' : '${value}k';
          //     },
          //   ),
          // ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return _getChart();
  }
}

class ChartWidget extends StatefulWidget {
  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  // Instead of didUpdateWidget try to take advantage of AsyncSnapshot's capabilities, especially "monitoring connectionState".

  //DropDown state
  Map<String, int> dropdownValues = {};

  Stream outputStream;

  @override
  void initState() {
    super.initState();
    outputStream = _generateDummyData();
  }

  Widget _getDropdownMenu({List list, String hintText}) {
    String key = hintText == "måned" ? "mm" : "yy";
    var listMenuItems = list
        .map<DropdownMenuItem<int>>((elm) => DropdownMenuItem<int>(
              value: elm['value'],
              child: Text(elm['text']),
            ))
        .toList();
    return DropdownButton<int>(
      hint: Text(
        hintText,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      value: dropdownValues[key],
      onChanged: (int newValue) {
        dropdownValues[key] = newValue;
        setState(() {});
      },
      items: listMenuItems,
    );
  }

  Widget _getRowDropDownMenus() {
    var monthsList = [
      {'text': 'Jan', 'value': 1},
      {'text': 'Feb', 'value': 2},
      {'text': 'Mar', 'value': 3},
      {'text': 'Apr', 'value': 4},
      {'text': 'May', 'value': 5},
      {'text': 'Jun', 'value': 6},
      {'text': 'Jul', 'value': 7},
      {'text': 'Aug', 'value': 8},
      {'text': 'Sep', 'value': 9},
      {'text': 'Okt', 'value': 10},
      {'text': 'Nov', 'value': 11},
      {'text': 'Des', 'value': 12},
    ];

    var yearsList = List.generate(2, (n) {
      var y = DateTime.now().year - n;
      return {'text': y.toString(), 'value': y};
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _getDropdownMenu(hintText: "år", list: yearsList),
        _getDropdownMenu(hintText: "måned", list: monthsList),
      ],
    );
  }

  void onUpdateData() {
    // StreamSubscription<dynamic> subscription =
    //     subscription.cancel();
    bool isRealData = Random().nextInt(4) == 1;
    outputStream =
        isRealData ? _generateStreamForChartData() : _generateDummyData();
    print("############ db data:  $isRealData #############");
    setState(() {});
  }

  Stream<Map<String, List<OrdinalMeasurment>>> _generateDummyData() {
    var label = (Random().nextInt(5) + 1).toString();

    List<OrdinalMeasurment> karbohydraterList = [
      OrdinalMeasurment(
          xLabelDomain: label, dataMeasure: Random().nextInt(100)),
      OrdinalMeasurment(
          xLabelDomain: "${label}_1", dataMeasure: Random().nextInt(100))
    ];
    List<OrdinalMeasurment> fettList = [
      OrdinalMeasurment(
          xLabelDomain: label, dataMeasure: Random().nextInt(100)),
      OrdinalMeasurment(
          xLabelDomain: "${label}_1", dataMeasure: Random().nextInt(100))
    ];
    List<OrdinalMeasurment> proteinList = [
      OrdinalMeasurment(
          xLabelDomain: label, dataMeasure: Random().nextInt(100)),
      OrdinalMeasurment(
          xLabelDomain: "${label}_1", dataMeasure: Random().nextInt(100))
    ];
    List<OrdinalMeasurment> kalorierList = [
      OrdinalMeasurment(
          xLabelDomain: label, dataMeasure: Random().nextInt(100)),
      OrdinalMeasurment(
          xLabelDomain: "${label}_1", dataMeasure: Random().nextInt(100))
    ];
    List<OrdinalMeasurment> kostnadList = [
      OrdinalMeasurment(
          xLabelDomain: label, dataMeasure: Random().nextInt(100)),
      OrdinalMeasurment(
          xLabelDomain: "${label}_1", dataMeasure: Random().nextInt(100))
    ];

    Stream stream = (StreamController<Map<String, List<OrdinalMeasurment>>>()
          ..add({
            "karbohydraterList": karbohydraterList,
            "fettList": fettList,
            "proteinList": proteinList,
            "kalorierList": kalorierList,
            "kostnadList": kostnadList,
          }))
        .stream
        .asBroadcastStream();

    return stream;
  }

  Stream<Map<String, List<OrdinalMeasurment>>> _generateStreamForChartData() {
    List<OrdinalMeasurment> karbohydraterList = [];
    List<OrdinalMeasurment> fettList = [];
    List<OrdinalMeasurment> proteinList = [];
    List<OrdinalMeasurment> kalorierList = [];
    List<OrdinalMeasurment> kostnadList = [];

    return DataDB.getStreamChartDataMNCollectionSnapshot()
        .map((qrySnapshot) => qrySnapshot.documents)
        .expand((listDocSnapshots) => listDocSnapshots)
        .take(6)
        .map((data) {
// this is the key which the elems are grouped by. i.e "måned", UKE_NR ...
      var xLabelDomain = data["id"].toString().substring(4);

      karbohydraterList.add(OrdinalMeasurment(
          xLabelDomain: xLabelDomain, dataMeasure: data[KARBOHYDRATER]));

      fettList.add(OrdinalMeasurment(
          xLabelDomain: xLabelDomain, dataMeasure: data[FETT]));

      proteinList.add(OrdinalMeasurment(
          xLabelDomain: xLabelDomain, dataMeasure: data[PROTEIN]));

      kalorierList.add(OrdinalMeasurment(
          xLabelDomain: xLabelDomain, dataMeasure: data[KALORIER]));

      kostnadList.add(OrdinalMeasurment(
          xLabelDomain: xLabelDomain, dataMeasure: data[KOSTNAD]));

      return {
        "karbohydraterList": karbohydraterList,
        "fettList": fettList,
        "proteinList": proteinList,
        "kalorierList": kalorierList,
        "kostnadList": kostnadList,
      };
    }).asBroadcastStream();
  }

  Widget _getChartWidget() {
    return StreamBuilder<Map<String, List<OrdinalMeasurment>>>(
      stream: outputStream,
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, List<OrdinalMeasurment>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData)
          return LoadingIndicatorWidget(
            waitingDur: 5,
            onCancelCallback: () {
              outputStream = null;

              setState(() {});
              // getCustomSnackBar("Forespørselen blir avbrutt!");
            },
          );
        else if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          return GroupedBarChartWidget(
            karbohydraterList: snapshot.data["karbohydraterList"],
            fettList: snapshot.data["fettList"],
            proteinList: snapshot.data["proteinList"],
            kalorierList: snapshot.data["kalorierList"],
            kostnadList: snapshot.data["kostnadList"],
          );
        }

        return Container();
      },
    );
  }

  Widget _getFloatingActionButton() {
    return StreamBuilder<Map<String, List<OrdinalMeasurment>>>(
      stream: outputStream,
      builder: (BuildContext context,
          AsyncSnapshot<Map<String, List<OrdinalMeasurment>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData)
          return Container();
        else if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          return FloatingActionButton(
            child: Text(
              "press me",
              textAlign: TextAlign.center,
            ),
            onPressed: () => onUpdateData(),
          );
        }

        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Storage Example'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(flex: 4, child: _getChartWidget()),
            Expanded(flex: 1, child: _getRowDropDownMenus()),
          ],
        ),
      ),
      floatingActionButton: _getFloatingActionButton(),
    );
  }
}
