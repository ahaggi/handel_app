import 'dart:collection';
import 'dart:math';
import 'dart:async';

import 'package:handle_app/db/db.dart';
import 'package:handle_app/config/attrconfig.dart';

class Util {
  static Map sortMap(Map inputMap, dynamic sortingFunction) {
    // HowTO:
    // Map unsortedMap = m5["5"]["produkter"];
    // dynamic fn = (a, b) => (unsortedMap[a][KARBOHYDRATER].compareTo(unsortedMap[b][KARBOHYDRATER]) as int);
    // Map sortedMap = Util.sortMap( unsortedMap , fn);

    List sortedKeys = inputMap.keys.toList()..sort(sortingFunction);
    LinkedHashMap sortedMap = new LinkedHashMap();
    sortedKeys.forEach((k) => sortedMap[k] = inputMap[k]);
    return sortedMap;
  }

  static void printChartDataAsProdukterSortedBy(
      {Map inputMap, String compareBy: KARBOHYDRATER, int take: 5}) {
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    print(inputMap["key"]);

    //sort
    Map m = inputMap["data"]["produkter"];
    dynamic fn = (a, b) => (m[a][compareBy].compareTo(m[b][compareBy]) as int);
    Map sortedMap = Util.sortMap(m, fn);
    sortedMap.keys.toList().reversed.take(take).forEach((k) {
      print("$k: ${sortedMap[k]}");
    });
    print("----------------Total----------------");

    (inputMap["data"] as Map).remove("produkter");
    print(inputMap);
    print("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
  }

  /// This function returns `null` for invalid inputs instead of throwing.
  static num parseStringtoNum(String input) {
    String value = input
        ?.replaceAll(new RegExp(r','), '.')
        ?.replaceAll(new RegExp(r' '), '');

    num number = num.tryParse(value);

    return number;
  }

  static DateTime parseStringtoDate(String input) {
    DateTime date = DateTime.parse(input);

    return date;
  }

  static bool isBarcodeValid(String code) {
    num _barcode = parseStringtoNum(code);
    if (_barcode != null && _barcode is int && _barcode > pow(10, 6)) {
      num _barcodeWithLastDigitAszero = (_barcode ~/ 10) * 10;
      num _barcodeLastDigit = _barcode - _barcodeWithLastDigitAszero;
      return _barcodeLastDigit ==
          calculateThecheckDigit(_barcodeWithLastDigitAszero);
    } else
      return false;
  }

  static int generateRandomBetween100and999() {
    double dbl = Random().nextDouble();
    for (var i = 0; i < 4 && dbl < 100; i++) dbl *= 10;

    // print(dbl);
    // print(dbl.toInt() % 1000);
    return dbl.toInt();
  }

  static Future<num> generateFakeBarcode() async {
    int _fakeBarcode;
    var allreadyRegistered = true;

    while (allreadyRegistered) {
      int _rndm3Digits = generateRandomBetween100and999();
      int _fakeBarcodeWithLastDigitAszero =
          (10101010 * 1000 + _rndm3Digits) * 10;

      _fakeBarcode = _fakeBarcodeWithLastDigitAszero +
          calculateThecheckDigit(_fakeBarcodeWithLastDigitAszero);

      allreadyRegistered =
          await DataDB.isStrekkodeRegistred(strekkode: _fakeBarcode.toString());
    }

    return _fakeBarcode;
  }

  static num calculateThecheckDigit(int _barcodeWithLastDigitAszero) {
    // Tested for GTIN , GSIN and SSCC

    // The algorithm to calculate a check digit manually
    //   - Create an int array with size of 18 elem.
    //   - Fill the most signi. digits of the barcode with 0. e.i. the most sig. numbers of a GTIN-12 will be six zeros.
    //   - Fill the array with the barcode digits.
    //   - Multiply each elem in the array (except the last one) with:
    // 		  - The first elem with 3, the 2nd with 1, the 3rd with 3, .. and the 17th with 3.
    //   - Add all the elements in the array together to create sum.
    //   - Subtract the sum from nearest equal or higher multiple of ten. for ex. 77 nearest equal or higher multiple of ten is 80 => 80 -77  and for 40 is 40 => 40-40
    //   - The result must be equal to the least sig. digit of the barcode.

    List<int> checkSumList = List.generate(18, (ind) {
      num exponent = 18 - 1 - ind;
      num digit = (_barcodeWithLastDigitAszero ~/ pow(10, exponent)) % 10;
      num n = pow(3, ((ind + 1) % 2));
      num sum = digit * n;
      print(" $digit X $n = $sum");
      return sum;
    });
    num theTotalSum = checkSumList.fold(0, (prev, element) => prev + element);

    num checkDigit = (theTotalSum / 10).ceil() * 10 - theTotalSum;
    //or
    // num checkDigit = (theTotalSum ~/ 10) * 10;
    // checkDigit = checkDigit < theTotalSum ? checkDigit + 10 : checkDigit;
    // checkDigit -= theTotalSum;

    print("TotalSum = $theTotalSum, and the last digit is $checkDigit.");
    return checkDigit;
  }

  ///********************************************************************************** */

  static List<int> getWeekNumber(DateTime date) {
    /// ISO 8601
    /// 


    /** This will not work for some of the flwg dates
 * // {DATE:"1970-01-02", WKNR:1},
// {DATE:"1970-01-03", WKNR:1},
// {DATE:"1970-01-04", WKNR:1},
// {DATE:"1970-01-05", WKNR:2},
// {DATE:"1970-01-06", WKNR:2},
// {DATE:"1970-01-07", WKNR:2},
// {DATE:"1970-01-08", WKNR:2},
// {DATE:"1970-01-09", WKNR:2},
// {DATE:"1970-01-10", WKNR:2},
// {DATE:"1970-12-22", WKNR:52},
// {DATE:"1970-12-23", WKNR:52},
// {DATE:"1970-12-24", WKNR:52},
// {DATE:"1970-12-25", WKNR:52},
// {DATE:"1970-12-26", WKNR:52},
// {DATE:"1970-12-27", WKNR:52},
// {DATE:"1970-12-28", WKNR:53},
// {DATE:"1970-12-29", WKNR:53},
// {DATE:"1970-12-30", WKNR:53},
// {DATE:"1970-12-31", WKNR:53},
// {DATE:"1971-01-01", WKNR:53},
// {DATE:"1971-01-02", WKNR:53},
// {DATE:"1971-01-03", WKNR:53},

 */

    // Set to nearest Thursday: current date + 4 - current day number
    // Make Sunday's day number 7
    var mutated_date = date.add(new Duration(days: (4 - date.weekday)));

    // print(mutated_date);

    // Get first day of year
    var yearStart = DateTime(mutated_date.year, 1, 1, 0, 0, 0);

    // Calculate full weeks to nearest Thursday
    var week_nr =
        (((mutated_date.difference(yearStart).inDays) + 1) / 7).ceil();

    //  the weeknr of 2017-01-01 is 52 of the year 2016
    print(" the weeknr of $date is $week_nr of the year ${mutated_date.year}");

    List<int> res = []..add(week_nr)..add(mutated_date.year);
    return res;
  }

}

