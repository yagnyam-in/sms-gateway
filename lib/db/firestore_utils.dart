import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_gateway/model/app_state.dart';

mixin FirestoreUtils {
  static DocumentReference rootRef(AppState appState) {
    assert(appState?.userId != null);
    return Firestore.instance
        .collection('/users')
        .document('${appState.userId}');
  }
}
