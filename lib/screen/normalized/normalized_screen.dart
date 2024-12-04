import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:research/model/criteria.dart';
import 'package:research/model/location.dart';
import 'package:research/services/functions.dart';

class NormalizedDataTableSource extends DataTableSource {
  final List<NormalizedLocation> normalized;

  NormalizedDataTableSource(this.normalized);

  @override
  DataRow? getRow(int index) {
    final e = normalized[index];
    return DataRow(
      // color: WidgetStatePropertyAll(
      //     index % 2 != 0 ? Colors.grey[100] : Colors.white),
      cells: [
        DataCell(Text(e.name, maxLines: 2)),
        ...e.normalizedValues.values
            .map((e) => DataCell(Text(e.toStringAsFixed(4)))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => normalized.length;

  @override
  int get selectedRowCount => 0;
}

class NormalizedScreen extends StatefulWidget {
  const NormalizedScreen({super.key});

  @override
  State<NormalizedScreen> createState() => _NormalizedScreenState();
}

class _NormalizedScreenState extends State<NormalizedScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    List<NormalizedLocation> normalized = args['normalized']!;
    List<Criteria> criterias = args["criterias"]!;

    final source = NormalizedDataTableSource(normalized);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Normalized Values"),
      ),
      body: Column(
        children: [
          Expanded(child: buildDataTable(source)),
          buildBottomRow(normalized, criterias),
        ],
      ),
    );
  }

  Widget buildDataTable(NormalizedDataTableSource source) {
    return SingleChildScrollView(
      child: PaginatedDataTable(
        source: source,
        headingRowHeight: 100,
        headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).primaryColor.withOpacity(0.2)),
        columns: [
          const DataColumn(label: Text("Name")),
          ...source.normalized.first.normalizedValues.keys
              .map((e) => DataColumn(
                      label: Text(
                    textAlign: TextAlign.center,
                    e,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ))),
        ],
      ),
    );
  }

  Widget buildBottomRow(
      List<NormalizedLocation> normalized, List<Criteria> criterias) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          FilledButton(
              onPressed: () {
                final calculatedLocations = normalized.map((location) {
                  final wsm = calculateWeightedSum(location, criterias);
                  final wpm = calculatWeightedPower(location, criterias);
                  final waspas = calculateWaspas(wsm, wpm);

                  return CalculatedLocation(
                      location.name,
                      location.criteriaValues,
                      location.normalizedValues,
                      wsm,
                      wpm,
                      waspas);
                });

                final targetWsm =
                    calculateTargetWeightedSum(normalized, criterias);
                final targetWpm =
                    calculateTargetWeightedPower(normalized, criterias);
                final targetWaspas = calculateWaspas(targetWsm, targetWpm);

                Navigator.of(context).pushNamed("/calculated", arguments: {
                  "calculated": calculatedLocations.toList(),
                  "targetWsm": targetWsm,
                  "targetWpm": targetWpm,
                  "targetWaspas": targetWaspas
                });
              },
              child: const Text("Calculate WASPAS"))
        ],
      ),
    );
  }
}
