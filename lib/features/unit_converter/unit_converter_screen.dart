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

  List<String> get _units =>
      kConversions[widget.initialCategory]!.keys.toList();

  @override
  void initState() {
    super.initState();
    _fromUnit = _units.first;
    _toUnit = _units.length > 1 ? _units[1] : _units.first;
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

    // Auto-save to history when input ends with a digit
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
              onFromChanged: (v) => setState(() {
                _fromUnit = v!;
                _convert();
              }),
              onToChanged: (v) => setState(() {
                _toUnit = v!;
                _convert();
              }),
              onSwap: () => setState(() {
                final t = _fromUnit;
                _fromUnit = _toUnit;
                _toUnit = t;
                _convert();
              }),
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
