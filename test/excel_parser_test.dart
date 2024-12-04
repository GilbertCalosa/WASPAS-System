import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:research/services/excel_parser.dart';
import 'package:test/test.dart';

void main() {
  const textExcelPath = "testData.xlsx";

  test("Parsing excel file", () async {
    final file = XFile(textExcelPath);
    expect(file, isNotNull);

    final parser = ExcelParser();
    final result = await parser.parse(file);

    expect(result, isNotNull);
    expect(result.criterias, isNotEmpty);
    expect(result.criterias, hasLength(6));
    expect(result.locations, isNotEmpty);
    expect(result.locations, hasLength(34));
  });
}
