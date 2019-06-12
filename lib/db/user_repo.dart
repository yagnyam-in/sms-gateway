import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_gateway/db/firestore_utils.dart';
import 'package:sms_gateway/model/app_state.dart';
import 'package:sms_gateway/model/user_entity.dart';

class UserRepo with FirestoreUtils {
  final AppState appState;
  final DocumentReference root;

  UserRepo(this.appState)
      : root = FirestoreUtils.rootRef(appState) {
    assert(appState != null);
  }

  Future<UserEntity> save(UserEntity user) async {
    await root.setData(user.toJson());
    return user;
  }

  Future<void> delete() async {
    await root.delete();
  }
}
