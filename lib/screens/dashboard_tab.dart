import 'dart:io';
import 'package:flutter/material.dart';
import '../systems/preference.dart';
import '../systems/receipt_recognition.dart';
import '../systems/slip_storage.dart';
import '../systems/thai_date.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _budgetController = TextEditingController();

  List<Map<String, dynamic>> _history = [];
  bool _isLoading = false;
  DateTime? _lastUpdated;
  double _budget = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final saved = await loadSavedSlips();
    final savedBudget = await getData('budget');
    if (!mounted) return;
    setState(() {
      _history = _sortedByTime(saved);
      _budget = double.tryParse(savedBudget ?? '') ?? 0;
    });
  }

  Future<void> _editBudget() async {
    final previous = _budget;
    _budgetController.text = _budget > 0 ? _budget.toStringAsFixed(2) : '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('กรอกจำนวนเงิน'),
        content: TextField(
          controller: _budgetController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'กรอกจำนวนเงิน',
            hintText: '0.00',
            prefixText: '฿ ',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _budget = double.tryParse(value.trim().replaceAll(',', '')) ?? 0;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      await saveData('budget', _budget.toString());
    } else {
      setState(() => _budget = previous);
    }
  }

  Future<void> _handleRefresh() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('กำลังโหลดสลีป กรุณารอสักครู่')),
            ],
          ),
        ),
      ),
    );

    try {
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
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleClear() async {
    if (_isLoading) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างประวัติรายการ'),
        content: const Text('ต้องการลบรายการที่บันทึกไว้ทั้งหมดหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ล้าง'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await clearSavedSlips();
      if (!mounted) return;
      setState(() {
        _history = [];
        _lastUpdated = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการล้างรายการ: $e')),
      );
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

  double get _weeklyTotal {
    double total = 0;
    for (final item in _history) {
      final amountStr = (item['amount'] ?? '').toString().replaceAll(',', '');
      total += double.tryParse(amountStr) ?? 0;
    }
    return total;
  }

  double get _overBudget {
    if (_budget <= 0 || _weeklyTotal <= _budget) return 0;
    return _weeklyTotal - _budget;
  }

  double get _budgetProgress {
    if (_budget <= 0) return 0;
    return (_weeklyTotal / _budget).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('หน้าหลัก')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            Text(
              'ประวัติรายการ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'ยังไม่มีรายการ กดปุ่มรีเฟรชเพื่อสแกนสลิป',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              )
            else
              ..._history.map(_buildHistoryTile),
          ],
        ),
      ),
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: _budgetProgress,
                      strokeWidth: 8,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(_budgetProgress * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _overBudget > 0
                          ? 'คุณใช้เกินงบไปแล้ว'
                          : 'สัปดาห์นี้คุณใช้ไปแล้ว',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _overBudget > 0
                          ? '-฿${_overBudget.toStringAsFixed(0)}'
                          : '฿${_weeklyTotal.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: _overBudget > 0
                            ? Colors.red.shade200
                            : Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 32,
                height: 96,
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: IconButton(
                      onPressed: _editBudget,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
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
                      : 'อัพเดทล่าสุด: ${_lastUpdated != null ? formatThaiDate(_lastUpdated!) : '-'}',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
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
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton(
                  onPressed: _isLoading ? null : _handleClear,
                  icon: const Icon(
                    Icons.cleaning_services,
                    color: Colors.white,
                  ),
                  disabledColor: Colors.white38,
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

  void _showSlipImage(Map<String, dynamic> item) {
    final imagePath = item['imagePath']?.toString() ?? '';
    final rawAmount = (item['amount'] ?? '').toString();

    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: InteractiveViewer(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text('ไม่พบไฟล์รูปภาพ'),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                rawAmount == 'Not Found'
                    ? 'ไม่พบยอด'
                    : 'ยอดที่อ่านได้: ฿$rawAmount',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ปิด'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> item) {
    final rawAmount = (item['amount'] ?? '').toString();
    final displayAmount = rawAmount == 'Not Found'
        ? 'ไม่พบยอด'
        : '-฿$rawAmount';

    final txTime = DateTime.tryParse(item['txTime']?.toString() ?? '');
    final subtitle = txTime != null ? formatThaiDate(txTime) : '-';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => _showSlipImage(item),
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade50,
        child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
      ),
      title: Text(item['Bank']?.toString() ?? '-', style: TextStyle()),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: Text(
        displayAmount,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
