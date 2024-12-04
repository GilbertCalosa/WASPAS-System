enum EnergyType {
  solar,
  wind;

  String get name {
    switch (this) {
      case EnergyType.solar:
        return 'Solar Energy';
      case EnergyType.wind:
        return 'Wind Energy';
    }
  }
}
