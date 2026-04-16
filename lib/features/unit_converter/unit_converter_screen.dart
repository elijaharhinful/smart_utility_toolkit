import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../history/conversion_history_provider.dart';
class UnitConverterScreen extends StatefulWidget {
  final String initialCategory;
  const UnitConverterScreen({super.key, required this.initialCategory});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  late String _fromUnit, _toUnit;
  final _inputController = TextEditingController();
  String _result = '';
  String _rateLabel = '';
  final Map<String, Map<String, double>> _conversions = {
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

  List<String> get _units =>
      _conversions[widget.initialCategory]!.keys.toList();

  @override
  void initState() {
    super.initState();
    _fromUnit = _units.first;
    _toUnit = _units.length > 1 ? _units[1] : _units.first;
  }

  String formatResult(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return double.parse(value.toStringAsPrecision(6)).toString();
  }

  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() {
        _result = '';
        _rateLabel = '';
      });
      return;
    }

    double result;
    if (widget.initialCategory == 'Temperature') {
      result = _convertTemp(input, _fromUnit, _toUnit);
    } else {
      final base = input / _conversions[widget.initialCategory]![_fromUnit]!;
      result = base * _conversions[widget.initialCategory]![_toUnit]!;
    }

    // Rate label
    double rate;
    if (widget.initialCategory == 'Temperature') {
      rate = _convertTemp(1, _fromUnit, _toUnit);
    } else {
      rate =
          _conversions[widget.initialCategory]![_toUnit]! /
          _conversions[widget.initialCategory]![_fromUnit]!;
    }

    final resultStr = formatResult(result);
    final rateStr =
        '1 ${_fromUnit.split(' ').first} = ${formatResult(rate)} ${_toUnit.split(' ').first}';

    // Auto-save to history when input ends with a digit (not mid-typing)
    final rawInput = _inputController.text;
    if (rawInput.isNotEmpty && RegExp(r'\d$').hasMatch(rawInput)) {
      final from = _fromUnit.split(' ').first;
      final to = _toUnit.split(' ').first;
      context.read<ConversionHistoryProvider>().add(
        label: '$rawInput $from to $to',
        result: '$resultStr $to',
        iconType: 'unit',
      );
    }

    setState(() {
      _result = resultStr;
      _rateLabel = rateStr;
    });
  }

  double _convertTemp(double v, String from, String to) {
    double c;
    if (from.contains('°F')) {
      c = (v - 32) * 5 / 9;
    } else if (from.contains('K')) {
      c = v - 273.15;
    } else {
      c = v;
    }
    if (to.contains('°F')) return c * 9 / 5 + 32;
    if (to.contains('K')) return c + 273.15;
    return c;
  }



  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toShort = _toUnit.contains('(')
        ? _toUnit.split('(')[1].replaceAll(')', '')
        : _toUnit;

    final history = context.watch<ConversionHistoryProvider>()
        .all.where((e) => e.iconType == 'unit').toList();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.initialCategory} Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _inputController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                ],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {
                      _inputController.clear();
                      setState(() {
                        _result = '';
                        _rateLabel = '';
                      });
                    },
                  ),
                ),
                onChanged: (_) => _convert(),
              ),
            ),
            const SizedBox(height: 40),

            // From / Swap / To
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    _fromUnit,
                    (v) => setState(() {
                      _fromUnit = v!;
                      _convert();
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      final t = _fromUnit;
                      _fromUnit = _toUnit;
                      _toUnit = t;
                      _convert();
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildDropdown(
                    _toUnit,
                    (v) => setState(() {
                      _toUnit = v!;
                      _convert();
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Result card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                children: [
                  const Text(
                    'CONVERTED RESULT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.colorAlternative5,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: AutoSizeText(
                          _result.isEmpty ? '—' : _result,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 60,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.dark,
                          ),
                          minFontSize: 20,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_result.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            toShort,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_rateLabel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _rateLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.colorAlternative1,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (history.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: const [
                  Icon(
                    Icons.history_rounded,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Recent History',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...history.map(
                (e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.iconBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.straighten_rounded,
                          size: 16,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.label,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.dark,
                              ),
                            ),
                            Text(
                              e.result,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.read<ConversionHistoryProvider>().removeEntry(e),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.danger,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.dark,
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
        ),
      ),
    );
  }
}
