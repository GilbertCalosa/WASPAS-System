import 'package:flutter/material.dart';
import 'package:research/model/criteria.dart';
import 'package:research/model/location.dart';

class LocationResult {
  final String? errorText;
  final List<Location> locations;

  LocationResult(this.errorText, this.locations);
}

Future<LocationResult?> showLocationInputDialog(
    BuildContext context, List<Criteria> currentCriterias) async {
  return showDialog<LocationResult>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          title: const Text("Input Locations Text"),
          content: TextField(
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
                try {
                  List<Location> locations =
                      Location.parse(controller.text, currentCriterias);
                  Navigator.of(context).pop(LocationResult(null, locations));
                } catch (e) {
                  Navigator.of(context).pop(LocationResult(e.toString(), []));
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      });
}
