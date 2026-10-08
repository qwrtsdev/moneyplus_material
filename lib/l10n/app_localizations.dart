import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @nav_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get nav_dashboard;

  /// No description provided for @nav_plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get nav_plan;

  /// No description provided for @nav_bill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get nav_bill;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get common_create;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get common_clear;

  /// No description provided for @common_no_items.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get common_no_items;

  /// No description provided for @common_amount_not_found.
  ///
  /// In en, this message translates to:
  /// **'Amount not found'**
  String get common_amount_not_found;

  /// No description provided for @dashboard_appbar.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard_appbar;

  /// No description provided for @dashboard_enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get dashboard_enter_amount;

  /// No description provided for @dashboard_add_history.
  ///
  /// In en, this message translates to:
  /// **'Add history'**
  String get dashboard_add_history;

  /// No description provided for @dashboard_history_label.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get dashboard_history_label;

  /// No description provided for @dashboard_history_label_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get dashboard_history_label_error;

  /// No description provided for @dashboard_history_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get dashboard_history_amount;

  /// No description provided for @dashboard_history_amount_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get dashboard_history_amount_error;

  /// No description provided for @dashboard_history_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dashboard_history_date;

  /// No description provided for @dashboard_add_history_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add history: {error}'**
  String dashboard_add_history_error(String error);

  /// No description provided for @dashboard_loading_slips.
  ///
  /// In en, this message translates to:
  /// **'Loading slips, please wait'**
  String get dashboard_loading_slips;

  /// No description provided for @dashboard_load_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load slips. Please try again.'**
  String get dashboard_load_error;

  /// No description provided for @dashboard_clear_title.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get dashboard_clear_title;

  /// No description provided for @dashboard_clear_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all saved items?'**
  String get dashboard_clear_confirm;

  /// No description provided for @dashboard_clear_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear items: {error}'**
  String dashboard_clear_error(String error);

  /// No description provided for @dashboard_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dashboard_history;

  /// No description provided for @dashboard_history_empty.
  ///
  /// In en, this message translates to:
  /// **'No items yet. Tap scan to load your slips.'**
  String get dashboard_history_empty;

  /// No description provided for @dashboard_over_budget.
  ///
  /// In en, this message translates to:
  /// **'You\'re over budget by'**
  String get dashboard_over_budget;

  /// No description provided for @dashboard_spent_this_week.
  ///
  /// In en, this message translates to:
  /// **'Spent this week'**
  String get dashboard_spent_this_week;

  /// No description provided for @dashboard_waiting_images.
  ///
  /// In en, this message translates to:
  /// **'Waiting for images to load'**
  String get dashboard_waiting_images;

  /// No description provided for @dashboard_last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String dashboard_last_updated(String date);

  /// No description provided for @dashboard_image_not_found.
  ///
  /// In en, this message translates to:
  /// **'Image file not found'**
  String get dashboard_image_not_found;

  /// No description provided for @dashboard_amount_read.
  ///
  /// In en, this message translates to:
  /// **'Amount read: ฿{amount}'**
  String dashboard_amount_read(String amount);

  /// No description provided for @plan_appbar.
  ///
  /// In en, this message translates to:
  /// **'Money Balance'**
  String get plan_appbar;

  /// No description provided for @plan_pick_slip.
  ///
  /// In en, this message translates to:
  /// **'Choose a slip to assign to a goal'**
  String get plan_pick_slip;

  /// No description provided for @plan_create_goal_first.
  ///
  /// In en, this message translates to:
  /// **'Please create a goal first'**
  String get plan_create_goal_first;

  /// No description provided for @plan_which_goal.
  ///
  /// In en, this message translates to:
  /// **'Which goal is this slip for?'**
  String get plan_which_goal;

  /// No description provided for @plan_slip_added.
  ///
  /// In en, this message translates to:
  /// **'Added slip to goal \"{name}\"'**
  String plan_slip_added(String name);

  /// No description provided for @plan_new_slips.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new slip found} other{{count} new slips found}}'**
  String plan_new_slips(int count);

  /// No description provided for @plan_new_slips_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which goal each one paid for'**
  String get plan_new_slips_subtitle;

  /// No description provided for @plan_add_goal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get plan_add_goal;

  /// No description provided for @plan_new_goal_title.
  ///
  /// In en, this message translates to:
  /// **'Create new goal'**
  String get plan_new_goal_title;

  /// No description provided for @plan_goal_name.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get plan_goal_name;

  /// No description provided for @plan_goal_name_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get plan_goal_name_error;

  /// No description provided for @plan_goal_target.
  ///
  /// In en, this message translates to:
  /// **'Target amount (THB)'**
  String get plan_goal_target;

  /// No description provided for @plan_goal_target_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get plan_goal_target_error;

  /// No description provided for @plan_delete_goal.
  ///
  /// In en, this message translates to:
  /// **'Delete goal'**
  String get plan_delete_goal;

  /// No description provided for @plan_delete_goal_confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete goal \"{name}\"?'**
  String plan_delete_goal_confirm(String name);

  /// No description provided for @plan_goal_reached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get plan_goal_reached;

  /// No description provided for @plan_remaining.
  ///
  /// In en, this message translates to:
  /// **'฿{amount} to go'**
  String plan_remaining(String amount);

  /// No description provided for @plan_payments.
  ///
  /// In en, this message translates to:
  /// **'Payments ({count})'**
  String plan_payments(int count);

  /// No description provided for @bill_appbar.
  ///
  /// In en, this message translates to:
  /// **'Split Bill'**
  String get bill_appbar;

  /// No description provided for @bill_phone_label.
  ///
  /// In en, this message translates to:
  /// **'PromptPay phone number'**
  String get bill_phone_label;

  /// No description provided for @bill_phone_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get bill_phone_error;

  /// No description provided for @bill_amount_label.
  ///
  /// In en, this message translates to:
  /// **'Amount (THB)'**
  String get bill_amount_label;

  /// No description provided for @bill_amount_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get bill_amount_error;

  /// No description provided for @bill_amount_invalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get bill_amount_invalid;

  /// No description provided for @bill_split_title.
  ///
  /// In en, this message translates to:
  /// **'Split Bill'**
  String get bill_split_title;

  /// No description provided for @bill_split_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Split the bill equally between people'**
  String get bill_split_subtitle;

  /// No description provided for @bill_people_label.
  ///
  /// In en, this message translates to:
  /// **'Number of people'**
  String get bill_people_label;

  /// No description provided for @bill_people_count.
  ///
  /// In en, this message translates to:
  /// **'{count} people'**
  String bill_people_count(int count);

  /// No description provided for @bill_per_person.
  ///
  /// In en, this message translates to:
  /// **'Amount per person:'**
  String get bill_per_person;

  /// No description provided for @bill_generate_qr.
  ///
  /// In en, this message translates to:
  /// **'Generate QR Code'**
  String get bill_generate_qr;

  /// No description provided for @bill_scan_to_pay.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code to pay'**
  String get bill_scan_to_pay;

  /// No description provided for @bill_qr_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount: ฿{amount}'**
  String bill_qr_amount(String amount);

  /// No description provided for @bill_split_summary.
  ///
  /// In en, this message translates to:
  /// **'Split among {count} people (total: ฿{total})'**
  String bill_split_summary(int count, String total);

  /// No description provided for @bill_sharing.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get bill_sharing;

  /// No description provided for @bill_share_qr.
  ///
  /// In en, this message translates to:
  /// **'Share QR Code'**
  String get bill_share_qr;

  /// No description provided for @bill_share_text.
  ///
  /// In en, this message translates to:
  /// **'PromptPay QR for ฿{amount}'**
  String bill_share_text(String amount);

  /// No description provided for @bill_share_text_split.
  ///
  /// In en, this message translates to:
  /// **'PromptPay QR for ฿{amount} (Split among {count} people)'**
  String bill_share_text_split(String amount, int count);

  /// No description provided for @bill_share_error.
  ///
  /// In en, this message translates to:
  /// **'Failed to share QR code: {error}'**
  String bill_share_error(String error);

  /// No description provided for @settings_appbar.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_appbar;

  /// No description provided for @settings_system_default.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settings_system_default;

  /// No description provided for @settings_text_size.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get settings_text_size;

  /// No description provided for @settings_text_size_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get settings_text_size_normal;

  /// No description provided for @settings_text_size_big.
  ///
  /// In en, this message translates to:
  /// **'Big'**
  String get settings_text_size_big;

  /// No description provided for @settings_text_size_biggest.
  ///
  /// In en, this message translates to:
  /// **'Biggest'**
  String get settings_text_size_biggest;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
