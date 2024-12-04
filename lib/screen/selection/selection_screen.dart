import 'package:flutter/material.dart';
import 'package:research/model/energy_type.dart';

class EnergySelectionScreen extends StatefulWidget {
  const EnergySelectionScreen({super.key});

  @override
  _EnergySelectionScreenState createState() => _EnergySelectionScreenState();
}

class _EnergySelectionScreenState extends State<EnergySelectionScreen> {
  EnergyType? _selectedEnergyType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Selection'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select Your Energy Source',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEnergyCard(context, EnergyType.solar, Icons.solar_power,
                    'Solar Energy'),
                const SizedBox(width: 20),
                _buildEnergyCard(
                    context, EnergyType.wind, Icons.wind_power, 'Wind Energy'),
              ],
            ),
            const SizedBox(height: 30),
            if (_selectedEnergyType != null)
              ElevatedButton(
                onPressed: () {
                  // Navigate to the next screen
                  Navigator.pushNamed(context, '/input',
                      arguments: _selectedEnergyType);
                },
                child: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyCard(BuildContext context, EnergyType energyType,
      IconData icon, String label) {
    bool isSelected = _selectedEnergyType == energyType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEnergyType = energyType;
        });
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
              width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isSelected ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? Colors.green : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
