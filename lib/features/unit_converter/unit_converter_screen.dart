import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnitConverterScreen extends StatefulWidget {
  final String initialCategory;
  const UnitConverterScreen({super.key, required this.initialCategory});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  late String _selectedCategory;
  late String _fromUnit;
  late String _toUnit;
  final _inputController = TextEditingController();
  String _result = '';

  final Map<String, Map<String, double>> _conversions = {
    'Length': {
      'Meter': 1,
      'Kilometer': 0.001,
      'Centimeter': 100,
      'Millimeter': 1000,
      'Mile': 0.000621371,
      'Yard': 1.09361,
      'Foot': 3.28084,
      'Inch': 39.3701,
      'Nautical Mile': 0.000539957,
    },
    'Weight': {
      'Kilogram': 1,
      'Gram': 1000,
      'Milligram': 1000000,
      'Pound': 2.20462,
      'Ounce': 35.274,
      'Ton (metric)': 0.001,
      'Stone': 0.157473,
    },
    'Temperature': {'Celsius': 1, 'Fahrenheit': 1, 'Kelvin': 1},
    'Area': {
      'Square Meter': 1,
      'Square Kilometer': 0.000001,
      'Square Mile': 3.861e-7,
      'Square Foot': 10.7639,
      'Square Inch': 1550,
      'Hectare': 0.0001,
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
      'Liter': 1,
      'Milliliter': 1000,
      'Cubic Meter': 0.001,
      'Gallon (US)': 0.264172,
      'Gallon (UK)': 0.219969,
      'Fluid Ounce': 33.814,
      'Cup': 4.22675,
      'Pint': 2.11338,
      'Quart': 1.05669,
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _fromUnit = _units.first;
    _toUnit = _units.length > 1 ? _units[1] : _units.first;
  }

  List<String> get _units => _conversions[_selectedCategory]!.keys.toList();

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() => _result = '');
      return;
    }

    double result;
    if (_selectedCategory == 'Temperature') {
      result = _convertTemperature(input, _fromUnit, _toUnit);
    } else {
      final inBase = input / _conversions[_selectedCategory]![_fromUnit]!;
      result = inBase * _conversions[_selectedCategory]![_toUnit]!;
    }

    // Clean up trailing zeros
    String formatted = result.toStringAsFixed(6);
    if (formatted.contains('.')) {
      formatted = formatted
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    setState(() => _result = '$formatted $_toUnit');
  }

  double _convertTemperature(double value, String from, String to) {
    double celsius;
    switch (from) {
      case 'Fahrenheit':
        celsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        celsius = value - 273.15;
        break;
      default:
        celsius = value;
    }
    switch (to) {
      case 'Fahrenheit':
        return celsius * 9 / 5 + 32;
      case 'Kelvin':
        return celsius + 273.15;
      default:
        return celsius;
    }
  }

  void _swap() {
    setState(() {
      final tmp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = tmp;
      _convert();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('$_selectedCategory Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input field
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
              ],
              decoration: InputDecoration(
                labelText: 'Enter value',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _inputController.clear();
                    setState(() => _result = '');
                  },
                ),
              ),
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 24),

            // From / Swap / To
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'From',
                    _fromUnit,
                    (v) => setState(() {
                      _fromUnit = v!;
                      _convert();
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton.filled(
                    onPressed: _swap,
                    icon: const Icon(Icons.swap_horiz),
                    tooltip: 'Swap',
                  ),
                ),
                Expanded(
                  child: _buildDropdown(
                    'To',
                    _toUnit,
                    (v) => setState(() {
                      _toUnit = v!;
                      _convert();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Result
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _result.isNotEmpty
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Result',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _result.isNotEmpty ? _result : '—',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_result.isNotEmpty &&
                      _inputController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_inputController.text} $_fromUnit = $_result',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick reference for temperature
            if (_selectedCategory == 'Temperature')
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Reference',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Water freezes: 0°C = 32°F = 273.15K'),
                      const Text('Body temp:    37°C = 98.6°F = 310.15K'),
                      const Text('Water boils:  100°C = 212°F = 373.15K'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      items: _units
          .map(
            (u) => DropdownMenuItem(
              value: u,
              child: Text(u, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
