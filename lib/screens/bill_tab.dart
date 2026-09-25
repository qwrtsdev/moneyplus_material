import 'package:flutter/material.dart';

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
        child: Text(
          'Welcome to the Bill!',
        ),
      ),
    );
  }
}