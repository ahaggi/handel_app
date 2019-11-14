import 'dart:math';

import './Tuple.dart';

class UtilLevDistance  {
  static List<Tuple<String,String>> getSuggestions(
      {String input = "", Map<String,String> data, int nrOfSuggestion = 5}) {

    
    Map<String, int> allDistanceCosts = Map<String, int>();

    Stopwatch perf = new Stopwatch();
    perf.start();

    data.forEach((k,v) {
      allDistanceCosts[k] =
          _calcWithDynamicProgramming(input.toLowerCase(), v.toLowerCase());
    });

    allDistanceCosts.removeWhere((k, v) => v > COSTTRESHOLD);

    List<String> _keys = allDistanceCosts.keys.toList();

    _keys.sort((elm1, elm2) =>
        allDistanceCosts[elm1].compareTo(allDistanceCosts[elm2]));

    print("The costs are calculated in ${perf.elapsedMilliseconds}ms");
    perf.stop();

    List<String> res = _keys.sublist(
        0, nrOfSuggestion < _keys.length ? nrOfSuggestion : _keys.length);


        return res.map((id)=> Tuple(id , data[id])).toList();
  }

//TODO assign diffrent cost for each operation
  static num INSERTION_COST = 0;
  static num DELETION_COST = 1;
  static num SUBSTITUTION_COST = 2;
  static num COSTTRESHOLD = 1;

  static int _costOfSubstitution({String char1, String char2}) {
    assert(char1.length == 1);
    assert(char2.length == 1);
    return char1 == char2 ? 0 : SUBSTITUTION_COST;
  }

/************************************************************************************** */
/*************************************ALternativly************************************* */
/************************************************************************************** */

  static int _calcWithDynamicProgramming(String x, String y) {
    List<List<int>> dp = List.generate(x.length + 1, (int ndx) {
      return List<int>(y.length + 1);
    });
    // print("$x , $y");

    for (int i = 0; i <= x.length; i++) {
      for (int j = 0; j <= y.length; j++) {
        if (i == 0) {
          dp[i][j] = j;
        } else if (j == 0) {
          dp[i][j] = i;
        } else {
          var char1 = x.substring(i - 1, i);
          var char2 = y.substring(j - 1, j);

          dp[i][j] = [
            dp[i - 1][j - 1] + _costOfSubstitution(char1: char1, char2: char2),
            dp[i - 1][j] + DELETION_COST, //cost of deleting a char from x
            dp[i][j - 1] + INSERTION_COST //cost of inserting a char in x from y
          ].reduce(min);
        }
      }
      // print("${dp[i]}");
    }
    // List<int> t = List.generate(x.length + 1, (ind) {
    //   return dp[ind].reduce(min);
    // });

    return dp[x.length][y.length];
  }
}


  // num INSERTION_COST = 0;
  // num DELETION_COST = 1;
  // num SUBSTITUTION_COST = 2;

  // void noe(String qry, List<String> data) {
  //   Map<String, int> allDistanceCosts = Map<String, int>();

  //   Stopwatch perf = new Stopwatch();
  //   perf.start();

  //   data.forEach((t) {
  //     allDistanceCosts[t] =
  //         calcWithDynamicProgramming(qry.toLowerCase(), t.toLowerCase());
  //   });

  //   //TODO bruk SplayTree
  //   data.sort((k1, k2) => allDistanceCosts[k1].compareTo(allDistanceCosts[k2]));

  //   for (var i = 0; i < 10; i++)
  //     print("${data[i]} ${allDistanceCosts[data[i]]}");

  //   print("The costs are calculated in ${perf.elapsedMilliseconds}ms");

  //   perf.stop();
  // }

  // int costOfSubstitution({String char1, String char2}) {
  //   assert(char1.length == 1);
  //   assert(char2.length == 1);
  //   return char1 == char2 ? 0 : SUBSTITUTION_COST;
  // }

  // int calcWithDynamicProgramming(String x, String y) {
  //   List<List<int>> dp = List.generate(x.length + 1, (int ndx) {
  //     return List<int>(y.length + 1);
  //   });
  //   print("$x , $y");

  //   for (int i = 0; i <= x.length; i++) {
  //     for (int j = 0; j <= y.length; j++) {
  //       if (i == 0) {
  //         dp[i][j] = j;
  //       } else if (j == 0) {
  //         dp[i][j] = i;
  //       } else {
  //         var char1 = x.substring(i - 1, i);
  //         var char2 = y.substring(j - 1, j);

  //         dp[i][j] = [
  //           dp[i - 1][j - 1] + costOfSubstitution(char1: char1, char2: char2),
  //           dp[i - 1][j] + DELETION_COST, //cost of deleting a char from x
  //           dp[i][j - 1] + INSERTION_COST //cost of inserting a char in x from y
  //         ].reduce(min);
  //       }
  //     }
  //     print("${dp[i]}");
  //   }
  //   // List<int> t = List.generate(x.length + 1, (ind) {
  //   //   return dp[ind].reduce(min);
  //   // });

  //   return dp[x.length][y.length];
  // }