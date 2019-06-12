import 'package:flutter/services.dart';
import 'package:sms_gateway/db/app_repo.dart';
import 'package:sms_gateway/db/request_repo.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/model/app_state.dart';
import 'package:sms_gateway/model/request_entity.dart';

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
    AppState appState,
    RequestEntity request,
  ) async {
    print("Sending SMS for $request");
    try {
      await sendSMS(phone: request.phone, message: request.message);
      _updateAppStats(appState, request);
      _markRequestProcessed(appState, request);
    } catch (e) {
      print("Failed to send SMS: $e");
    }
  }

  static Future<void> processAllPendingRequests(
    AppState appState, [
    List<RequestEntity> pendingRequests,
  ]) async {
    if (appState != null) {
      pendingRequests =
          pendingRequests ?? await RequestRepo(appState).fetchPendingRequests();
      pendingRequests.forEach((r) => processRequest(appState, r));
    }
  }

  static Future<void> _updateAppStats(
    AppState appState,
    RequestEntity request,
  ) async {
    if (appState != null) {
      AppRepo appRepo = AppRepo(appState);
      AppEntity app = await appRepo.fetchApp(request.appId);
      if (app == null) {
        app = AppEntity(
          userId: appState.userId,
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
    AppState appState,
    RequestEntity request,
  ) async {
    if (appState != null) {
      await RequestRepo(appState).markProcessed(request);
    }
  }
}
