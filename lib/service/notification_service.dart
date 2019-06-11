import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sms_gateway/db/user_repo.dart';
import 'package:sms_gateway/model/user_entity.dart';
import 'package:sms_gateway/service/sms_service.dart';

class NotificationService {
  static NotificationService _instance;

  static NotificationService instance(FirebaseUser firebaseUser) {
    if (_instance == null) {
      _instance = NotificationService._internal(firebaseUser);
    } else {
      _instance._firebaseUser = firebaseUser;
    }
    return _instance;
  }

  NotificationService._internal(FirebaseUser firebaseUser)
      : _firebaseUser = firebaseUser;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseUser _firebaseUser;
  bool _started = false;

  Future<FirebaseUser> get firebaseUser {
    if (_firebaseUser != null) {
      return Future.value(_firebaseUser);
    } else {
      return FirebaseAuth.instance.currentUser();
    }
  }

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
      if (_firebaseUser != null) {
        UserEntity user = UserEntity(
          uid: _firebaseUser.uid,
          fcmToken: newToken,
        );
        UserRepo(_firebaseUser).save(user);
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
    SmsService.processAllPendingRequests(_firebaseUser);
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
