import 'package:research/services/functions.dart';
import 'package:test/test.dart';
import 'package:research/model/criteria.dart';
import 'package:research/model/location.dart';

const criteriaData = """
Direct Normal Irradiance 	Specific PV Power Output 	Global Horizontal Irradiance 	Air Temperature 	Average Slope of Terrain	Distance from Demand/Load Centers
0.27	0.27	0.27	0.09	0.06	0.04
4	4	4.5	25	8	20
min	min	min	max	max	max
""";

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

const normalizedData = """
Agoncillo	0.8628	0.9306	0.9342	0.9139	0.1321	0.1498
Alitagtag	0.7788	0.8981	0.8929	0.9721	0.3412	0.2686
Balayan	0.9181	0.9630	0.9643	0.9004	0.2973	0.3393
Balete	0.7854	0.8935	0.8947	0.9004	0.1730	0.1533
Batangas City	0.8562	0.9282	0.9323	0.9173	0.1492	0.2294
Bauan	0.8341	0.9190	0.7086	0.9208	0.2080	0.2980
Calaca	0.9137	0.9606	0.9624	0.9037	0.1946	0.3713
Calatagan	1.0000	1.0000	1.0000	0.9004	0.2192	0.1389
City of Tanauan	0.8319	0.9120	0.9117	0.9385	0.3725	0.1851
Cuenca	0.7633	0.8866	0.8835	0.9839	0.1364	0.2360
Ibaan	0.8429	0.9190	0.9229	0.9421	0.4452	0.3319
Laurel	0.8783	0.9329	0.9398	0.9071	0.1031	0.1263
Lemery	0.8164	0.9144	0.9154	0.9071	0.1754	0.2188
Lian	0.8296	0.9514	0.9511	0.9173	0.2441	0.1967
Lipa City	0.7832	0.8565	0.8628	0.9959	0.3394	0.1307
Lobo	0.8938	0.9144	0.9229	0.9421	0.0893	0.1115
Mabini	0.8938	0.9444	0.9492	0.9242	0.1116	0.1649
Malvar	0.8119	0.9074	0.9041	0.9531	0.3929	0.2392
Mataasnakahoy	0.7721	0.8889	0.8835	1.0000	0.1863	0.1303
Nasugbu	0.8341	0.9097	0.9117	0.9104	0.1470	0.0327
Padre Garcia	0.8363	0.9144	0.9192	0.9494	1.0000	0.1230
Rosario	0.8473	0.9190	0.9229	0.9421	0.3357	0.1104
San Jose	0.7965	0.8981	0.8985	0.9644	0.5452	0.3363
San Juan	0.9469	0.9722	0.9774	0.9242	0.2343	0.0655
San Luis	0.7854	0.8935	0.8985	0.9104	0.2164	0.1900
San Nicolas	0.8252	0.9074	0.9173	0.9071	0.2612	0.1009
San Pascual	0.8562	0.9259	0.9323	0.9242	0.7057	0.4672
Santa Teresita	0.7743	0.8773	0.8872	0.9173	0.3667	0.1751
Santo Tomas	0.8142	0.9051	0.9041	0.9385	0.2859	0.6281
Taal	0.8053	0.9051	0.9098	0.9139	0.4758	0.1362
Talisay	0.8451	0.9236	0.9248	0.9071	0.1242	0.1044
Taysan	0.8473	0.9236	0.9267	0.9349	0.2009	0.1075
Tingloy	0.9345	0.9597	0.9682	0.9173	0.0932	0.1122
Tuy	0.8511	0.9241	0.9256	0.9071	0.2807	1.0000
""";

List<Location> parseLocations(String data, List<Criteria> criterias) {
  var lines = data.split("\n");

  return lines.where((line) => line.isNotEmpty).map((line) {
    return Location.parseFromLine(line, criterias);
  }).toList();
}

List<Criteria> parseCriteriaData(String data) {
  var lines = data.split("\n");

  if (lines.length < 4) {
    throw const FormatException("Insufficient data to parse criteria.");
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
    throw const FormatException("Mismatch in the number of criteria elements.");
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

void main() {
  test("criteria parsing", () {
    var criterias = parseCriteriaData(criteriaData);
    expect(criterias.length, 6);
    expect(criterias[0].name, "Direct Normal Irradiance");
    expect(criterias[0].weight, 0.27);
    expect(criterias[0].targetValue, 4);
    expect(criterias[0].type, CriteriaType.min);
  });
  test("test normalize", () {
    var criterias = parseCriteriaData(criteriaData);
    var locations = parseLocations(testData, criterias);
    var normalizedLocations = locations.map((location) {
      return normalizeLocation(location, locations, criterias);
    }).toList();
    var expectedOutputs = parseLocations(normalizedData, criterias);

    expect(normalizedLocations.length, expectedOutputs.length);

    for (var i = 0; i < normalizedLocations.length; i++) {
      var normalizedLocation = normalizedLocations[i];
      var expectedLocation = expectedOutputs[i];

      expect(normalizedLocation.name, expectedLocation.name);

      for (var criteria in criterias) {
        var normalizedValue =
            normalizedLocation.normalizedValues[criteria.name]!;
        var expectedValue = expectedLocation.criteriaValues[criteria.name]!;
        expect(normalizedValue, closeTo(expectedValue, 0.1));
      }
    }
  });
}
