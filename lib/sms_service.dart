
import 'package:flutter/services.dart';

class SmsService {
  static const platform = const MethodChannel('sms_gateway.yagnyam.in/SmsService');

  Future<String> sendSMS({
    String phone,
    String message,
  }) async {
    return platform.invokeMethod('sendSMS', {
      'phone': phone,
      'message': message,
    });
  }

}