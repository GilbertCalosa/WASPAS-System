import 'package:research/model/location.dart';
import 'package:research/services/functions.dart';

enum CriteriaType { min, max }

class Criteria {
  final String name;
  final double weight;
  final double targetValue;
  final CriteriaType type;

  Criteria(this.name, this.weight, this.targetValue, this.type);

  double calculateNormalizedTargetValue(List<Location> locations) {
    if (type == CriteriaType.min) {
      final max = locations.map((e) => e.criteriaValues[name]!).max();
      return targetValue / max;
    } else {
      final min = locations.map((e) => e.criteriaValues[name]!).min();
      return min / targetValue;
    }
  }

  static List<Criteria> parseCriteriaData(String data) {
    var lines = data.split("\n");

    if (lines.length < 4) {
      throw FormatException(
          "Insufficient data to parse criteria. Length: ${lines.length}");
    }

    final criteriaNames = lines[0].split("\t");
    final criteriaWeights = lines[1].split("\t").map((e) {
      try {
        return double.parse(e);
      } catch (e) {
        throw FormatException("Invalid weight value: $e");
      }
    }).toList();
    final criteriaTargetValues = lines[2].split("\t").map((e) {
      try {
        return double.parse(e);
      } catch (e) {
        throw FormatException("Invalid target value: $e");
      }
    }).toList();
    final criteriaTypes = lines[3].split("\t");

    if (criteriaNames.length != criteriaWeights.length ||
        criteriaNames.length != criteriaTargetValues.length ||
        criteriaNames.length != criteriaTypes.length) {
      throw const FormatException(
          "Mismatch in the number of criteria elements.");
    }

    Criteria createCriteria(int index) {
      return Criteria(
        criteriaNames[index].trim(),
        criteriaWeights[index],
        criteriaTargetValues[index],
        criteriaTypes[index] == "min" ? CriteriaType.min : CriteriaType.max,
      );
    }

    return List.generate(criteriaNames.length, createCriteria);
  }
}
