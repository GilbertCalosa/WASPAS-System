import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:research/home.dart';
import 'package:research/screen/calculated/calculated_screen.dart';
import 'package:research/screen/decision/decision_screen.dart';
import 'package:research/screen/input_screen.dart';
import 'package:research/screen/normalized/normalized_screen.dart';
import 'package:research/screen/selection/selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WASPAS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: "/",
      onGenerateRoute: (settings) {
        if (settings.name == "/") {
          return PageTransition(
            child: const EnergySelectionScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings,
          );
        }
        if (settings.name == "/input") {
          return PageTransition(
            child: const InputScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings,
          );
        } else if (settings.name == "/normalized") {
          return PageTransition(
            child: const NormalizedScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings,
          );
        } else if (settings.name == "/calculated") {
          return PageTransition(
            child: const CalculatedScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings,
          );
        } else if (settings.name == "/decision") {
          return PageTransition(
            child: const DecisionScreen(),
            type: PageTransitionType.rightToLeft,
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
