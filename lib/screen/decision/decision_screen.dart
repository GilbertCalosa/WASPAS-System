import 'package:flutter/material.dart';
import 'package:research/model/location.dart';
import 'package:research/services/export_as_excel.dart';

class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    List<CalculatedLocation> calculated = args['calculated']!;

    // sort by waspas
    calculated.sort((b, a) => a.waspas.compareTo(b.waspas));

    double targetWaspas = args['targetWaspas']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculated Values"),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: buildDataTable(calculated, targetWaspas),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: () {
                    exportAsPdf(calculated, targetWaspas);
                  },
                  child: const Text("Save as PDF"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // columns: NAME, RANK, REMARKS (if waspas is less than target waspas) then remark is not suitable
  Widget buildDataTable(
      List<CalculatedLocation> calculated, double targetWaspas) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).primaryColor.withOpacity(0.2)),
        // dataRowColor: const WidgetStatePropertyAll(Colors.white),
        columns: const [
          DataColumn(label: Text("Rank")),
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("WASPAS")),
          DataColumn(label: Text("Remarks")),
        ],
        rows: [
          ...calculated.asMap().entries.map((entry) {
            CalculatedLocation e = entry.value;
            return DataRow(
              color: WidgetStatePropertyAll(
                entry.key % 2 != 0
                    ? Theme.of(context).primaryColor.withOpacity(0.2)
                    : Theme.of(context).colorScheme.surface,
              ),
              cells: [
                DataCell(Text((calculated.indexOf(e) + 1).toString())), // rank
                DataCell(Text(e.name)),
                DataCell(Text(e.waspas.toStringAsFixed(2))),
                DataCell(Text(
                    e.waspas < targetWaspas ? "Not Suitable" : "Suitable")),
              ],
            );
          }),
        ],
      ),
    );
  }
}
