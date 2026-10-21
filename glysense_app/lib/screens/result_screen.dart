import 'package:flutter/material.dart';

import '../services/history_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();

    _saveResultToHistory();
  }

  Future<void> _saveResultToHistory() async {
    if (_historySaved) {
      return;
    }

    _historySaved = true;

    try {
      await HistoryService.saveHistory(
        widget.result,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Riwayat gagal disimpan: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String prediction =
        widget.result['prediction']?.toString() ??
            'Tidak diketahui';

    final Map<String, dynamic> probability =
        Map<String, dynamic>.from(
      widget.result['probability'] ?? {},
    );

    final double tidakDiabetes =
        (probability['tidak_diabetes'] ?? 0).toDouble();

    final double prediabetes =
        (probability['prediabetes'] ?? 0).toDouble();

    final double diabetes =
        (probability['diabetes'] ?? 0).toDouble();

    final double threshold =
        (widget.result['prediabetes_threshold'] ?? 0)
            .toDouble();

    final String message =
        widget.result['message']?.toString() ??
            'Hasil ini merupakan skrining awal.';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hasil Skrining',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.health_and_safety_rounded,
                size: 90,
                color: Colors.red,
              ),

              const SizedBox(height: 20),

              const Text(
                'Hasil Skrining GlySense',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Hasil Prediksi',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        prediction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Probabilitas Model',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      buildProbabilityRow(
                        'Tidak Diabetes',
                        tidakDiabetes,
                      ),

                      const SizedBox(height: 14),

                      buildProbabilityRow(
                        'Prediabetes',
                        prediabetes,
                      ),

                      const SizedBox(height: 14),

                      buildProbabilityRow(
                        'Diabetes',
                        diabetes,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Model',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Threshold Prediabetes: '
                        '${threshold.toStringAsFixed(2)}',
                      ),

                      const SizedBox(height: 10),

                      Text(
                        message,
                        style: const TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.save_rounded,
                      color: Colors.green,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Hasil skrining ini telah disimpan '
                        'ke Riwayat Skrining.',
                        style: TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Form Skrining',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Hasil skrining bukan merupakan diagnosis medis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProbabilityRow(
    String label,
    double value,
  ) {
    final double percentage = value * 100;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: [
            Text(label),

            Text(
              '${percentage.toStringAsFixed(2)}%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        LinearProgressIndicator(
          value: value.clamp(
            0.0,
            1.0,
          ),
          minHeight: 8,
          borderRadius:
              BorderRadius.circular(10),
        ),
      ],
    );
  }
}