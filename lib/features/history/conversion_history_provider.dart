import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversionHistoryEntry {
  final String label;
  final String result;
  final String iconType; // 'unit' | 'currency'
  final DateTime timestamp;

  const ConversionHistoryEntry({
    required this.label,
    required this.result,
    required this.iconType,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'label': label,
    'result': result,
    'iconType': iconType,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ConversionHistoryEntry.fromJson(Map<String, dynamic> j) =>
      ConversionHistoryEntry(
        label: j['label'],
        result: j['result'],
        iconType: j['iconType'] ?? 'unit',
        timestamp: DateTime.parse(j['timestamp']),
      );

  IconData get icon => iconType == 'currency'
      ? Icons.currency_exchange_rounded
      : Icons.straighten_rounded;
}

class ConversionHistoryProvider extends ChangeNotifier {
  static const _key = 'conversion_history_v1';
  static const _maxEntries = 10;

  List<ConversionHistoryEntry> _entries = [];

  List<ConversionHistoryEntry> get all => List.unmodifiable(_entries);
  List<ConversionHistoryEntry> get recent => _entries.take(3).toList();

  ConversionHistoryProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data != null) {
      _entries = (jsonDecode(data) as List)
          .map((e) => ConversionHistoryEntry.fromJson(e))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_entries.map((e) => e.toJson()).toList()),
    );
  }

  void add({
    required String label,
    required String result,
    required String iconType,
  }) {
    // Avoid duplicate consecutive entries
    if (_entries.isNotEmpty && _entries.first.label == label) return;

    _entries.insert(
      0,
      ConversionHistoryEntry(
        label: label,
        result: result,
        iconType: iconType,
        timestamp: DateTime.now(),
      ),
    );

    if (_entries.length > _maxEntries) _entries.removeLast();
    _save();
    notifyListeners();
  }

  void remove(int index) {
    if (index < 0 || index >= _entries.length) return;
    _entries.removeAt(index);
    _save();
    notifyListeners();
  }

  void removeEntry(ConversionHistoryEntry entry) {
    _entries.remove(entry);
    _save();
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    _save();
    notifyListeners();
  }
}
