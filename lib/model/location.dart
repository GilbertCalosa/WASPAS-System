import 'package:research/model/criteria.dart';

class Location {
  final String name;
  final Map<String, double> criteriaValues;

  Location(this.name, this.criteriaValues);

  @override
  String toString() {
    return 'Location{name: $name, criteriaValues: $criteriaValues}';
  }

  static Location parseFromLine(String line, List<Criteria> criterias) {
    var parts = line.split("\t");
    final name = parts[0];
    final values = parts.sublist(1).map((e) => double.parse(e)).toList();

    // values length should be equal to criterias length
    if (values.length != criterias.length) {
      throw Exception(
          "Values length should be equal to criterias length [Values: ${values.length}, Criterias: ${criterias.length}]\n Line: $line");
    }

    return Location(
        name, Map.fromIterables(criterias.map((e) => e.name), values));
  }

  static List<Location> parse(String input, List<Criteria> criterias) {
    return input
        .split("\n")
        .where((e) => e.isNotEmpty)
        .map((e) => parseFromLine(e, criterias))
        .toList();
  }
}

/// A marker class for normalized locations
class NormalizedLocation extends Location {
  final Map<String, double> normalizedValues;

  NormalizedLocation(super.name, super.criteriaValues, this.normalizedValues);

  @override
  String toString() {
    return 'NormalizedLocation{name: $name, criteriaValues: $criteriaValues, normalizedValues: $normalizedValues}';
  }
}

class CalculatedLocation extends NormalizedLocation {
  final double weightedSum;
  final double weigtedPower;
  final double waspas;

  CalculatedLocation(super.name, super.criteriaValues, super.normalizedValues,
      this.weightedSum, this.weigtedPower, this.waspas);
}
