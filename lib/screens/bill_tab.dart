import 'package:flutter/material.dart';
import 'package:thai_promptpay_flutter/thai_promptpay_flutter.dart';

class BillTab extends StatefulWidget {
  @override
  State<BillTab> createState() => _BillTabState();
}

class _BillTabState extends State<BillTab> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill'),
      ),
      body: Center(
        child: PromptPayQr(
          target: const PromptPayTarget(PromptPayType.mobile, '0812345678'),
          amountSatang: 5000,
          size: 240,
        ),
      ),
    );
  }
}