const Map<String, Map<String, double>> kConversions = {
  'Length': {
    'Meter (m)': 1,
    'Kilometer (km)': 0.001,
    'Centimeter (cm)': 100,
    'Millimeter (mm)': 1000,
    'Mile (mi)': 0.000621371,
    'Yard (yd)': 1.09361,
    'Feet (ft)': 3.28084,
    'Inch (in)': 39.3701,
  },
  'Weight': {
    'Kilogram (kg)': 1,
    'Gram (g)': 1000,
    'Milligram (mg)': 1000000,
    'Pound (lb)': 2.20462,
    'Ounce (oz)': 35.274,
    'Ton': 0.001,
    'Stone (st)': 0.157473,
  },
  'Temperature': {'Celsius (°C)': 1, 'Fahrenheit (°F)': 1, 'Kelvin (K)': 1},
  'Area': {
    'Square Meter (m²)': 1,
    'Square Kilometer (km²)': 0.000001,
    'Square Mile': 3.861e-7,
    'Square Foot (ft²)': 10.7639,
    'Hectare (ha)': 0.0001,
    'Acre': 0.000247105,
  },
  'Speed': {
    'm/s': 1,
    'km/h': 3.6,
    'mph': 2.23694,
    'knot': 1.94384,
    'ft/s': 3.28084,
  },
  'Volume': {
    'Liter (L)': 1,
    'Milliliter (mL)': 1000,
    'Cubic Meter (m³)': 0.001,
    'Gallon (US)': 0.264172,
    'Fluid Ounce (fl oz)': 33.814,
    'Cup': 4.22675,
    'Pint (pt)': 2.11338,
  },
};

// Strips unnecessary trailing zeros.
String formatUnitResult(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  }
  return double.parse(value.toStringAsPrecision(6)).toString();
}

// Converts temperature between units.
double convertTemperature(double v, String from, String to) {
  double celsius;
  if (from.contains('°F')) {
    celsius = (v - 32) * 5 / 9;
  } else if (from.contains('K')) {
    celsius = v - 273.15;
  } else {
    celsius = v;
  }
  if (to.contains('°F')) return celsius * 9 / 5 + 32;
  if (to.contains('K')) return celsius + 273.15;
  return celsius;
}

// Performs the conversion for a given category.
double convertUnits({
  required String category,
  required double input,
  required String fromUnit,
  required String toUnit,
}) {
  if (category == 'Temperature') {
    return convertTemperature(input, fromUnit, toUnit);
  }
  final table = kConversions[category]!;
  final base = input / table[fromUnit]!;
  return base * table[toUnit]!;
}

// Calculates the 1-unit rate label for display.
double unitRate({
  required String category,
  required String fromUnit,
  required String toUnit,
}) {
  if (category == 'Temperature') {
    return convertTemperature(1, fromUnit, toUnit);
  }
  final table = kConversions[category]!;
  return table[toUnit]! / table[fromUnit]!;
}
