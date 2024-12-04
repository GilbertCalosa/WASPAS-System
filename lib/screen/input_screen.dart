import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:research/model/criteria.dart';
import 'package:research/model/energy_type.dart';
import 'package:research/model/location.dart';
import 'package:research/screen/criteria_input_dialog.dart';
import 'package:research/screen/location_input_dialog.dart';
import 'package:research/services/excel_parser.dart';
import 'package:research/services/functions.dart';

const solarEnergyDefaultCriteria = """
Direct Normal Irradiance 	Specific PV Power Output 	Global Horizontal Irradiance 	Air Temperature 	Average Slope of Terrain	Distance from Demand/Load Centers
0.27	0.27	0.27	0.09	0.06	0.04
4	4	4.5	25	8	20
min	min	min	max	max	max
""";

const windEnergyDefaultCriteria = """
Mean Wind Speed at 100m height	Mean Power Density at 100m height	Orography	Roughness length	Distance from Demand/Load Centers
0.3440	0.3440	0.1650	0.1000	0.0470
5	500	200	0.2	20
min	min	min	max	max
""";

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class CriteriaStateHolder {
  Criteria criteria;
  final List<TextEditingController> controllers =
      List.generate(3, (index) => TextEditingController());

  CriteriaStateHolder(this.criteria) {
    controllers[0].text = criteria.name;
    controllers[1].text = criteria.weight.toString();
    controllers[2].text = criteria.targetValue.toString();

    // observe
    controllers[0].addListener(() {
      criteria = Criteria(
        controllers[0].text,
        criteria.weight,
        criteria.targetValue,
        criteria.type,
      );
    });
    controllers[1].addListener(() {
      criteria = Criteria(
        criteria.name,
        double.tryParse(controllers[1].text) ?? 0,
        criteria.targetValue,
        criteria.type,
      );
    });
    controllers[2].addListener(() {
      criteria = Criteria(
        criteria.name,
        criteria.weight,
        double.tryParse(controllers[2].text) ?? 0,
        criteria.type,
      );
    });
  }
}

class LocationStateHolder {
  Location location;
  final List<TextEditingController> controllers = [];
  final TextEditingController nameController = TextEditingController();

  LocationStateHolder(this.location, int criteriaCount) {
    nameController.text = location.name;

    controllers.addAll(
        List.generate(criteriaCount, (index) => TextEditingController()));

    location.criteriaValues.forEach((key, value) {
      final index = location.criteriaValues.keys.toList().indexOf(key);
      controllers[index].text = value.toString();
    });
  }

  void criteriaAdded() {
    controllers.add(TextEditingController());
  }
}

class _InputScreenState extends State<InputScreen> {
  List<CriteriaStateHolder> criterias = [];
  List<LocationStateHolder> locations = [];

  bool _dragging = false;
  bool _parsing = false;
  String? error;

  void _onDropDone(DropDoneDetails details) {
    // preliminary checks
    setState(() {
      _dragging = false;
    });

    if (details.files.isEmpty) {
      return;
    }

    final file = details.files.first;
    parse(file);
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result != null) {
      parse(result.xFiles.first);
    }
  }

  void parse(XFile file) async {
    setState(() {
      _parsing = true;
      error = null;
    });

    final parser = ExcelParser();
    compute(parser.parse, file).then((result) {
      setState(() {
        _parsing = false;
        if (result.criterias.isNotEmpty && result.locations.isNotEmpty) {
          // if there are already criterias, ask the user if they want to replace them or merge them
          if (criterias.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Replace or Merge"),
                  content: const Text(
                      "Do you want to replace the existing criterias or merge them with the new ones?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          criterias = result.criterias
                              .map((e) => CriteriaStateHolder(e))
                              .toList();
                          locations = result.locations
                              .map((e) =>
                                  LocationStateHolder(e, criterias.length))
                              .toList();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Replace"),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          criterias.addAll(result.criterias
                              .map((e) => CriteriaStateHolder(e)));
                          for (var location in locations) {
                            location.criteriaAdded();
                          }
                          locations.addAll(result.locations.map(
                              (e) => LocationStateHolder(e, criterias.length)));
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Merge"),
                    ),
                  ],
                );
              },
            );
          } else {
            setState(() {
              criterias =
                  result.criterias.map((e) => CriteriaStateHolder(e)).toList();
              locations = result.locations
                  .map((e) => LocationStateHolder(e, criterias.length))
                  .toList();
            });
          }
        } else {
          error = "Invalid file format. Please try again.";
        }
      });
    }).catchError((e) {
      setState(() {
        _parsing = false;
        error = e.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final type = ModalRoute.of(context)?.settings.arguments as EnergyType? ??
        EnergyType.solar;

    if (criterias.isEmpty) {
      if (type == EnergyType.solar) {
        getCriteria(solarEnergyDefaultCriteria).then((value) {
          setState(() {
            criterias = value.map((e) => CriteriaStateHolder(e)).toList();
          });
        });
      } else {
        getCriteria(windEnergyDefaultCriteria).then((value) {
          setState(() {
            criterias = value.map((e) => CriteriaStateHolder(e)).toList();
          });
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Screen - ${type.name}'),
        actions: [
          FilledButton(
            onPressed: () {
              showCriteriaInputDialog(context).then((result) => {
                    if (result?.criterias != null &&
                        result!.criterias.isNotEmpty)
                      {
                        setState(() {
                          criterias = result!.criterias
                              .map((e) => CriteriaStateHolder(e))
                              .toList();
                        })
                      }
                    else
                      {
                        // show error
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Error"),
                                content: const Text(
                                    "Invalid criteria input. Please try again."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("OK"),
                                  )
                                ],
                              );
                            })
                      }
                  });
            },
            child: const Text("Input Criteria"),
          ),
          if (criterias.isNotEmpty)
            FilledButton(
              onPressed: () {
                showLocationInputDialog(
                        context, criterias.map((e) => e.criteria).toList())
                    .then((result) {
                  if (result?.locations != null) {
                    setState(() {
                      int criteriaCount = criterias.length;
                      locations = result!.locations
                          .map((e) => LocationStateHolder(e, criteriaCount))
                          .toList();
                    });
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Error"),
                            content: const Text(
                                "Invalid location input. Please try again."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("OK"),
                              )
                            ],
                          );
                        });
                  }
                });
              },
              child: const Text("Input Locations"),
            ),
          if (criterias.isNotEmpty)
            FilledButton(
                onPressed: () {
                  setState(() {
                    locations.add(
                      LocationStateHolder(
                        Location(
                          "Location ${locations.length + 1}",
                          Map.fromIterables(
                            criterias.map((e) => e.criteria.name),
                            List.generate(criterias.length, (index) => 0.0),
                          ),
                        ),
                        criterias.length,
                      ),
                    );
                  });
                },
                child: const Text("Add Location")),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 48),
            child: FilledButton(
              onPressed: () {
                setState(() {
                  criterias.add(
                    CriteriaStateHolder(
                      Criteria("Criteria ${criterias.length + 1}", 1, 1,
                          CriteriaType.min),
                    ),
                  );

                  for (var location in locations) {
                    location.criteriaAdded();
                  }
                });
              },
              child: const Text("Add criteria"),
            ),
          ),
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    return criterias.isEmpty && locations.isEmpty
        ? dropWidget()
        : Padding(
            padding: const EdgeInsets.all(32.0),
            child: Flex(
              direction: Axis.vertical,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    // padding: const EdgeInsets.only(bottom: 20),
                    child: tableWidget(),
                  ),
                ),
                if (locations.isEmpty) Expanded(child: dropWidget()),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () {
                        // save
                      },
                      child: const Text("Save"),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: locations.isEmpty || criterias.isEmpty
                          ? null
                          : () {
                              final allCriterias =
                                  criterias.map((e) => e.criteria).toList();

                              final modifiedLocations = locations.map((e) {
                                final newCriteriaValues = e.controllers
                                    .map((e) => double.tryParse(e.text) ?? 0)
                                    .toList();
                                final newCriteriaMap = Map.fromIterables(
                                    allCriterias.map((e) => e.name),
                                    newCriteriaValues);
                                return Location(
                                    e.location.name, newCriteriaMap);
                              }).toList();

                              compute(normalize, {
                                "locations": modifiedLocations,
                                "criterias": allCriterias
                              }).then((value) {
                                Navigator.pushNamed(
                                  context,
                                  "/normalized",
                                  arguments: {
                                    "normalized": value,
                                    "criterias": criterias
                                        .map((e) => e.criteria)
                                        .toList()
                                  },
                                );
                              });
                            },
                      child: const Text("Normalize"),
                    ),
                  ],
                )
              ],
            ),
          );
  }

  bool isDragging = false;

  Widget dropWidget() {
    // return a rounded card with 16 padding that matches parent width and height
    return Center(
        child: _parsing
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropTarget(
                    onDragDone: _onDropDone,
                    onDragEntered: (_) => setState(() => _dragging = true),
                    onDragExited: (_) => setState(() => _dragging = false),
                    child: Container(
                      width: 300,
                      height: 200,
                      decoration: BoxDecoration(
                        color: _dragging ? Colors.green[100] : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color:
                                _dragging ? Colors.green : Colors.grey.shade300,
                            width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.upload_file,
                            size: 80,
                            color: _dragging ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _dragging
                                ? 'Drop your Excel file here'
                                : 'Drag and Drop Excel File',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color:
                                      _dragging ? Colors.green : Colors.black,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Or Select File'),
                  ),
                  const SizedBox(height: 20),
                  if (error != null)
                    Text(
                      error!,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                ],
              ));
  }

  TableRow emptyRow() {
    return TableRow(children: [
      ...List.generate(
          criterias.length + 1,
          (index) => const SizedBox(
                height: 20,
              ))
    ]);
  }

  Widget tableWidget() {
    return Table(
      children: [
        if (criterias.isNotEmpty) criteriaRow(),
        emptyRow(),
        ...locations.map(locationRow),
      ],
    );
  }

  TableRow locationRow(LocationStateHolder location) {
    return TableRow(children: [
      SizedBox(
        width: 120,
        child: TextField(
          controller: location.nameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
      ...location.controllers.map((e) {
        return SizedBox(
          width: 120,
          child: TextField(
            controller: e,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        );
      })
    ]);
  }

  TableRow criteriaRow() {
    return TableRow(children: [
      const SizedBox(),
      ...criterias.asMap().entries.map((e) {
        return SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: e.value.controllers[0],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: e.value.controllers[1],
                decoration: const InputDecoration(
                  label: Text("Weight"),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: e.value.controllers[2],
                decoration: const InputDecoration(
                  label: Text("Target"),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        // color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton(
                        value: e.value.criteria.type,
                        icon: const Icon(Icons.arrow_drop_down),
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: CriteriaType.min,
                            child: Text("Beneficial"),
                          ),
                          DropdownMenuItem(
                            value: CriteriaType.max,
                            child: Text("Non-Benificial"),
                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            e.value.criteria = Criteria(
                              e.value.criteria.name,
                              e.value.criteria.weight,
                              e.value.criteria.targetValue,
                              value as CriteriaType,
                            );
                          });
                        },
                      )),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        criterias.removeAt(e.key);
                        for (var location in locations) {
                          location.controllers.removeAt(e.key);
                        }
                      });
                    },
                    icon: const Icon(Icons.delete),
                  )
                ],
              )
            ],
          ),
        );
      })
    ]);
  }
}

Future<List<NormalizedLocation>> normalize(Map<String, dynamic> args) async {
  final List<Location> locations = args['locations'];
  final List<Criteria> allCriterias = args['criterias'];
  return locations.map((e) {
    return normalizeLocation(e, locations, allCriterias);
  }).toList();
}
