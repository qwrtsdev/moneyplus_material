import 'dart:io';
import 'package:flutter/material.dart';
import '../systems/preference.dart';
import '../systems/receipt_recognition.dart';
import '../systems/slip_storage.dart';
import '../systems/thai_date.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';

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
    slipsRevision.addListener(_loadSavedData);
  }

  @override
  void dispose() {
    slipsRevision.removeListener(_loadSavedData);
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

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dashboard_enter_amount),
        content: TextField(
          controller: _budgetController,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.dashboard_enter_amount,
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
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.common_ok),
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

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(l10n.dashboard_loading_slips)),
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
      debugPrint('processNewSlips failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dashboard_load_error)));
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

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dashboard_clear_title),
        content: Text(l10n.dashboard_clear_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.common_clear),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dashboard_clear_error('$e'))));
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboard_appbar)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 24),
            Text(
              l10n.dashboard_history,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  l10n.dashboard_history_empty,
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
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);

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
                          ? l10n.dashboard_over_budget
                          : l10n.dashboard_spent_this_week,
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
                      ? l10n.dashboard_waiting_images
                      : l10n.dashboard_last_updated(
                          _lastUpdated != null
                              ? formatDate(_lastUpdated!, locale)
                              : '-',
                        ),
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
    final l10n = AppLocalizations.of(context)!;

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
                  errorBuilder: (context, error, stackTrace) => Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(l10n.dashboard_image_not_found),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                rawAmount == 'Not Found'
                    ? l10n.common_amount_not_found
                    : l10n.dashboard_amount_read(rawAmount),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.common_close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> item) {
    final rawAmount = (item['amount'] ?? '').toString();
    final displayAmount = rawAmount == 'Not Found'
        ? AppLocalizations.of(context)!.common_amount_not_found
        : '-฿$rawAmount';

    final txTime = DateTime.tryParse(item['txTime']?.toString() ?? '');
    final subtitle = txTime != null
        ? formatDate(txTime, Localizations.localeOf(context))
        : '-';

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
