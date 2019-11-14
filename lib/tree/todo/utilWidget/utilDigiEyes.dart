import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:async';
import 'package:handle_app/config/attrconfig.dart';

class UtilDigiEyes {
  static Map<String, dynamic> getToken(String barcode) {
//old
// /3wCYrJ6Ai8y
// Mb37D1v9u3Nh9Yk2

// Your application id is:   /xLfi56v5ves
// Your user key is:         Wr17U8m8s0Xh5Ju4

    var appKey = "/wyPJha3W4C9";
    var userKey = "Gi58G3f1v0Yx5Fa8"; // AUTH. KEY for digit-eyes.com API

    var key = utf8.encode(userKey);
    var bytes = utf8.encode(barcode);

    var hmacSha1 = new Hmac(sha1, key); // HMAC-SHA1
    var digest = hmacSha1.convert(bytes);

    var digestedByte = digest.bytes;
    var digestedBase64 = base64.encode(digest.bytes);

    print("HMAC digest as bytes: $digestedByte");
    print("HMAC digest as base64 string: $digestedBase64");
    Map<String, dynamic> resp = {
      "userKey": userKey,
      "appKey": appKey,
      "signature": digestedBase64
    };
    return resp;
  }

  static Map<String, dynamic> populateProduktInfoFromResp(
      Map<String, dynamic> resp) {
    // final String rand = "${new Random().nextInt(10000)}";
    print(resp);
    Map<String, dynamic> produkt = {


      NAVN: "",
      STREKKODE: "",
      KOMMENTAR: "",
      NETTOVEKT: "",
      INFO: {
        NAERINGSINNHOLD: Map<String, dynamic>()
          ..addAll({
            ENERGI: "0",
            KALORIER: "0",
            FETT: "0",
            METTET_FETT: "0",
            ENUMETTET: "0",
            FLERUMETTET: "0",
            KARBOHYDRATER: "0",
            SUKKERARTER: "0",
            STIVELSE: "0",
            KOSTFIBER: "0",
            PROTEIN: "0",
            SALT: "0",
          })
      },
      ER_LEOSVEKT: true,
      ER_MATVARE: true,
    };
    if (resp != null) {
      String description =
          resp['description'] != null ? resp["description"] : "";
      String brand = resp["brand"] != null ? resp["brand"] : "";

      produkt[NAVN] = description + " - " + brand;

      produkt[STREKKODE] =
          resp['upc_code'] != null ? resp["upc_code"].toString() : "";
      produkt[KOMMENTAR] = resp["uom"] != null ? resp["uom"] : "";
      produkt[NETTOVEKT] = ""; //"manualt"

      if (resp["nutrition"] != null)
        produkt[INFO][NAERINGSINNHOLD] =
            populateNutritionUsingregexCapturingGroup(
                resp["nutrition"], produkt[INFO][NAERINGSINNHOLD]);

      produkt[ER_MATVARE] =
          resp["nutrition"] != null && resp["nutrition"] != "null";
    }
    return produkt;
  }

  static Map<String, dynamic> populateNutritionUsingregexCapturingGroup(
      String nutrition, Map<String, dynamic> naeringsinnhold) {
    int ndx = nutrition.indexOf(RegExp(r'Energi', caseSensitive: false));
    String trimmedNutrition = ndx > 0 ? nutrition.substring(ndx) : nutrition;
    print(trimmedNutrition);

    RegExp exp = new RegExp(r"([a-zA-Z :]*) (\d+[,|.]?\d*) ([kj|kcal|g]*){1}",
        caseSensitive:
            false); //trim the spaces in the first group of each match

    Map<String, dynamic> scannedInfo = {};
    Iterable<Match> matches = exp.allMatches(trimmedNutrition);
    for (Match m in matches) {
      //TODO finn bedre løsning med lookbehind
      if (m.group(3).isEmpty)
        continue; // for å se bort fra næringsinnholder som ikke har (kcal , kj eller g) benevninger. for eks   Salt 0 mg

      // m.group(i) Returns the string matched by the given group.  If group is 0, returns the match of the pattern.
      //m.group(0) = Energi 188 kj
      //m.group(1) = Energi
      //m.group(2) = 188
      //m.group(2) = kj

      // karbohydrater        =  1
      var key = m.group(1).trim();
      var value = m.group(2).replaceAll(new RegExp(r','), '.');
      scannedInfo[key] = value;
    }
    naeringsinnhold.forEach((k, v) {
      String k1 = k;
      if (scannedInfo[k] == null) {
        // Hvis scannedInfo inholder en nækkel "Flerumettet Fett" i stedenfor FLERUMETTET
        k1 =
            scannedInfo.keys.firstWhere((str) => str.startsWith(k), orElse: () {
          scannedInfo[k1] = naeringsinnhold[k];
          return k;
        });
      }
      naeringsinnhold[k] = scannedInfo[k1];
    });

    return naeringsinnhold;
  }

  static dynamic processBarCode(String barcode) async {
    print(
        "objectobjectobjectobjectobjectobjectobje   $barcode   ctobjectobjectobjectobjectobjectobjectobjectobject");
    Map<String, dynamic> token = getToken(barcode);
    String signature = token["signature"];
    String appKey = token["appKey"];

    String uri =
        "https://www.digit-eyes.com/gtin/v2_0/?upcCode=$barcode&field_names=all, description, usage, brand, gcp_name_address, ingredients, language, nutrition, manufacturer, website, product_web_page, image, uom&language=en&app_key=$appKey&signature=$signature";
    print(uri);
    final response = await http.get(uri);
    Map<String, dynamic> resp_produkt = {
      NAVN: "mockNavn",
      STREKKODE: barcode,
      KOMMENTAR: "mockkommentar",
      NETTOVEKT: "mockNettovekt",
      ER_LEOSVEKT: true,
      ER_MATVARE: true,

      INFO: {
        NAERINGSINNHOLD: Map<String, dynamic>()
          ..addAll({
            ENERGI: "1",
            KALORIER: "2",
            FETT: "3",
            ENUMETTET: "4",
            FLERUMETTET: "5",
            METTET_FETT: "6",
            KARBOHYDRATER: "7",
            SUKKERARTER: "8",
            STIVELSE: "9",
            KOSTFIBER: "10",
            PROTEIN: "11",
            SALT: "12",
          })
      },
    };
    if (response.statusCode == 200 ) {
      // If server returns an OK response, parse the JSON
      var resBody = json.decode(response.body);
      if(resBody["return_code"]!= "667")
      resp_produkt = populateProduktInfoFromResp(resBody);
    }

    /**¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ mockData ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ */
    // if (barcode == "7038010055690")
    //   resp_produkt = populateProduktInfoFromResp( resp_body_7038010055690);
    // else
    //   resp_produkt = populateProduktInfoFromResp( resp_body_7035620033995);
    /**¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ end mockData ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ */

    return resp_produkt;
  }
}
