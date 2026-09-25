// dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../systems/receipt_recognition.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  static const List<String> _thaiMonthsAbbr = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  // Show whatever is already on disk immediately, no scanning/OCR.
  Future<void> _loadSavedData() async {
    final saved = await loadSavedSlips();
    if (!mounted) return;
    setState(() {
      _history = _sortedByTime(saved);
    });
  }

  // Wired to the refresh IconButton: scans for new slips, runs OCR,
  // then refreshes the list from the updated slips.json.
  Future<void> _handleRefresh() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Testing: cap this batch to the latest 10 unread slip images.
      final updated = await processNewSlips(limit: 10);
      if (!mounted) return;
      setState(() {
        _history = _sortedByTime(updated);
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดสลิป: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _sortedByTime(List<Map<String, dynamic>> list) {
    final copy = List<Map<String, dynamic>>.from(list);
    copy.sort((a, b) {
      final aTime =
          DateTime.tryParse(a['txTime']?.toString() ?? '') ?? DateTime(0);
      final bTime =
          DateTime.tryParse(b['txTime']?.toString() ?? '') ?? DateTime(0);
      return bTime.compareTo(aTime);
    });
    return copy;
  }

  String _formatThaiDate(DateTime dt) {
    final buddhistYear = dt.year + 543;
    final month = _thaiMonthsAbbr[dt.month - 1];
    return '${dt.day} $month $buddhistYear';
  }

  double get _weeklyTotal {
    double total = 0;
    for (final item in _history) {
      final amountStr = (item['amount'] ?? '').toString().replaceAll(',', '');
      total += double.tryParse(amountStr) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildSummaryCard(),
            const SizedBox(height: 24),
            Text(
              'ประวัติรายการ',
              style: GoogleFonts.notoSansThai(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'ยังไม่มีรายการ กดปุ่มรีเฟรชเพื่อสแกนสลิป',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              )
            else
              ..._history.map(_buildHistoryTile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://example.com/avatar.png'),
        ),
        const SizedBox(width: 12),
        Text(
          'ชื่อผู้ใช้งาน',
          style: GoogleFonts.notoSansThai(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: 0.6,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'สัปดาห์นี้คุณใช้ไปแล้ว',
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '฿${_weeklyTotal.toStringAsFixed(0)}',
                      style: GoogleFonts.notoSansThai(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isLoading
                      ? 'กรุณารอรูปโหลด'
                      : 'อัพเดทล่าสุด: ${_lastUpdated != null ? _formatThaiDate(_lastUpdated!) : '-'}',
                  style: GoogleFonts.notoSansThai(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(
                width: 32,
                height: 32,
                child: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: _handleRefresh,
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> item) {
    final rawAmount = (item['amount'] ?? '').toString();
    final displayAmount = rawAmount == 'Not Found'
        ? 'ไม่พบยอด'
        : '-฿$rawAmount';

    final txTime = DateTime.tryParse(item['txTime']?.toString() ?? '');
    final subtitle = txTime != null ? _formatThaiDate(txTime) : '-';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade50,
        child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
      ),
      title: Text(
        item['Bank']?.toString() ?? '-',
        style: GoogleFonts.notoSansThai(),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.notoSansThai(fontSize: 12)),
      trailing: Text(
        displayAmount,
        style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600),
      ),
    );
  }
}
