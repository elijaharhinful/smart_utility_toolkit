import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../core/theme/app_theme.dart';
import 'currency_provider.dart';
import '../history/conversion_history_provider.dart';
import '../unit_converter/widgets/history_list.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  final _inputController = TextEditingController(text: '1');

  // Debounce fields
  Timer? _debounceTimer;
  String? _pendingValue;
  String? _pendingResult;

  static const List<String> _popularCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'GHS',
    'NGN',
    'JPY',
    'CAD',
    'AUD',
    'CHF',
    'CNY',
    'INR',
    'ZAR',
    'KES',
    'EGP',
    'MAD',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CurrencyProvider>().fetchRates(_fromCurrency),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_pendingValue != null && _pendingValue!.isNotEmpty) {
      // Use the last known result so we don't need a provider reference.
      _saveToHistory(_pendingValue!, _pendingResult ?? '');
    }
    _inputController.dispose();
    super.dispose();
  }

  String _formatResult(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return double.parse(value.toStringAsPrecision(6)).toString();
  }

  String _convert(CurrencyProvider provider) {
    final input = double.tryParse(_inputController.text);
    if (input == null || provider.rates.isEmpty) return '—';
    final rate = provider.rates[_toCurrency] ?? 0;
    return _formatResult(input * rate);
  }

  void _scheduleHistory(String text, String result) {
    if (text.isEmpty || !RegExp(r'\d$').hasMatch(text) || result == '—') return;

    _pendingValue = text;
    _pendingResult = result;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1200), () {
      _saveToHistory(_pendingValue!, _pendingResult ?? '');
      _pendingValue = null;
      _pendingResult = null;
    });
  }

  void _saveToHistory(String inputValue, String resultStr) {
    context.read<ConversionHistoryProvider>().add(
      label: '$inputValue $_fromCurrency to $_toCurrency',
      result: '$resultStr $_toCurrency',
      iconType: 'currency',
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
          final result = _convert(provider);
          final rate = provider.rates[_toCurrency];
          final rateLabel = rate != null
              ? '1 $_fromCurrency = ${_formatResult(rate)} $_toCurrency'
              : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error banner
                if (provider.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: AppTheme.danger),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Amount input
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: TextField(
                    controller: _inputController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
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
                          setState(() {});
                        },
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                      _scheduleHistory(
                        _inputController.text, _convert(provider));
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // From and To
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(_fromCurrency, (v) {
                        _flushPending();
                        setState(() => _fromCurrency = v!);
                        provider.fetchRates(v!);
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: GestureDetector(
                        onTap: () {
                          _flushPending();
                          setState(() {
                            final tmp = _fromCurrency;
                            _fromCurrency = _toCurrency;
                            _toCurrency = tmp;
                          });
                          provider.fetchRates(_fromCurrency);
                        },
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
                      child: _buildDropdown(_toCurrency, (v) {
                        _flushPending();
                        setState(() => _toCurrency = v!);
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Result card
                if (provider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  )
                else
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
                                result.isEmpty ? '—' : result,
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
                            if (result != '—') ...[
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  _toCurrency,
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
                        if (rateLabel.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            rateLabel,
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
                const SizedBox(height: 16),

                // Refresh Rates button
                OutlinedButton.icon(
                  onPressed: () => provider.fetchRates(_fromCurrency),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.colorAlternative1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Refresh Rates',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),

                // History
                ConverterHistoryList(iconType: 'currency'),
              ],
            ),
          );
        },
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.dark,
          ),
          items: _popularCurrencies
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
