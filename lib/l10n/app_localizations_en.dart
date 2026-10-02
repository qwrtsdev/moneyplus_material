// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get nav_dashboard => 'Dashboard';

  @override
  String get nav_plan => 'Plan';

  @override
  String get nav_bill => 'Bill';

  @override
  String get nav_settings => 'Settings';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Close';

  @override
  String get common_create => 'Create';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_no_items => 'No items yet';

  @override
  String get common_amount_not_found => 'Amount not found';

  @override
  String get dashboard_appbar => 'Dashboard';

  @override
  String get dashboard_enter_amount => 'Enter amount';

  @override
  String get dashboard_loading_slips => 'Loading slips, please wait';

  @override
  String dashboard_load_error(String error) {
    return 'Failed to load slips: $error';
  }

  @override
  String get dashboard_clear_title => 'Clear history';

  @override
  String get dashboard_clear_confirm => 'Delete all saved items?';

  @override
  String dashboard_clear_error(String error) {
    return 'Failed to clear items: $error';
  }

  @override
  String get dashboard_history => 'History';

  @override
  String get dashboard_history_empty =>
      'No items yet. Tap scan to load your slips.';

  @override
  String get dashboard_over_budget => 'You\'re over budget by';

  @override
  String get dashboard_spent_this_week => 'Spent this week';

  @override
  String get dashboard_waiting_images => 'Waiting for images to load';

  @override
  String dashboard_last_updated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get dashboard_image_not_found => 'Image file not found';

  @override
  String dashboard_amount_read(String amount) {
    return 'Amount read: ฿$amount';
  }

  @override
  String get plan_appbar => 'Money Balance';

  @override
  String get plan_pick_slip => 'Choose a slip to assign to a goal';

  @override
  String get plan_create_goal_first => 'Please create a goal first';

  @override
  String get plan_which_goal => 'Which goal is this slip for?';

  @override
  String plan_slip_added(String name) {
    return 'Added slip to goal \"$name\"';
  }

  @override
  String plan_new_slips(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new slips found',
      one: '1 new slip found',
    );
    return '$_temp0';
  }

  @override
  String get plan_new_slips_subtitle => 'Choose which goal each one paid for';

  @override
  String get plan_add_goal => 'Add goal';

  @override
  String get plan_new_goal_title => 'Create new goal';

  @override
  String get plan_goal_name => 'Goal name';

  @override
  String get plan_goal_name_error => 'Please enter a name';

  @override
  String get plan_goal_target => 'Target amount (THB)';

  @override
  String get plan_goal_target_error => 'Please enter a valid amount';

  @override
  String get plan_delete_goal => 'Delete goal';

  @override
  String plan_delete_goal_confirm(String name) {
    return 'Delete goal \"$name\"?';
  }

  @override
  String get plan_goal_reached => 'Goal reached';

  @override
  String plan_remaining(String amount) {
    return '฿$amount to go';
  }

  @override
  String plan_payments(int count) {
    return 'Payments ($count)';
  }

  @override
  String get bill_appbar => 'Split Bill';

  @override
  String get bill_phone_label => 'PromptPay phone number';

  @override
  String get bill_phone_error => 'Please enter phone number';

  @override
  String get bill_amount_label => 'Amount (THB)';

  @override
  String get bill_amount_error => 'Please enter amount';

  @override
  String get bill_amount_invalid => 'Please enter a valid number';

  @override
  String get bill_split_title => 'Split Bill';

  @override
  String get bill_split_subtitle => 'Split the bill equally between people';

  @override
  String get bill_people_label => 'Number of people';

  @override
  String bill_people_count(int count) {
    return '$count people';
  }

  @override
  String get bill_per_person => 'Amount per person:';

  @override
  String get bill_generate_qr => 'Generate QR Code';

  @override
  String get bill_scan_to_pay => 'Scan QR Code to pay';

  @override
  String bill_qr_amount(String amount) {
    return 'Amount: ฿$amount';
  }

  @override
  String bill_split_summary(int count, String total) {
    return 'Split among $count people (total: ฿$total)';
  }

  @override
  String get bill_sharing => 'Creating...';

  @override
  String get bill_share_qr => 'Share QR Code';

  @override
  String bill_share_text(String amount) {
    return 'PromptPay QR for ฿$amount';
  }

  @override
  String bill_share_text_split(String amount, int count) {
    return 'PromptPay QR for ฿$amount (Split among $count people)';
  }

  @override
  String bill_share_error(String error) {
    return 'Failed to share QR code: $error';
  }

  @override
  String get settings_appbar => 'Settings';
}
