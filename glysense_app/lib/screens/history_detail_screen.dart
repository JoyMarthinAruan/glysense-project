import 'package:flutter/material.dart';

import '../widgets/app_ui.dart';
import 'result_screen.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> historyItem;

  const HistoryDetailScreen({
    super.key,
    required this.historyItem,
  });

  @override
  Widget build(BuildContext context) {
    final String date = historyItem['date']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Riwayat')),
      body: SafeArea(
        child: ResultView(
          result: historyItem,
          tanggal: date.isEmpty ? null : formatTanggalJam(date),
          actions: [
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Kembali ke Riwayat'),
            ),
          ],
        ),
      ),
    );
  }
}
