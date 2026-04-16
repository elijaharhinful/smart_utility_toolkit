import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../history/conversion_history_provider.dart';
import 'unit_converter_data.dart';
import 'widgets/converter_input.dart';
import 'widgets/converter_unit_row.dart';
import 'widgets/result_card.dart';
import 'widgets/history_list.dart';

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

  // Debounce fields
  Timer? _debounceTimer;
  String? _pendingValue;
  String? _pendingResult;

  List<String> get _units =>
      kConversions[widget.initialCategory]!.keys.toList();

  @override
  void initState() {
    super.initState();
    _fromUnit = _units.first;
    _toUnit = _units.length > 1 ? _units[1] : _units.first;
  }

  // Performs the live conversion and schedules a debounced history save.
  void _convert() {
    final rawInput = _inputController.text;
    final input = double.tryParse(rawInput);

    if (input == null) {
      _debounceTimer?.cancel();
      setState(() {
        _result = '';
        _rateLabel = '';
      });
      return;
    }

    final result = convertUnits(
      category: widget.initialCategory,
      input: input,
      fromUnit: _fromUnit,
      toUnit: _toUnit,
    );

    final rate = unitRate(
      category: widget.initialCategory,
      fromUnit: _fromUnit,
      toUnit: _toUnit,
    );

    final resultStr = formatUnitResult(result);
    final rateStr =
        '1 ${_fromUnit.split(' ').first} = ${formatUnitResult(rate)} ${_toUnit.split(' ').first}';

    // Update the display immediately — no debounce here.
    setState(() {
      _result = resultStr;
      _rateLabel = rateStr;
    });

    // Debounce history recording.
    if (rawInput.isNotEmpty && RegExp(r'\d$').hasMatch(rawInput)) {
      _pendingValue = rawInput;
      _pendingResult = resultStr;

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 1200), () {
        _saveToHistory(_pendingValue!, _pendingResult ?? '');
        _pendingValue = null;
        _pendingResult = null;
      });
    }
  }

  void _saveToHistory(String inputValue, String resultStr) {
    final from = _fromUnit.split(' ').first;
    final to = _toUnit.split(' ').first;
    context.read<ConversionHistoryProvider>().add(
      label: '$inputValue $from to $to',
      result: '$resultStr $to',
      iconType: 'unit',
    );
  }

  // Flush any pending history entry, then apply the unit change.
  void _onFromUnitChanged(String? newUnit) {
    if (newUnit == null) return;
    _flushPending();
    setState(() {
      _fromUnit = newUnit;
      _convert();
    });
  }

  void _onToUnitChanged(String? newUnit) {
    if (newUnit == null) return;
    _flushPending();
    setState(() {
      _toUnit = newUnit;
      _convert();
    });
  }

  void _onSwap() {
    _flushPending();
    setState(() {
      final t = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = t;
      _convert();
    });
  }

  void _flushPending() {
    _debounceTimer?.cancel();
    if (_pendingValue != null && _pendingValue!.isNotEmpty) {
      _saveToHistory(_pendingValue!, _pendingResult ?? '');
      _pendingValue = null;
      _pendingResult = null;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_pendingValue != null && _pendingValue!.isNotEmpty) {
      _saveToHistory(_pendingValue!, _pendingResult ?? '');
    }
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toShort = _toUnit.contains('(')
        ? _toUnit.split('(')[1].replaceAll(')', '')
        : _toUnit;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.initialCategory} Converter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConverterInput(
              controller: _inputController,
              onChanged: (_) => _convert(),
            ),
            const SizedBox(height: 40),
            ConverterUnitRow(
              units: _units,
              fromUnit: _fromUnit,
              toUnit: _toUnit,
              onFromChanged: _onFromUnitChanged,
              onToChanged: _onToUnitChanged,
              onSwap: _onSwap,
            ),
            const SizedBox(height: 40),
            ResultCard(
              result: _result,
              unitShort: toShort,
              rateLabel: _rateLabel,
            ),
            ConverterHistoryList(iconType: 'unit'),
          ],
        ),
      ),
    );
  }
}
