import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Placeholder history data
  final List<Map<String, String>> _history = const [
    {'title': 'ร้านกาแฟ', 'subtitle': '24 ก.ย. 2569', 'amount': '-฿120'},
    {'title': 'ค่าเดินทาง', 'subtitle': '23 ก.ย. 2569', 'amount': '-฿80'},
    {'title': 'ค่าอาหาร', 'subtitle': '22 ก.ย. 2569', 'amount': '-฿100'},
  ];

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
                      '฿300',
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
              Text(
                'อัพเดทล่าสุด: 25 ก.ย. 2569',
                style: GoogleFonts.notoSansThai(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.refresh, color: Colors.white),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, String> item) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade50,
        child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
      ),
      title: Text(item['title']!, style: GoogleFonts.notoSansThai()),
      subtitle: Text(
        item['subtitle']!,
        style: GoogleFonts.notoSansThai(fontSize: 12),
      ),
      trailing: Text(
        item['amount']!,
        style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600),
      ),
    );
  }
}
