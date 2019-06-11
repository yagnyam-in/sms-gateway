import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sms_gateway/db/app_repo.dart';
import 'package:sms_gateway/db/request_repo.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/model/request_entity.dart';
import 'package:uuid/uuid.dart';

class SmsService {
  static const platform =
      const MethodChannel('sms_gateway.yagnyam.in/SmsService');

  static Future<String> sendSMS({
    String phone,
    String message,
  }) async {
    String result;
    try {
      result = await platform.invokeMethod('sendSMS', {
        'phone': phone,
        'message': message,
      });
    } on PlatformException catch (e) {
      print("Error sending SMS: ${e.message}");
      throw e.message;
    } catch (e) {
      print("Error sending SMS: $e");
      throw e;
    }
    return result;
  }

  static Future<void> processRequest(
    FirebaseUser firebaseUser,
    RequestEntity request,
  ) async {
    print("Sending SMS for $request");
    try {
      await sendSMS(phone: request.phone, message: request.message);
      _updateAppStats(firebaseUser, request);
      _markRequestProcessed(firebaseUser, request);
    } catch (e) {
      print("Failed to send SMS: $e");
    }
  }

  static Future<void> processAllPendingRequests(
    FirebaseUser firebaseUser, [
    List<RequestEntity> pendingRequests,
  ]) async {
    if (firebaseUser != null) {
      pendingRequests = pendingRequests ??
          await RequestRepo(firebaseUser).fetchPendingRequests();
      pendingRequests.forEach((r) => processRequest(firebaseUser, r));
    }
  }

  static Future<void> _updateAppStats(
    FirebaseUser firebaseUser,
    RequestEntity request,
  ) async {
    if (firebaseUser != null) {
      AppRepo appRepo = AppRepo(firebaseUser);
      AppEntity app = await appRepo.fetchApp(request.appId);
      if (app == null) {
        app = AppEntity(
          uid: Uuid().v4(),
          id: request.appId,
          name: request.appId,
          description: 'Not yet registered',
          accessToken: 'Dont know',
        );
      }
      app = app.copy(smsCount: app.smsCount + 1);
      await appRepo.save(app);
    }
  }

  static Future<void> _markRequestProcessed(
    FirebaseUser firebaseUser,
    RequestEntity request,
  ) async {
    if (firebaseUser != null) {
      // await RequestRepo(firebaseUser).markProcessed(request);
    }
  }
}
