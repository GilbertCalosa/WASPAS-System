import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:research/model/criteria.dart';

class CriteriaResult {
  final String? errorText;
  final List<Criteria> criterias;

  CriteriaResult(this.errorText, this.criterias);
}

Future<CriteriaResult?> showCriteriaInputDialog(BuildContext context) async {
  return showDialog<CriteriaResult>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        bool loading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Input Criterias Text"),
              content: loading
                  ? const Center(child: CircularProgressIndicator())
                  : TextField(
                      controller: controller,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      loading = true;
                    });

                    getCriteria(controller.text).then((value) {
                      Navigator.of(context).pop(CriteriaResult(null, value));
                    }).catchError((e) {
                      Navigator.of(context)
                          .pop(CriteriaResult(e.toString(), []));
                    });
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      });
}

Future<List<Criteria>> getCriteria(String input) async {
  try {
    final result = await compute(Criteria.parseCriteriaData, input);
    return result;
  } catch (e) {
    return Future.error(e);
  }
}
