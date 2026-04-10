import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'currency_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Consumer<CurrencyProvider>(
        builder: (context, provider, _) {
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
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildCurrencyDropdown('From', _fromCurrency, (v) {
                        setState(() => _fromCurrency = v!);
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
                          provider.fetchRates(_fromCurrency);
                        }),
                        icon: const Icon(Icons.swap_horiz),
                      ),
                    ),
                    Expanded(
                      child: _buildCurrencyDropdown(
                        'To',
                        _toCurrency,
                        (v) => setState(() => _toCurrency = v!),
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
