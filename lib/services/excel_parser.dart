import 'package:excel/excel.dart';
import 'package:cross_file/cross_file.dart';
import 'package:research/model/criteria.dart';
import 'package:research/model/location.dart';

class ParseResult {
  final List<Criteria> criterias;
  final List<Location> locations;

  ParseResult(this.criterias, this.locations);
}

class ExcelParser {
  Future<ParseResult> parse(XFile file) async {
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    // throw if the file is empty
    if (excel.sheets.isEmpty) {
      throw Exception("The file is empty");
    }

    // if there are multiple sheets, throw
    if (excel.sheets.length > 1) {
      throw Exception(
          "The file has multiple sheets, only one sheet is allowed");
    }

    // get the first sheet
    var sheet = excel.sheets.values.first;

    String endLetter = "";

    try {
      const start = "2";
      const startLetter = "C";

      int current = 0;
      CellValue? cellValue = sheet.cell(CellIndex.indexByString('C2')).value;

      while (cellValue != null) {
        final currentLetter =
            String.fromCharCode(startLetter.codeUnitAt(0) + current);

        cellValue =
            sheet.cell(CellIndex.indexByString("${currentLetter}2")).value;

        current++;
      }

      final end = current - 2;
      endLetter = String.fromCharCode(startLetter.codeUnitAt(0) + end);
    } catch (e) {
      throw Exception("The file is not in the correct format: $e");
    }

    // the distance between the start and end letter is the number of criteria
    final criteriaCount = endLetter.codeUnitAt(0) - "C".codeUnitAt(0) + 1;
    final endLetterIndex = criteriaCount + 2;

    List<Criteria> criterias = [];

    // now from the criterias should be from C2 to endLetter5
    // currentLetter2 = Criteria name
    // currentLetter3 = Weight
    // currentLetter4 = Target
    // currentLetter5 = Min/Max
    for (var i = 2; i < endLetterIndex; i++) {
      final currentLetter = String.fromCharCode("C".codeUnitAt(0) + i - 2);

      final criteriaName = sheet
          .cell(CellIndex.indexByString("${currentLetter}2"))
          .value
          ?.toString();
      if (criteriaName == null) {
        throw Exception(
            "Expected a criteria name at ${currentLetter}2 but none found");
      }

      final weight = sheet
          .cell(CellIndex.indexByString("$currentLetter${3}"))
          .value
          ?.toString();
      if (weight == null) {
        throw Exception(
            "Expected a weight at $currentLetter${3} but none found");
      }

      final target = sheet
          .cell(CellIndex.indexByString("$currentLetter${4}"))
          .value
          ?.toString();
      if (target == null) {
        throw Exception(
            "Expected a target at $currentLetter${4} but none found");
      }

      final minMax = sheet
          .cell(CellIndex.indexByString("$currentLetter${5}"))
          .value
          ?.toString();
      if (minMax == null) {
        throw Exception(
            "Expected a min/max at $currentLetter${5} but none found");
      }

      final minMaxType = minMax.toUpperCase() == "MIN"
          ? CriteriaType.min
          : minMax.toUpperCase() == "MAX"
              ? CriteriaType.max
              : throw Exception(
                  "Expected a min/max value of either MIN or MAX but found $minMax at $currentLetter${5}");

      final criteria = Criteria(
        criteriaName,
        double.parse(weight),
        double.parse(target),
        minMaxType,
      );
      criterias.add(criteria);
    }

    // now we need to get the locations
    // location name starts at B6
    List<Location> locations = [];

    while (true) {
      try {
        final location = getLocationAt(sheet, locations.length + 6, criterias);
        locations.add(location);
      } catch (e) {
        if (locations.isEmpty) {
          throw Exception("No locations found in the file: $e");
        }
        break;
      }
    }

    if (locations.isEmpty) {
      throw Exception("No locations found");
    }

    return ParseResult(criterias, locations);
  }

  Location getLocationAt(Sheet sheet, int column, List<Criteria> criterias) {
    final locationName =
        sheet.cell(CellIndex.indexByString("B$column")).value?.toString();
    if (locationName == null) {
      throw Exception("Expected a location name at B$column but none found");
    }

    final criteriaValues = <String, double>{};
    for (var i = 0; i < criterias.length; i++) {
      final letter = String.fromCharCode("C".codeUnitAt(0) + i);
      final value = sheet
          .cell(CellIndex.indexByString("$letter$column"))
          .value
          ?.toString();

      if (value == null) {
        throw Exception("Expected a value at $letter$column but none found");
      }

      criteriaValues[criterias[i].name] = double.parse(value);
    }
    return Location(locationName, criteriaValues);
  }
}
