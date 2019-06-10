import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_gateway/sms_service.dart';

mixin SmsHelper {
  final SmsService _smsService = SmsService();

  void showToast(String toast);

  Future<void> sendSMS({
    String phone,
    String message,
  }) async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.sms);
    if (permission != PermissionStatus.granted) {
      Map<PermissionGroup, PermissionStatus> permissions =
          await PermissionHandler().requestPermissions([PermissionGroup.sms]);
      permissions.forEach((k, v) => print("$k = $v"));
      if (permissions[PermissionGroup.sms] != PermissionStatus.granted) {
        showToast("Permission not granted");
      }
    }
    try {
      await _smsService.sendSMS(phone: phone, message: message);
      showToast("SMS Sent");
    } on PlatformException catch (e) {
      print("Error sending SMS: $e");
      showToast(e.message);
    } catch (e) {
      print("Error sending SMS: $e");
      showToast("$e");
    }
  }
}
