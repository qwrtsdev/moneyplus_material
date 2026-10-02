import 'package:flutter/material.dart';
import 'dashboard_tab.dart';
import 'plan_tab.dart';
import 'bill_tab.dart';
import 'settings_tab.dart';
import 'package:moneyplus_material/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onLocaleChanged});

  final ValueChanged<Locale>? onLocaleChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Widget> tabs = [
      DashboardTab(),
      PlanTab(),
      BillTab(),
      SettingsTab(onLocaleChanged: widget.onLocaleChanged),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.nav_dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: l10n.nav_plan,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.request_quote),
            label: l10n.nav_bill,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.nav_settings,
          ),
        ],
      ),
    );
  }
}
