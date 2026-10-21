import 'package:flutter/material.dart';

import '../services/history_service.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      isLoading = true;
    });

    final data = await HistoryService.getHistory();

    if (!mounted) return;

    setState(() {
      history = data;
      isLoading = false;
    });
  }

  Future<void> clearHistory() async {
    final bool? confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Riwayat?'),
          content: const Text(
            'Semua hasil skrining yang tersimpan akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true) return;

    await HistoryService.clearHistory();
    await loadHistory();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Riwayat skrining berhasil dihapus.',
        ),
      ),
    );
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);

      final day =
          parsedDate.day.toString().padLeft(2, '0');

      final month =
          parsedDate.month.toString().padLeft(2, '0');

      final year = parsedDate.year.toString();

      final hour =
          parsedDate.hour.toString().padLeft(2, '0');

      final minute =
          parsedDate.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return 'Tanggal tidak tersedia';
    }
  }

  Color getPredictionColor(String prediction) {
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

  IconData getPredictionIcon(String prediction) {
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

  void openDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryDetailScreen(
          historyItem: item,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Riwayat Skrining',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              onPressed: clearHistory,
              tooltip: 'Hapus Riwayat',
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : history.isEmpty
                ? buildEmptyHistory()
                : buildHistoryList(),
      ),
    );
  }

  Widget buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 90,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Riwayat Skrining',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Setelah Anda melakukan skrining, '
              'hasilnya akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.home_rounded,
              ),
              label: const Text(
                'Kembali ke Beranda',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistoryList() {
    return RefreshIndicator(
      onRefresh: loadHistory,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${history.length} hasil skrining tersimpan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...history.map(
            (item) => buildHistoryCard(item),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildHistoryCard(
    Map<String, dynamic> item,
  ) {
    final String prediction =
        item['prediction']?.toString() ??
            'Tidak diketahui';

    final String date =
        item['date']?.toString() ?? '';

    final Map<String, dynamic> probability =
        Map<String, dynamic>.from(
      item['probability'] ?? {},
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

    final Color resultColor =
        getPredictionColor(prediction);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          openDetail(item);
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: resultColor.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      getPredictionIcon(
                        prediction,
                      ),
                      color: resultColor,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          prediction,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight:
                                FontWeight.bold,
                            color: resultColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(date),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 10),

              const Text(
                'Probabilitas Model',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              buildProbabilityText(
                'Tidak Diabetes',
                tidakDiabetes,
              ),

              const SizedBox(height: 8),

              buildProbabilityText(
                'Prediabetes',
                prediabetes,
              ),

              const SizedBox(height: 8),

              buildProbabilityText(
                'Diabetes',
                diabetes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProbabilityText(
    String label,
    double value,
  ) {
    final double percentage =
        value * 100;

    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '${percentage.toStringAsFixed(2)}%',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}