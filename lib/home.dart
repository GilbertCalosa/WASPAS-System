import 'package:flutter/material.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class TypeModel {
  final String name;

  TypeModel(this.name);
}

class _HomePageWidgetState extends State<HomePageWidget> {
  TypeModel? currentItem;

  final List<TypeModel> modelList = [
    TypeModel("GeoThermal"),
    TypeModel("Wind"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WASPAS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            typeSelectorWidget(),
          ],
        ),
      ),
    );
  }

  Widget typeSelectorWidget() {
    return Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: modelList.map((it) {
        return itemWidget(it, (item) {
          final navigator = Navigator.of(context);
          navigator.pushNamed("/input", arguments: item.name);
        });
      }).toList(),
    ));
  }

  Widget itemWidget(TypeModel model, void Function(TypeModel item) onClick) {
    return Card.outlined(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: InkWell(
        onTap: () {
          onClick(model);
        },
        child: Padding(
          padding: const EdgeInsets.all(64),
          child: Text(model.name, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
