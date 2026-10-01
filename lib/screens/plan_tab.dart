import 'package:flutter/material.dart';

class PlanTab extends StatefulWidget {
  @override
  State<PlanTab> createState() => _PlanTabState();
}

class _PlanTabState extends State<PlanTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สมดุลเงิน')),
      body: Center(child: Text('Welcome to the Plan!')),
    );
  }
}
