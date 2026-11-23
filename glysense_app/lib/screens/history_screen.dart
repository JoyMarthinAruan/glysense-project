import 'package:flutter/material.dart';

import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
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
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: AppColors.riskHigh),
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
      const SnackBar(content: Text('Riwayat skrining berhasil dihapus.')),
    );
  }

  void openDetail(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryDetailScreen(historyItem: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Skrining'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              onPressed: clearHistory,
              tooltip: 'Hapus Riwayat',
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : history.isEmpty
                ? buildEmptyHistory()
                : buildHistoryList(),
      ),
    );
  }

  Widget buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Belum Ada Riwayat Skrining',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Setelah Anda melakukan skrining, hasilnya akan muncul di '
              'halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_rounded),
              label: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistoryList() {
    final List<int> jumlah = [0, 0, 0];
    for (final Map<String, dynamic> item in history) {
      jumlah[RiskInfo.levelOf(item)]++;
    }

    return RefreshIndicator(
      onRefresh: loadHistory,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: _statistik('Rendah', jumlah[0], AppColors.riskLow),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statistik('Waspada', jumlah[1], AppColors.riskMedium),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statistik('Tinggi', jumlah[2], AppColors.riskHigh),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${history.length} hasil skrining tersimpan',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          for (final Map<String, dynamic> item in history)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: buildHistoryCard(item),
            ),
        ],
      ),
    );
  }

  Widget _statistik(String label, int nilai, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$nilai',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: warna,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryCard(Map<String, dynamic> item) {
    final String prediction = item['prediction']?.toString() ?? 'Tidak diketahui';
    final String date = item['date']?.toString() ?? '';
    final RiskInfo risiko = RiskInfo.of(item);

    return SoftCard(
      onTap: () => openDetail(item),
      child: Row(
        children: [
          IconBadge(icon: risiko.icon, color: risiko.color, size: 50),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: risiko.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  risiko.title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatTanggalJam(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
