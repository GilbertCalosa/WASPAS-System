// min = value / MAX(DATA VALUES)
// max = MIN(DATA VALUES) / value
import 'dart:math';

import 'package:research/model/criteria.dart';
import 'package:research/model/location.dart';

double normalize(
    List<Location> locations, Location location, Criteria criteria) {
  final value = location.criteriaValues[criteria.name]!;
  final type = criteria.type;

  if (type == CriteriaType.min) {
    final max = locations.map((e) => e.criteriaValues[criteria.name]!).max();
    return value / max;
  } else {
    final min = locations.map((e) => e.criteriaValues[criteria.name]!).min();
    return min / value;
  }
}

NormalizedLocation normalizeLocation(
    Location location, List<Location> locations, List<Criteria> criterias) {
  // check that the location has all the criterias
  final locationCriterias = location.criteriaValues.keys.toList();
  final missingCriterias = criterias
      .where((element) => !locationCriterias.contains(element.name))
      .toList();
  if (missingCriterias.isNotEmpty) {
    throw Exception(
        "Location is missing criterias: ${missingCriterias.map((e) => e.name).toList()}");
  }

  final normalizedValues = location.criteriaValues.map((key, value) {
    final criteria = criterias.firstWhere((element) => element.name == key);
    return MapEntry(key, normalize(locations, location, criteria));
  });

  return NormalizedLocation(
    location.name,
    location.criteriaValues,
    normalizedValues,
  );
}

double calculateTargetWeightedSum(
    List<Location> locations, List<Criteria> criterias) {
  final targetValues = criterias
      .map((criteria) => criteria.calculateNormalizedTargetValue(locations))
      .toList();
  final weights = criterias.map((e) => e.weight).toList();

  return calculatedWsm(weights, targetValues);
}

///=SUMPRODUCT($SE_Norm.$C$4:$H$4,$SE_Norm.C7:H7)
/// where $SE_Norm.$C$4:$H$4 is the weights
/// and $SE_Norm.C7:H7 is the normalized values
double calculateWeightedSum(
    NormalizedLocation location, List<Criteria> criterias) {
  final weights = criterias.map((e) => e.weight).toList();
  final normalizedValues = location.normalizedValues.values.toList();

  return calculatedWsm(weights, normalizedValues);
}

double calculatedWsm(List<double> weights, List<double> normalizedValues) {
  return weights
      .asMap()
      .entries
      .map((e) => e.value * normalizedValues[e.key])
      .reduce((value, element) => value + element);
}

double calculateTargetWeightedPower(
    List<Location> locations, List<Criteria> criterias) {
  final targetNormalizedValues = criterias
      .map((criteria) => criteria.calculateNormalizedTargetValue(locations))
      .toList();
  final weights = criterias.map((e) => e.weight).toList();
  return calculateWpm(targetNormalizedValues, weights);
}

// =($SE_Norm.C7^$SE_Norm.$C$4)*($SE_Norm.D7^$SE_Norm.$D$4)*($SE_Norm.E7^$SE_Norm.$E$4)*($SE_Norm.F7^$SE_Norm.$F$4)*($SE_Norm.G7^$SE_Norm.$G$4)*($SE_Norm.H7^$SE_Norm.$H$4)
// where $SE_Norm.C7:H7 is the normalized values
double calculatWeightedPower(
    NormalizedLocation location, List<Criteria> criterias) {
  final normalizedValues = location.normalizedValues.values.toList();
  final weights = criterias.map((e) => e.weight).toList();

  return calculateWpm(normalizedValues, weights);
}

double calculateWpm(List<double> normalizedValues, List<double> weights) {
  return normalizedValues
      .asMap()
      .entries
      // power of value and weight
      .map((e) => pow(e.value, weights[e.key]).toDouble())
      .reduce((value, element) => value * element);
}

// waspas
double calculateWaspas(double wsm, double wpm) {
  return (0.5 * wsm) + (0.5 * wpm);
}

// .min() extension method for List<double>, returns the minimum value in the list
extension Min on Iterable<double> {
  double min() {
    return reduce((value, element) => value < element ? value : element);
  }
}

// .max() extension method for List<double>, returns the maximum value in the list
extension Max on Iterable<double> {
  double max() {
    return reduce((value, element) => value > element ? value : element);
  }
}
