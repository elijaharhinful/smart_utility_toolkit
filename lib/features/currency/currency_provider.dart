import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyProvider extends ChangeNotifier {
  Map<String, double> _rates = {};
  bool isLoading = false;
  String? error;

  Map<String, double> get rates => _rates;

  Future<void> fetchRates(String base) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Using free open.er-api.com
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/$base'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _rates = Map<String, double>.from(
          data['rates'].map((k, v) => MapEntry(k, (v as num).toDouble())),
        );
      } else {
        error = 'Failed to fetch rates';
      }
    } catch (e) {
      error = 'Network error. Check connection.';
    }
    isLoading = false;
    notifyListeners();
  }
}
