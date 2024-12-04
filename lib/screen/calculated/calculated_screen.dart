import 'package:flutter/material.dart';
import 'package:research/model/location.dart';

class CalculatedScreen extends StatefulWidget {
  const CalculatedScreen({super.key});

  @override
  State<CalculatedScreen> createState() => _CalculatedScreenState();
}

class _CalculatedScreenState extends State<CalculatedScreen> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    List<CalculatedLocation> calculated = args['calculated']!;
    double targetWaspas = args['targetWaspas']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculated Values"),
      ),
      body: Column(
        children: [
          Expanded(
            child: buildDataTable(calculated, targetWaspas),
            flex: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/decision", arguments: args);
                  },
                  child: const Text("Decision"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDataTable(
      List<CalculatedLocation> calculated, double targetWaspas) {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
            Theme.of(context).primaryColor.withOpacity(0.2)),
        columns: const [
          DataColumn(label: Text("Name")),
          DataColumn(label: Text("Weighted Sum")),
          DataColumn(label: Text("Weighted Power")),
          DataColumn(label: Text("WASPAS")),
        ],
        rows: [
          ...calculated.asMap().entries.map((entry) {
            CalculatedLocation e = entry.value;
            return DataRow(
              color: WidgetStatePropertyAll(entry.key % 2 != 0
                  ? Theme.of(context).primaryColor.withOpacity(0.2)
                  : Theme.of(context).colorScheme.surface),
              cells: [
                DataCell(Text(e.name)),
                DataCell(Text(e.weightedSum.toStringAsFixed(4))),
                DataCell(Text(e.weigtedPower.toStringAsFixed(4))),
                DataCell(Text(e.waspas.toStringAsFixed(4))),
              ],
            );
          }),
        ],
      ),
    );
  }
}
