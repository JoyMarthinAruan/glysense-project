import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _historyKey = 'screening_history';

  static Future<void> saveHistory(
    Map<String, dynamic> result,
  ) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String> history =
        prefs.getStringList(_historyKey) ?? [];

    final Map<String, dynamic> historyItem = {
      'date': DateTime.now().toIso8601String(),
      'prediction': result['prediction'],
      'predicted_class': result['predicted_class'],
      'probability': result['probability'],
      'prediabetes_threshold':
          result['prediabetes_threshold'],
      'message': result['message'],
    };

    history.insert(
      0,
      jsonEncode(historyItem),
    );

    await prefs.setStringList(
      _historyKey,
      history,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getHistory() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    final List<String> history =
        prefs.getStringList(_historyKey) ?? [];

    return history.map(
      (item) {
        return Map<String, dynamic>.from(
          jsonDecode(item),
        );
      },
    ).toList();
  }

  static Future<void> clearHistory() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _historyKey,
    );
  }
}