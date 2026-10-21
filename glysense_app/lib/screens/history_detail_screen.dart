import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> historyItem;

  const HistoryDetailScreen({
    super.key,
    required this.historyItem,
  });

  String formatDate(
    String date,
  ) {
    try {
      final DateTime parsedDate =
          DateTime.parse(date);

      final String day =
          parsedDate.day.toString().padLeft(
                2,
                '0',
              );

      final String month =
          parsedDate.month.toString().padLeft(
                2,
                '0',
              );

      final String year =
          parsedDate.year.toString();

      final String hour =
          parsedDate.hour.toString().padLeft(
                2,
                '0',
              );

      final String minute =
          parsedDate.minute.toString().padLeft(
                2,
                '0',
              );

      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return 'Tanggal tidak tersedia';
    }
  }

  Color getPredictionColor(
    String prediction,
  ) {
    if (prediction == 'Tidak Diabetes') {
      return Colors.green;
    }

    if (prediction == 'Prediabetes') {
      return Colors.orange;
    }

    if (prediction == 'Diabetes') {
      return Colors.red;
    }

    return Colors.grey;
  }

  IconData getPredictionIcon(
    String prediction,
  ) {
    if (prediction == 'Tidak Diabetes') {
      return Icons.check_circle_rounded;
    }

    if (prediction == 'Prediabetes') {
      return Icons.warning_amber_rounded;
    }

    if (prediction == 'Diabetes') {
      return Icons.health_and_safety_rounded;
    }

    return Icons.help_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final String prediction =
        historyItem['prediction']?.toString() ??
            'Tidak diketahui';

    final String date =
        historyItem['date']?.toString() ?? '';

    final Map<String, dynamic> probability =
        Map<String, dynamic>.from(
      historyItem['probability'] ?? {},
    );

    final double tidakDiabetes =
        (probability['tidak_diabetes'] ?? 0)
            .toDouble();

    final double prediabetes =
        (probability['prediabetes'] ?? 0)
            .toDouble();

    final double diabetes =
        (probability['diabetes'] ?? 0)
            .toDouble();

    final double threshold =
        (historyItem['prediabetes_threshold'] ?? 0)
            .toDouble();

    final String message =
        historyItem['message']?.toString() ??
            'Hasil ini merupakan skrining awal.';

    final Color resultColor =
        getPredictionColor(
      prediction,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Icon(
                getPredictionIcon(
                  prediction,
                ),
                size: 85,
                color: resultColor,
              ),

              const SizedBox(height: 18),

              const Text(
                'Detail Hasil Skrining',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                formatDate(
                  date,
                ),
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    24,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Hasil Prediksi',
                        style:
                            TextStyle(
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        prediction,
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              resultColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Probabilitas Model',
                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      buildProbabilityRow(
                        'Tidak Diabetes',
                        tidakDiabetes,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      buildProbabilityRow(
                        'Prediabetes',
                        prediabetes,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

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
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Model',
                        style:
                            TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      Text(
                        'Threshold Prediabetes: '
                        '${threshold.toStringAsFixed(2)}',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        message,
                        style:
                            const TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.red
                      .withValues(
                    alpha: 0.06,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons
                          .warning_amber_rounded,
                      color:
                          Colors.red,
                    ),

                    SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        'Hasil ini merupakan skrining awal '
                        'dan bukan diagnosis medis.',
                        style:
                            TextStyle(
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
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons
                        .arrow_back_rounded,
                  ),
                  label: const Text(
                    'Kembali ke Riwayat',
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),
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
    final double percentage =
        value * 100;

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
                fontWeight:
                    FontWeight.bold,
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
              BorderRadius.circular(
            10,
          ),
        ),
      ],
    );
  }
}