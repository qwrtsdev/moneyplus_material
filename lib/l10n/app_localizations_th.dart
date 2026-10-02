// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get nav_dashboard => 'หน้าหลัก';

  @override
  String get nav_plan => 'แผน';

  @override
  String get nav_bill => 'บิล';

  @override
  String get nav_settings => 'ตั้งค่า';

  @override
  String get common_cancel => 'ยกเลิก';

  @override
  String get common_ok => 'ตกลง';

  @override
  String get common_close => 'ปิด';

  @override
  String get common_create => 'สร้าง';

  @override
  String get common_delete => 'ลบ';

  @override
  String get common_clear => 'ล้าง';

  @override
  String get common_no_items => 'ยังไม่มีรายการ';

  @override
  String get common_amount_not_found => 'ไม่พบยอด';

  @override
  String get dashboard_appbar => 'หน้าหลัก';

  @override
  String get dashboard_enter_amount => 'กรอกจำนวนเงิน';

  @override
  String get dashboard_loading_slips => 'กำลังโหลดสลีป กรุณารอสักครู่';

  @override
  String dashboard_load_error(String error) {
    return 'เกิดข้อผิดพลาดในการโหลดสลิป: $error';
  }

  @override
  String get dashboard_clear_title => 'ล้างประวัติรายการ';

  @override
  String get dashboard_clear_confirm =>
      'ต้องการลบรายการที่บันทึกไว้ทั้งหมดหรือไม่?';

  @override
  String dashboard_clear_error(String error) {
    return 'เกิดข้อผิดพลาดในการล้างรายการ: $error';
  }

  @override
  String get dashboard_history => 'ประวัติรายการ';

  @override
  String get dashboard_history_empty =>
      'ยังไม่มีรายการ กรุณากดสแกนสลีปเพื่อเริ่มต้น';

  @override
  String get dashboard_over_budget => 'คุณใช้เกินงบไปแล้ว';

  @override
  String get dashboard_spent_this_week => 'สัปดาห์นี้คุณใช้ไปแล้ว';

  @override
  String get dashboard_waiting_images => 'กรุณารอรูปโหลด';

  @override
  String dashboard_last_updated(String date) {
    return 'อัพเดทล่าสุด: $date';
  }

  @override
  String get dashboard_image_not_found => 'ไม่พบไฟล์รูปภาพ';

  @override
  String dashboard_amount_read(String amount) {
    return 'ยอดที่อ่านได้: ฿$amount';
  }

  @override
  String get plan_appbar => 'สมดุลเงิน';

  @override
  String get plan_pick_slip => 'เลือกสลีปที่ต้องการจัดเข้าเป้าหมาย';

  @override
  String get plan_create_goal_first => 'กรุณาสร้างเป้าหมายก่อน';

  @override
  String get plan_which_goal => 'สลีปนี้เป็นการจ่ายของเป้าหมายไหน';

  @override
  String plan_slip_added(String name) {
    return 'เพิ่มสลีปเข้าเป้าหมาย \"$name\" แล้ว';
  }

  @override
  String plan_new_slips(int count) {
    return 'พบสลีปใหม่ $count รายการ';
  }

  @override
  String get plan_new_slips_subtitle => 'เลือกว่าเป็นการจ่ายของเป้าหมายไหน';

  @override
  String get plan_add_goal => 'เพิ่มเป้าหมาย';

  @override
  String get plan_new_goal_title => 'สร้างเป้าหมายใหม่';

  @override
  String get plan_goal_name => 'ชื่อเป้าหมาย';

  @override
  String get plan_goal_name_error => 'กรุณากรอกชื่อเป้าหมาย';

  @override
  String get plan_goal_target => 'จำนวนเงินเป้าหมาย (บาท)';

  @override
  String get plan_goal_target_error => 'กรุณากรอกจำนวนเงินให้ถูกต้อง';

  @override
  String get plan_delete_goal => 'ลบเป้าหมาย';

  @override
  String plan_delete_goal_confirm(String name) {
    return 'ต้องการลบเป้าหมาย \"$name\" หรือไม่?';
  }

  @override
  String get plan_goal_reached => 'ครบตามเป้าหมายแล้ว';

  @override
  String plan_remaining(String amount) {
    return 'เหลืออีก ฿$amount';
  }

  @override
  String plan_payments(int count) {
    return 'รายการที่จ่าย ($count)';
  }

  @override
  String get bill_appbar => 'หารบิล';

  @override
  String get bill_phone_label => 'เบอร์โทรศัพท์พร้อมเพย์';

  @override
  String get bill_phone_error => 'กรุณากรอกเบอร์โทรศัพท์';

  @override
  String get bill_amount_label => 'ยอดเงิน (บาท)';

  @override
  String get bill_amount_error => 'กรุณากรอกยอดเงิน';

  @override
  String get bill_amount_invalid => 'กรุณากรอกตัวเลขให้ถูกต้อง';

  @override
  String get bill_split_title => 'หารบิล';

  @override
  String get bill_split_subtitle => 'หารบิลเท่ากันระหว่างหลายคน';

  @override
  String get bill_people_label => 'จำนวนคน';

  @override
  String bill_people_count(int count) {
    return '$count คน';
  }

  @override
  String get bill_per_person => 'จำนวนเงินต่อคน:';

  @override
  String get bill_generate_qr => 'สร้าง QR Code';

  @override
  String get bill_scan_to_pay => 'สแกน QR Code เพื่อชำระเงิน';

  @override
  String bill_qr_amount(String amount) {
    return 'จำนวนเงิน: ฿$amount';
  }

  @override
  String bill_split_summary(int count, String total) {
    return 'หารระหว่าง $count คน (รวม: ฿$total)';
  }

  @override
  String get bill_sharing => 'กำลังสร้าง...';

  @override
  String get bill_share_qr => 'แชร์ QR Code';

  @override
  String bill_share_text(String amount) {
    return 'QR พร้อมเพย์ ยอด ฿$amount';
  }

  @override
  String bill_share_text_split(String amount, int count) {
    return 'QR พร้อมเพย์ ยอด ฿$amount (หารระหว่าง $count คน)';
  }

  @override
  String bill_share_error(String error) {
    return 'แชร์ QR Code ไม่สำเร็จ: $error';
  }

  @override
  String get settings_appbar => 'ตั้งค่า';
}
