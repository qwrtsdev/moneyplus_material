import 'package:flutter/material.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';
import '../systems/plan_storage.dart';
import '../systems/slip_storage.dart';
import '../systems/thai_date.dart';

String _money(double value) {
  return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);
}

class PlanTab extends StatefulWidget {
  const PlanTab({super.key});

  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  List<Map<String, dynamic>> _goals = [];
  List<Map<String, dynamic>> _pendingSlips = [];

  @override
  void initState() {
    super.initState();
    _load();
    slipsRevision.addListener(_load);
  }

  @override
  void dispose() {
    slipsRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final goals = await loadGoals();
    final slips = await loadSavedSlips();
    if (!mounted) return;

    final assigned = goals
        .expand(goalPayments)
        .map((payment) => payment['imagePath'])
        .toSet();
    final pending = slips
        .where(
          (slip) =>
              amountOf(slip) != null && !assigned.contains(slip['imagePath']),
        )
        .toList();
    pending.sort((a, b) {
      final aTime = DateTime.tryParse('${a['txTime']}') ?? DateTime(0);
      final bTime = DateTime.tryParse('${b['txTime']}') ?? DateTime(0);
      return bTime.compareTo(aTime);
    });

    setState(() {
      _goals = goals;
      _pendingSlips = pending;
    });
  }

  Future<void> _createGoal() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _NewGoalDialog(),
    );
    if (result == null) return;

    final goals = [..._goals, result];
    await saveGoals(goals);
    await _load();
  }

  Future<void> _showGoalDetail(Map<String, dynamic> goal) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (context) => _GoalDetailDialog(goal: goal),
    );
    if (deleted != true) return;

    await saveGoals(_goals.where((g) => g['id'] != goal['id']).toList());
    await _load();
  }

  Future<void> _showPendingSheet() async {
    final slip = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppLocalizations.of(context)!.plan_pick_slip,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ..._pendingSlips.map((slip) => _buildPendingTile(context, slip)),
          ],
        ),
      ),
    );
    if (slip == null || !mounted) return;

    await _assignSlip(slip);
  }

  Widget _buildPendingTile(BuildContext context, Map<String, dynamic> slip) {
    final txTime = DateTime.tryParse('${slip['txTime']}');

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.deepPurple.shade50,
        child: const Icon(Icons.receipt_long, color: Colors.deepPurple),
      ),
      title: Text(slip['Bank']?.toString() ?? '-'),
      subtitle: Text(
        txTime != null
            ? formatDate(txTime, Localizations.localeOf(context))
            : '-',
        style: TextStyle(fontSize: 12),
      ),
      trailing: Text(
        '฿${slip['amount']}',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: () => Navigator.pop(context, slip),
    );
  }

  Future<void> _assignSlip(Map<String, dynamic> slip) async {
    final l10n = AppLocalizations.of(context)!;
    if (_goals.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.plan_create_goal_first)));
      return;
    }

    final goal = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.plan_which_goal),
        children: _goals
            .map(
              (goal) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, goal),
                child: Text('${goal['name']}'),
              ),
            )
            .toList(),
      ),
    );
    if (goal == null) return;

    final payments = [
      ...goalPayments(goal),
      {'imagePath': slip['imagePath'], 'amount': amountOf(slip)},
    ];
    final updated = _goals
        .map((g) => g['id'] == goal['id'] ? {...g, 'payments': payments} : g)
        .toList();

    await saveGoals(updated);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.plan_slip_added('${goal['name']}'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.plan_appbar)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_pendingSlips.isNotEmpty) ...[
            _buildPendingBanner(),
            const SizedBox(height: 16),
          ],
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [..._goals.map(_buildGoalCard), _buildAddCard()],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingBanner() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: const Icon(
          Icons.notifications_active,
          color: Colors.deepPurple,
        ),
        title: Text(l10n.plan_new_slips(_pendingSlips.length)),
        subtitle: Text(l10n.plan_new_slips_subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: _showPendingSheet,
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final progress = goalProgress(goal);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: InkWell(
        onTap: () => _showGoalDetail(goal),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                '${goal['name']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 7,
                      backgroundColor: Colors.deepPurple.shade50,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '฿${_money(goalSaved(goal))} / ฿${_money(goalTarget(goal))}',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(128),
        ),
      ),
      child: InkWell(
        onTap: _createGoal,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context)!.plan_add_goal),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewGoalDialog extends StatefulWidget {
  const _NewGoalDialog();

  @override
  State<_NewGoalDialog> createState() => _NewGoalDialogState();
}

class _NewGoalDialogState extends State<_NewGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final target = double.parse(_targetController.text.trim());
    Navigator.pop(context, newGoal(_nameController.text.trim(), target));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.plan_new_goal_title),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.plan_goal_name,
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.plan_goal_name_error;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.plan_goal_target,
                prefixText: '฿ ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0) {
                  return l10n.plan_goal_target_error;
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.common_create)),
      ],
    );
  }
}

class _GoalDetailDialog extends StatelessWidget {
  const _GoalDetailDialog({required this.goal});

  final Map<String, dynamic> goal;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.plan_delete_goal),
        content: Text(l10n.plan_delete_goal_confirm('${goal['name']}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = goalProgress(goal);
    final saved = goalSaved(goal);
    final target = goalTarget(goal);
    final payments = goalPayments(goal);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${goal['name']}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.deepPurple.shade50,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '฿${_money(saved)} / ฿${_money(target)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              saved >= target
                  ? l10n.plan_goal_reached
                  : l10n.plan_remaining(_money(target - saved)),
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.plan_payments(payments.length),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Flexible(
              child: payments.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(l10n.common_no_items),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: payments
                          .map(
                            (payment) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.receipt_long,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                '฿${_money((payment['amount'] as num).toDouble())}',
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.plan_delete_goal),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.common_close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
