import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';
import 'package:moneyplus_material/systems/preference.dart';

class BillTab extends StatefulWidget {
  const BillTab({super.key});

  @override
  State<BillTab> createState() => _BillTabState();
}

class _BillTabState extends State<BillTab> {
  final _formKey = GlobalKey<FormState>();
  final _screenshotController = ScreenshotController();

  late TextEditingController _phoneNumberController;
  late TextEditingController _amountController;

  String? _targetPhoneNumber;
  int? _amountSatang;

  bool _isSplitBill = false;
  int _splitPeopleCount = 2;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _amountController = TextEditingController(text: '0.00');

    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final savedPhone = await getData('phoneNumber') ?? '';
    if (!mounted) return;

    setState(() {
      _phoneNumberController.text = savedPhone;
      _targetPhoneNumber = savedPhone;
    });

    if (savedPhone.isNotEmpty) {
      _generateQrCode();
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _generateQrCode() {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneNumberController.text.trim();
    saveData('phoneNumber', phone);

    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final finalAmount = _isSplitBill
        ? (totalAmount / _splitPeopleCount)
        : totalAmount;

    setState(() {
      _targetPhoneNumber = phone;
      _amountSatang = (finalAmount * 100).round();
    });

    FocusScope.of(context).unfocus();
  }

  Future<void> _shareQrCode() async {
    if (_isSharing) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSharing = true);

    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 20),
        pixelRatio: 3.0,
      );

      if (imageBytes == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/promptpay_qr.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final shareText = _isSplitBill
          ? l10n.bill_share_text_split(
              ((_amountSatang ?? 0) / 100).toStringAsFixed(2),
              _splitPeopleCount,
            )
          : l10n.bill_share_text(totalAmount.toStringAsFixed(2));

      await Share.shareXFiles([XFile(imagePath)], text: shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.bill_share_error('$e'))));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final totalAmountDouble =
        double.tryParse(_amountController.text.trim()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bill_appbar)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(128),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          labelText: l10n.bill_phone_label,
                          hintText: '0812345678',
                          prefixIcon: const Icon(Icons.phone_android),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.bill_phone_error;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: l10n.bill_amount_label,
                          hintText: '0.00',
                          prefixIcon: const Icon(Icons.attach_money),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) {
                          if (_isSplitBill) setState(() {});
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.bill_amount_error;
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return l10n.bill_amount_invalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.bill_split_title),
                        subtitle: Text(l10n.bill_split_subtitle),
                        value: _isSplitBill,
                        onChanged: (value) {
                          setState(() {
                            _isSplitBill = value;
                          });
                        },
                      ),

                      if (_isSplitBill) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _splitPeopleCount,
                          decoration: InputDecoration(
                            labelText: l10n.bill_people_label,
                            prefixIcon: const Icon(Icons.group),
                            border: const OutlineInputBorder(),
                          ),
                          items: List.generate(9, (index) => index + 2).map((
                            count,
                          ) {
                            return DropdownMenuItem<int>(
                              value: count,
                              child: Text(l10n.bill_people_count(count)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _splitPeopleCount = value;
                              });
                            }
                          },
                        ),
                        if (totalAmountDouble > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withAlpha(100),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.bill_per_person,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '฿${(totalAmountDouble / _splitPeopleCount).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _generateQrCode,
                        icon: const Icon(Icons.qr_code_2),
                        label: Text(l10n.bill_generate_qr),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_targetPhoneNumber != null &&
                  _targetPhoneNumber!.isNotEmpty) ...[
                Screenshot(
                  controller: _screenshotController,
                  child: Card(
                    elevation: 2,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.bill_scan_to_pay,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(20),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: PromptPayQr(
                              target: PromptPayTarget(
                                PromptPayType.mobile,
                                _targetPhoneNumber!,
                              ),
                              amountSatang: _amountSatang,
                              size: 220,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'PromptPay ID: $_targetPhoneNumber',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (_amountSatang != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              l10n.bill_qr_amount(
                                (_amountSatang! / 100).toStringAsFixed(2),
                              ),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isSplitBill) ...[
                              const SizedBox(height: 2),
                              Text(
                                l10n.bill_split_summary(
                                  _splitPeopleCount,
                                  totalAmountDouble.toStringAsFixed(2),
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isSharing ? null : _shareQrCode,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.share),
                  label: Text(
                    _isSharing ? l10n.bill_sharing : l10n.bill_share_qr,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
