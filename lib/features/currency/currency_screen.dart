import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'currency_provider.dart';
import '../history/conversion_history_provider.dart';
import '../../core/theme/app_theme.dart';
class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _fromCurrency = 'USD';
  String _toCurrency = 'GHS';
  final _inputController = TextEditingController(text: '1');
  final List<String> _popularCurrencies = [
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

  String _convert() {
    final provider = context.read<CurrencyProvider>();
    final input = double.tryParse(_inputController.text);
    if (input == null || provider.rates.isEmpty) return '—';
    final rate = provider.rates[_toCurrency] ?? 0;
    return (input * rate).toStringAsFixed(2);
  }

  void _recordHistory() {
    final text = _inputController.text;
    if (text.isEmpty || !RegExp(r'\d$').hasMatch(text)) return;
    final result = _convert();
    if (result == '—') return;
    
    context.read<ConversionHistoryProvider>().add(
      label: '$text $_fromCurrency to $_toCurrency',
      result: '$result $_toCurrency',
      iconType: 'currency',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
          final history = context.watch<ConversionHistoryProvider>()
              .all.where((e) => e.iconType == 'currency').toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (_) {
                    setState(() {});
                    _recordHistory();
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildCurrencyDropdown('From', _fromCurrency, (v) {
                        setState(() {
                          _fromCurrency = v!;
                          _recordHistory();
                        });
                        provider.fetchRates(v!);
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconButton.filled(
                        onPressed: () => setState(() {
                          final tmp = _fromCurrency;
                          _fromCurrency = _toCurrency;
                          _toCurrency = tmp;
                          _recordHistory();
                          provider.fetchRates(_fromCurrency);
                        }),
                        icon: const Icon(Icons.swap_horiz),
                      ),
                    ),
                    Expanded(
                      child: _buildCurrencyDropdown(
                        'To',
                        _toCurrency,
                        (v) => setState(() {
                          _toCurrency = v!;
                          _recordHistory();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${_inputController.text} $_fromCurrency =',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_convert()} $_toCurrency',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rate: 1 $_fromCurrency = ${provider.rates[_toCurrency]?.toStringAsFixed(4) ?? '—'} $_toCurrency',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => provider.fetchRates(_fromCurrency),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Rates'),
                ),

                if (history.isNotEmpty) ...[
                  const SizedBox(height: 32),
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
                            child: Icon(
                              e.icon,
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
          );
        },
      ),
    );
  }

  Widget _buildCurrencyDropdown(
    String label,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
      ),
      items: _popularCurrencies
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
