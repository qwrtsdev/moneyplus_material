import 'dart:io';
import 'package:flutter/material.dart';
import '../systems/preference.dart';
import '../systems/receipt_recognition.dart';
import '../systems/slip_storage.dart';
import '../systems/thai_date.dart';
import '../systems/amount_format.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _budgetController = TextEditingController();
  final _customLabelController = TextEditingController();
  final _customAmountController = TextEditingController();

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
    _customLabelController.dispose();
    _customAmountController.dispose();
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
    _budgetController.text = _budget > 0
      ? formatAmount(_budget, decimalDigits: 2)
      : '';

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

  Future<void> _addCustomHistory() async {
    final l10n = AppLocalizations.of(context)!;
    _customLabelController.clear();
    _customAmountController.clear();
    final today = DateTime.now();
    var selectedDate = today;
    var showErrors = false;

    final entry = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text(l10n.dashboard_add_history),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customLabelController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.dashboard_history_label,
                  errorText: showErrors &&
                          _customLabelController.text.trim().isEmpty
                      ? l10n.dashboard_history_label_error
                      : null,
                ),
                onChanged: (_) {
                  if (showErrors) setDialogState(() {});
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.dashboard_history_amount,
                  prefixText: '฿ ',
                  errorText: showErrors &&
                          (double.tryParse(
                                    _customAmountController.text
                                        .trim()
                                        .replaceAll(',', ''),
                                  ) ??
                                  0) <=
                              0
                      ? l10n.dashboard_history_amount_error
                      : null,
                ),
                onChanged: (_) {
                  if (showErrors) setDialogState(() {});
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: dialogContext,
                    initialDate: selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: today,
                  );
                  if (picked == null) return;
                  setDialogState(() {
                    selectedDate = DateTime(
                      picked.year,
                      picked.month,
                      picked.day,
                      selectedDate.hour,
                      selectedDate.minute,
                      selectedDate.second,
                    );
                  });
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  '${l10n.dashboard_history_date}: '
                  '${formatDate(selectedDate, Localizations.localeOf(context))}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () {
                final label = _customLabelController.text.trim();
                final amount = double.tryParse(
                  _customAmountController.text.trim().replaceAll(',', ''),
                );
                if (label.isEmpty || amount == null || amount <= 0) {
                  setDialogState(() => showErrors = true);
                  return;
                }
                Navigator.pop(dialogContext, {
                  'Bank': label,
                  'amount': amount.toStringAsFixed(2),
                  'txTime': selectedDate.toIso8601String(),
                  'imagePath': '',
                  'custom': true,
                });
              },
              child: Text(l10n.common_create),
            ),
          ],
        ),
      ),
    );

    if (entry == null || !mounted) return;

    try {
      final saved = await loadSavedSlips();
      final updated = [...saved, entry];
      await saveSlips(updated);
      if (!mounted) return;
      setState(() => _history = _sortedByTime(updated));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dashboard_add_history_error('$e'))),
      );
    }
  }

  Future<void> _editHistoryAmount(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context)!;
    final currentAmount = amountOf(item);
    _customAmountController.text = currentAmount == null
      ? ''
      : formatAmount(currentAmount, decimalDigits: 2);
    var showError = false;

    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.dashboard_edit_history),
          content: TextField(
            controller: _customAmountController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.dashboard_history_amount,
              prefixText: '฿ ',
              errorText: showError ? l10n.dashboard_history_amount_error : null,
            ),
            onChanged: (_) {
              if (showError) setDialogState(() => showError = false);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(
                  _customAmountController.text.trim().replaceAll(',', ''),
                );
                if (value == null || value <= 0) {
                  setDialogState(() => showError = true);
                  return;
                }
                Navigator.pop(dialogContext, value);
              },
              child: Text(l10n.common_ok),
            ),
          ],
        ),
      ),
    );
    if (amount == null || !mounted) return;

    try {
      final saved = await loadSavedSlips();
      final index = saved.indexWhere(
        (record) =>
            record['imagePath'] == item['imagePath'] &&
            record['txTime'] == item['txTime'] &&
            record['Bank'] == item['Bank'] &&
            record['amount'] == item['amount'] &&
            record['custom'] == item['custom'],
      );
      if (index == -1) {
        await _loadSavedData();
        return;
      }

      final updated = [...saved];
      updated[index] = {
        ...updated[index],
        'amount': amount.toStringAsFixed(2),
      };
      await saveSlips(updated);
      if (!mounted) return;
      setState(() => _history = _sortedByTime(updated));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dashboard_edit_history_error('$e'))),
      );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomHistory,
        tooltip: l10n.dashboard_add_history,
        child: const Icon(Icons.add),
      ),
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
                          ? '-฿${formatAmount(_overBudget, decimalDigits: 0)}'
                          : '฿${formatAmount(_weeklyTotal, decimalDigits: 0)}',
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
                  : l10n.dashboard_amount_read(formatAmountText(rawAmount)),
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
    final l10n = AppLocalizations.of(context)!;
    final rawAmount = (item['amount'] ?? '').toString();
    final displayAmount = rawAmount == 'Not Found'
      ? l10n.common_amount_not_found
      : '-฿${formatAmountText(rawAmount)}';

    final txTime = DateTime.tryParse(item['txTime']?.toString() ?? '');
    final subtitle = txTime != null
        ? formatDate(txTime, Localizations.localeOf(context))
        : '-';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: item['custom'] == true ? null : () => _showSlipImage(item),
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade50,
        child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
      ),
      title: Text(item['Bank']?.toString() ?? '-', style: TextStyle()),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayAmount,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 3),
          IconButton(
            tooltip: l10n.dashboard_edit_history,
            onPressed: () => _editHistoryAmount(item),
            icon: const Icon(Icons.edit_outlined, size: 20),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
