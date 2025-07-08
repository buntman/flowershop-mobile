import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TemporaryStorage {
  static Future<void> storePaymentOption(String payment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('payment_option', payment);
  }

  static Future<void> storePickupDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    await prefs.setString('pickup_date', formattedDate);
  }

  static Future<void> storePickupTime(TimeOfDay time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pickup_time', '${time.hour}:${time.minute}');
  }

  static Future<String?> getPaymentOption() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('payment_option');
  }

  static Future<String?> getPickupDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('pickup_date');
  }

  static Future<String?> getPickupTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('pickup_time');
  }

  static Future<void> removeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('payment_option');
    await prefs.remove('pickup_date');
    await prefs.remove('pickup_time');
  }
}
