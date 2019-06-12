import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sms_gateway/db/user_repo.dart';
import 'package:sms_gateway/model/app_state.dart';
import 'package:sms_gateway/model/user_entity.dart';
import 'package:sms_gateway/service/sms_service.dart';

class NotificationService {
  static NotificationService _instance;

  static NotificationService instance(AppState appState) {
    if (_instance == null) {
      _instance = NotificationService._internal(appState);
    } else {
      _instance._appState = appState;
    }
    return _instance;
  }

  NotificationService._internal(AppState appState) : _appState = appState;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  AppState _appState;
  bool _started = false;

  void start() {
    if (!_started) {
      _started = true;
      _start();
    }
  }

  void refreshToken() {
    _firebaseMessaging
        .getToken()
        .then(tokenRefresh, onError: tokenRefreshFailure);
  }

  void _start() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.onTokenRefresh
        .listen(tokenRefresh, onError: tokenRefreshFailure);
    _firebaseMessaging.configure(
      onMessage: onMessage,
      onLaunch: onLaunch,
      onResume: onResume,
    );
  }

  void tokenRefresh(String newToken) async {
    if (newToken != null) {
      print("New FCM Token $newToken");
      if (_appState?.firebaseUser != null) {
        UserEntity user = UserEntity(
          uid: _appState.firebaseUser.uid,
          fcmToken: newToken,
        );
        UserRepo(_appState).save(user);
      }
    }
  }

  void tokenRefreshFailure(error) {
    print("FCM token refresh failed with error $error");
  }

  Future<void> onMessage(Map<String, dynamic> message) {
    print("onMessage $message");
    Map<dynamic, dynamic> data = message['data'];
    print('data: $data');
    SmsService.processAllPendingRequests(_appState);
    return null;
  }

  Future<void> onLaunch(Map<String, dynamic> message) {
    print("onLaunch $message");
    return null;
  }

  Future<void> onResume(Map<String, dynamic> message) {
    print("onResume $message");
    return null;
  }
}
