import 'dart:math';
import 'package:research/model/criteria.dart';
import 'package:research/model/location.dart';
import 'package:research/services/functions.dart';

const testData = """
Agoncillo	3.90	4.02	4.97	26.70	14.16	15.22
Alitagtag	3.52	3.88	4.75	25.10	5.48	8.49
Balayan	4.15	4.16	5.13	27.10	6.29	6.72
Balete	3.55	3.86	4.76	27.10	10.81	14.87
Batangas City	3.87	4.01	4.96	26.60	12.53	9.94
Bauan	3.77	3.97	3.77	26.50	8.99	7.65
Calaca	4.13	4.15	5.12	27.00	9.61	6.14
Calatagan	4.52	4.32	5.32	27.10	8.53	16.42
City of Tanauan	3.76	3.94	4.85	26.00	5.02	12.32
Cuenca	3.45	3.83	4.70	24.80	13.71	9.66
Ibaan	3.81	3.97	4.91	25.90	4.20	6.87
Laurel	3.97	4.03	5.00	26.90	18.13	18.05
Lemery	3.69	3.95	4.87	26.90	10.66	10.42
Lian	3.75	4.11	5.06	26.60	7.66	11.59
Lipa City	3.54	3.70	4.59	24.50	5.51	17.44
Lobo	4.04	3.95	4.91	25.90	20.93	20.44
Mabini	4.04	4.08	5.05	26.40	16.75	13.83
Malvar	3.67	3.92	4.81	25.60	4.76	9.53
Mataasnakahoy	3.49	3.84	4.70	24.40	10.04	17.50
Nasugbu	3.77	3.93	4.85	26.80	12.72	69.71
Padre Garcia	3.78	3.95	4.89	25.70	1.87	18.53
Rosario	3.83	3.97	4.91	25.90	5.57	20.66
San Jose	3.60	3.88	4.78	25.30	3.43	6.78
San Juan	4.28	4.20	5.20	26.40	7.98	34.79
San Luis	3.55	3.86	4.78	26.80	8.64	12.00
San Nicolas	3.73	3.92	4.88	26.90	7.16	22.60
San Pascual	3.87	4.00	4.96	26.40	2.65	4.88
Santa Teresita	3.50	3.79	4.72	26.60	5.10	13.02
Santo Tomas	3.68	3.91	4.81	26.00	6.54	3.63
Taal	3.64	3.91	4.84	26.70	3.93	16.74
Talisay	3.82	3.99	4.92	26.90	15.06	21.84
Taysan	3.83	3.99	4.93	26.10	9.31	21.21
Tingloy	4.22	4.15	5.15	26.60	20.06	20.32
Tuy	3.85	3.99	4.92	26.90	6.66	2.28
""";

List<Location> parseData(String data, List<Criteria> criterias) {
  var lines = data.split("\n");

  return lines.where((line) => line.isNotEmpty).map((line) {
    return Location.parseFromLine(line, criterias);
  }).toList();
}

void main() {
  final criteriaList = [
    Criteria("Direct Normal Irradiance", 0.27, 4, CriteriaType.min),
    Criteria("Specific PV Power Output", 0.27, 4, CriteriaType.min),
    Criteria("Global Horizontal Irradiance", 0.27, 4.5, CriteriaType.min),
    Criteria("Air Temperature", 0.09, 25, CriteriaType.max),
    Criteria("Average Slope of Terrain", 0.06, 8, CriteriaType.max),
    Criteria("Distance from Demand/Load Centers", 0.04, 20, CriteriaType.max),
  ];

  final locations = parseData(testData, criteriaList);

  for (final location in locations) {}
}

void testLocation(
    Location location, List<Location> locations, List<Criteria> criteriaList) {
  final normalizedLocation =
      normalizeLocation(location, locations, criteriaList);
  print(normalizedLocation);

  final weightedSum = calculateWeightedSum(normalizedLocation, criteriaList);
  print(weightedSum);

  final weightedPower = calculatWeightedPower(normalizedLocation, criteriaList);
  print(weightedPower);

  final waspas = calculateWaspas(weightedSum, weightedPower);
  print(waspas);

  for (var criteria in criteriaList) {
    final normalizedTargetValue =
        criteria.calculateNormalizedTargetValue(locations);
    print(
        "Normalized Target Value for ${criteria.name}: $normalizedTargetValue");
  }

  final targetWeightedSum = calculateTargetWeightedSum(locations, criteriaList);
  print("Target Weighted Sum: $targetWeightedSum");

  final targetWeightedPower =
      calculateTargetWeightedPower(locations, criteriaList);
  print("Target Weighted Power: $targetWeightedPower");

  final targetWaspas = calculateWaspas(targetWeightedSum, targetWeightedPower);
  print("WASPAS: $targetWaspas");
}
