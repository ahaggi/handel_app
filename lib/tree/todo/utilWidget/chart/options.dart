import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:handle_app/db/dbQry.dart';

import '../myCallback.dart';
import '../util.dart';
import '../utilUI.dart';

const int MAX_PERIOD_LEN = 9;

class Options extends StatefulWidget {
  Options(
      {Key key,
      @required this.scaffoldKey,
      @required this.onSelectCallback,
      @required this.changeModeCallback,
      @required this.mode});
  final GlobalKey<ScaffoldState> scaffoldKey;
  final MC2Dynamicvoid onSelectCallback;
  final MCDynamicVoid changeModeCallback;
  final GroupBy mode;

  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  Map<String, dynamic> selectedMonthsValue = {
    FROM_MONTH: Map<String, dynamic>()..addAll({"mm": null, "yyyy": null}),
    TO_MONTH: Map<String, dynamic>()..addAll({"mm": null, "yyyy": null}),
  };
  Map<String, dynamic> selectedWeeksValue = {
    FROM_WEEK: Map<String, dynamic>()..addAll({"wk": null, "yyyy": null}),
    TO_WEEK: Map<String, dynamic>()..addAll({"wk": null, "yyyy": null}),
  };

  Widget _getViewByMenu() {
    var viewBylist = [
      {'text': 'Month', 'value': GroupBy.MONTH},
      {'text': 'Week', 'value': GroupBy.WEEK},
    ];
    var tiles = viewBylist
        .map((elm) => SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Container(
                height: 40.0,
                child: RadioListTile<GroupBy>(
                  dense: true,
                  title: Text(elm['text']),
                  value: elm['value'],
                  groupValue: widget.mode,
                  onChanged: (GroupBy value) {
                    widget.changeModeCallback(value);
                    // setState(() {}); commented out, since the parent will trigger a rerendering anyway
                  },
                ),
              ),
            ))
        .toList();

    return Row(
      children: tiles,
    );

    // var listMenuItems = viewBylist
    //     .map<DropdownMenuItem<String>>((elm) => DropdownMenuItem<String>(
    //           value: "${elm['value']}",
    //           child: Text(elm['text']),
    //         ))
    //     .toList();
    // return DropdownButton<String>(
    //   hint: Text(
    //     "View By",
    //     style: TextStyle(
    //       color: Colors.black,
    //     ),
    //   ),
    //   value: widget.mode?.index.toString(),
    //   onChanged: (String v) {
    //     int newValue = Util.parseStringtoNum(v);
    //     GroupBy _md;
    //     if (newValue == GroupBy.MONTH.index) {
    //       _md = GroupBy.MONTH;
    //     } else if (newValue == GroupBy.WEEK.index) {
    //       _md = GroupBy.WEEK;
    //     }
    //     widget.changeModeCallback(_md);

    //   },
    //   items: listMenuItems,
    // );
  }

  Future _showDialog({String dialogMsg, MCDynamicVoid fn, rangeStart}) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            // shape: RoundedRectangleBorder(
            // borderRadius: BorderRadius.all(Radius.circular(32.0))),
            // borderRadius: BorderRadius.only(topLeft: Radius.circular(32.0), topRight: Radius.circular(32.0))),
            title: Center(child: Text(dialogMsg)),
            children: <Widget>[
              DateListView(
                  onSelectCallback: fn,
                  mode: widget.mode,
                  rangeStart: rangeStart)
            ],
          );
        });
  }

  // String formatMntInput(String key) {
  //   var tempMm = selectedMonthsValue[key]['mm'];
  //   var tempYyyy = selectedMonthsValue[key]['yyyy'];
  //   String prefix = "${tempMm > 9 ? '' : '0'}";

  //   return "$tempYyyy-$prefix$tempMm";
  // }

  void setFromMonthHandler(fromDate) {
    //validation
    //------------------------------------------------------------------------
    var fmMm = fromDate['mm'];
    var fmYyyy = fromDate['yyyy'];
    var valid = (fmMm > 0 && fmMm <= 12) && (fmYyyy <= DateTime.now().year);

    if (!valid) {
      UtilUI.getCustomSnackBar(scaffoldKey: widget.scaffoldKey, text: "!valid");
      return;
    }

    // validate that if TO_MONTH is set before FROM_MONTH, then the diff should not exceed MAX_PERIOD_LEN
    var toMm = selectedMonthsValue[TO_MONTH]['mm'];
    var toYyyy = selectedMonthsValue[TO_MONTH]['yyyy'];

    if (toMm != null || toYyyy != null) {
      var selectedPeriodLength = ((toYyyy - fmYyyy) * 12) + (toMm - fmMm);
      if (selectedPeriodLength >= MAX_PERIOD_LEN || selectedPeriodLength < 0) {
        UtilUI.getCustomSnackBar(
            scaffoldKey: widget.scaffoldKey, text: "sdf! MAX_PERIOD_LEN..");
        selectedMonthsValue[TO_MONTH]['mm'] = fromDate['mm'];
        selectedMonthsValue[TO_MONTH]['yyyy'] = fromDate['yyyy'];
      }
    }
    //------------------------------------------------------------------------

    selectedMonthsValue[FROM_MONTH]['mm'] = fromDate['mm'];
    selectedMonthsValue[FROM_MONTH]['yyyy'] = fromDate['yyyy'];
    print(selectedMonthsValue[FROM_MONTH]);
    widget.onSelectCallback(GroupBy.MONTH, selectedMonthsValue);
    setState(() {});
  }

  void setToMonthHandler(toDate) {
    //validation
    //------------------------------------------------------------------------
    var toMm = toDate['mm'];
    var toYyyy = toDate['yyyy'];
    var valid = (toMm > 0 && toMm <= 12) && (toYyyy <= DateTime.now().year);

    if (!valid) {
      UtilUI.getCustomSnackBar(scaffoldKey: widget.scaffoldKey, text: "!valid");
      return;
    }

    var fmMm = selectedMonthsValue[FROM_MONTH]['mm'];
    var fmYyyy = selectedMonthsValue[FROM_MONTH]['yyyy'];

    if (fmMm != null || fmYyyy != null) {
      var selectedPeriodLength = ((toYyyy - fmYyyy) * 12) + (toMm - fmMm);
      if (selectedPeriodLength >= MAX_PERIOD_LEN || selectedPeriodLength < 0) {
        UtilUI.getCustomSnackBar(
            scaffoldKey: widget.scaffoldKey, text: "sdf! MAX_PERIOD_LEN..");

        //Obs return
        return;
      }
    }
    //------------------------------------------------------------------------

    selectedMonthsValue[TO_MONTH]['mm'] = toDate['mm'];
    selectedMonthsValue[TO_MONTH]['yyyy'] = toDate['yyyy'];
    print(selectedMonthsValue[TO_MONTH]);
    widget.onSelectCallback(GroupBy.MONTH, selectedMonthsValue);
    setState(() {});
  }

  void setFromWeekHandler(fromDate) {
    //validation
    //------------------------------------------------------------------------
    var fmWk = fromDate['wk'];
    var fmYyyy = fromDate['yyyy'];
    var valid = (fmWk > 0 && fmWk <= 53) && (fmYyyy <= DateTime.now().year);

    if (!valid) {
      UtilUI.getCustomSnackBar(scaffoldKey: widget.scaffoldKey, text: "!valid");
      return;
    }

    // validate that if TO_WEEK is set before FROM_WEEK, then the diff should not exceed MAX_PERIOD_LEN
    var toWk = selectedWeeksValue[TO_WEEK]['wk'];
    var toYyyy = selectedWeeksValue[TO_WEEK]['yyyy'];

    if (toWk != null || toYyyy != null) {
      var selectedPeriodLength = ((toYyyy - fmYyyy) * 52) + (toWk - fmWk);
      if (selectedPeriodLength >= MAX_PERIOD_LEN || selectedPeriodLength < 0) {
        UtilUI.getCustomSnackBar(
            scaffoldKey: widget.scaffoldKey, text: "sdf! MAX_PERIOD_LEN..");
        selectedWeeksValue[TO_WEEK]['wk'] = fromDate['wk'];
        selectedWeeksValue[TO_WEEK]['yyyy'] = fromDate['yyyy'];
      }
    }
    //------------------------------------------------------------------------

    selectedWeeksValue[FROM_WEEK]['wk'] = fromDate['wk'];
    selectedWeeksValue[FROM_WEEK]['yyyy'] = fromDate['yyyy'];

    print(selectedWeeksValue[FROM_WEEK]);
    widget.onSelectCallback(GroupBy.WEEK, selectedWeeksValue);

    setState(() {});
  }

  void setToWeekHandler(toDate) {
    //validation
    //------------------------------------------------------------------------
    var toWk = toDate['wk'];
    var toYyyy = toDate['yyyy'];
    var valid = (toWk > 0 && toWk <= 53) && (toYyyy <= DateTime.now().year);

    if (!valid) {
      UtilUI.getCustomSnackBar(scaffoldKey: widget.scaffoldKey, text: "!valid");
      return;
    }

    var fmWk = selectedWeeksValue[FROM_WEEK]['wk'];
    var fmYyyy = selectedWeeksValue[FROM_WEEK]['yyyy'];

    if (fmWk != null || fmYyyy != null) {
      var selectedPeriodLength = ((toYyyy - fmYyyy) * 52) + (toWk - fmWk);
      if (selectedPeriodLength >= MAX_PERIOD_LEN || selectedPeriodLength < 0) {
        UtilUI.getCustomSnackBar(
            scaffoldKey: widget.scaffoldKey, text: "sdf! MAX_PERIOD_LEN..");

        //Obs return
        return;
      }
    }
    //------------------------------------------------------------------------

    selectedWeeksValue[TO_WEEK]['wk'] = toDate['wk'];
    selectedWeeksValue[TO_WEEK]['yyyy'] = toDate['yyyy'];
    print(selectedWeeksValue[TO_WEEK]);
    widget.onSelectCallback(GroupBy.WEEK, selectedWeeksValue);
    setState(() {});
  }

  List<Widget> selectDatesButtons() {
    var fromCallbackHandler;
    var toCallbackHandler;
    String fromKey;
    String toKey;
    var rangeStart;
    var selectedValue;
    if (widget.mode == GroupBy.MONTH) {
      selectedValue = selectedMonthsValue;
      fromCallbackHandler = setFromMonthHandler;
      toCallbackHandler = setToMonthHandler;
      fromKey = FROM_MONTH;
      toKey = TO_MONTH;
      rangeStart = (selectedMonthsValue[FROM_MONTH]["mm"] != null &&
              selectedMonthsValue[FROM_MONTH]["yyyy"] != null)
          ? selectedMonthsValue[FROM_MONTH]
          : null;
    } else if (widget.mode == GroupBy.WEEK) {
      selectedValue = selectedWeeksValue;
      fromCallbackHandler = setFromWeekHandler;
      toCallbackHandler = setToWeekHandler;
      fromKey = FROM_WEEK;
      toKey = TO_WEEK;
      rangeStart = (selectedWeeksValue[FROM_WEEK]["wk"] != null &&
              selectedWeeksValue[FROM_WEEK]["yyyy"] != null)
          ? selectedWeeksValue[FROM_WEEK]
          : null;
    }

    return [
      RaisedButton(
        onPressed: () =>
            _showDialog(dialogMsg: "fm ewr", fn: fromCallbackHandler),
        child: Text("From:${selectedValue[fromKey]}"),
      ),
      RaisedButton(
        onPressed: () => _showDialog(
            dialogMsg: "to wer", fn: toCallbackHandler, rangeStart: rangeStart),
        child: Text("To:${selectedValue[toKey]}"),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: selectDatesButtons()),
        _getViewByMenu(),
      ],
    ));
  }
}

const String FROM_MONTH = 'fromMonth';
const String TO_MONTH = 'toMonth';
const String FROM_WEEK = 'fromWeek';
const String TO_WEEK = 'toWeek';

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
class DateListView extends StatefulWidget {
  DateListView(
      {@required this.onSelectCallback, @required this.mode, this.rangeStart});
  final MCDynamicVoid onSelectCallback;
  final GroupBy mode;
  final rangeStart;
  @override
  _DateListViewState createState() => _DateListViewState();
}

class _DateListViewState extends State<DateListView> {
  ScrollController _scrollController;
  List<dynamic> _items;

  void initState() {
    _scrollController = ScrollController();
    _items = [];
    appendMore();

    super.initState();
  }

  void appendMore() {
    if (widget.mode == GroupBy.MONTH) {
      appendMonthsToDateList(MAX_PERIOD_LEN);
    } else if (widget.mode == GroupBy.WEEK) {
      appendWeeksToDateList(MAX_PERIOD_LEN);
    }
  }

  void appendWeeksToDateList(int nrOfItems) {
    var weekNrStart;
    var yearStart;

    if (_items.length == 0) {
      var now = DateTime.now();
      var res = Util.getWeekNumber(now);
      weekNrStart = res[0];
      yearStart = res[1];

      if ((widget.rangeStart ?? {})["wk"] != null) {
        var wkSR = widget.rangeStart["wk"];
        var yrSR = widget.rangeStart["yyyy"];

        // rangeStart + 9 weeks must be < DateTime.now
        // which means: 9 weeks < (DateTime.now) - (rangeStart)
        var temp = (((yearStart - yrSR) * 52) + weekNrStart - wkSR);
        temp = (MAX_PERIOD_LEN < temp) ? MAX_PERIOD_LEN : temp;
        weekNrStart = (wkSR + temp) % 52;
        yearStart = yrSR + ((wkSR + temp) ~/ 52);
      }
    } else {
      // instead of calc the start value of new weeks (which depends on how many weeks already exists in the list),
      weekNrStart = (_items[_items.length - 1])['value']["wk"];
      yearStart = (_items[_items.length - 1])['value']["yyyy"];
    }

    var weeksList = List.generate(nrOfItems, (n) {
      if (weekNrStart == 1) {
        // if the prev value of the weekNr was 1, Or we started the list at weekNr 1
        yearStart--;
        weekNrStart = Util.isItLongYearISO(yearStart) ? 53 : 52;
      } else {
        weekNrStart--;
      }

      String prefix = "${weekNrStart > 9 ? '' : '0'}";

      var txt = "$yearStart-$prefix$weekNrStart";

      Map<String, int> wkValue = {"wk": weekNrStart, "yyyy": yearStart};

      return {
        'text': txt,
        'value': wkValue,
      };
    });

    _items.addAll(weeksList);
    setState(() {});
  }

  void appendMonthsToDateList(int nrOfItem) {
    var mm = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    var temp = 0;
    var mmRS = (widget.rangeStart ?? {})["mm"];
    var yrRS = (widget.rangeStart ?? {})["yyyy"];
    var now = DateTime.now();
    var mntStart = now.month - _items.length;
    var yearStart = now.year - ((_items.length + mntStart) ~/ 12);

    if (mmRS != null) {
      temp = ((yearStart - yrRS) * 12) + mntStart - mmRS;
      temp = (MAX_PERIOD_LEN < temp) ? MAX_PERIOD_LEN - 1 : temp;

      mntStart = (mmRS + temp) % 12;
      yearStart = yrRS + ((mmRS + temp) ~/ 12);
    }

    var monthsList = List.generate(nrOfItem, (n) {
      // (mntStart - 1) since in our months-list we have 0 Jan, 1 Feb, .., 11 Des
      var ind = ((mntStart - 1) - n) % 12;
      int tempYearStr = (yearStart - ((12 - mntStart + n) ~/ 12));

      // String prefix = "${ind + 1 > 9 ? '' : '0'}";
      // "mnd-$tempYearStr-$prefix${ind + 1}";
      var mmText = "$tempYearStr" + "-" + mm[ind];
      Map<String, int> mmValue = {"yyyy": tempYearStr, "mm": ind + 1};

      return {
        'text': mmText,
        'value': mmValue,
      };
    }).toList();

    _items.addAll(monthsList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget customScrollView() => NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (
              //(scrollNotification is OverscrollNotification) &&
              (_scrollController.position.pixels >
                  (_scrollController.position.maxScrollExtent - 200))) {
            // load new items when reaching 200px before the end of the list
            // if (widget.range == null || widget.range > _items.length) {
            appendMore();
            // }
          }
          return;
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: _items.length,
              itemBuilder: (_, int index) {
                return Card(
                  color: index % 2 == 0 ? Theme.of(context).buttonColor : null,
                  child: ListTile(
                      title: Center(child: Text(_items[index]['text'])),
                      dense: true,
                      onTap: () {
                        widget.onSelectCallback(_items[index]['value']);
                        Navigator.pop(context);
                      }),
                );
              }),
        ));

    return customScrollView();
  }
}
