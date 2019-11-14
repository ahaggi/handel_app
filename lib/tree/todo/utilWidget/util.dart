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

  static int getweekNumber(DateTime date) {
    // Method: Using ISO weekday numbers (running from 1 for Monday to 7 for Sunday), subtract the weekday from the ordinal date, then add 10. Divide the result by 7. Ignore the remainder; the quotient equals the week number. If the week number thus obtained equals 0, it means that the given date belongs to the preceding (week-based) year. If a week number of 53 is obtained, one must check that the date is not actually in week 1 of the following year.
    var firstDayOfYear = DateTime.utc(date.year, 1, 1, 0, 0, 0);
    var dayOfYear = date.difference(firstDayOfYear).inDays + 1;
    var weekNr = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (weekNr == 0) weekNr = 52;
    if (weekNr == 53) weekNr = 1;

    return weekNr;
  }
}
