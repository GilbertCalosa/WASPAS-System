import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:research/model/location.dart';

void exportAsPdf(List<CalculatedLocation> results, double targetWaspas) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
        build: (context) => buildPdfPage(context, results, targetWaspas)),
  );

  final output = await pdf.save();
  List<int> fileInts = List.from(output);

  final result = await FileSaver.instance
      .saveFile(name: "calculated.pdf", bytes: Uint8List.fromList(fileInts));
}

List<pw.Widget> buildPdfPage(
    pw.Context context, List<CalculatedLocation> results, double targetWaspas) {
  return [
    pw.Header(
      level: 0,
      child: pw.Text("Calculated Values"),
    ),
    pw.TableHelper.fromTextArray(
      context: null,
      data: [
        ["Rank", "Name", "WASPAS", "Remarks"],
        ...results.asMap().entries.map((entry) {
          final index = entry.key;
          final location = entry.value;
          return [
            (index + 1).toString(),
            location.name,
            location.waspas.toStringAsFixed(4),
            location.waspas < targetWaspas ? "Not Suitable" : "Suitable",
          ];
        }),
      ],
    ),
  ];
}
