import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sms_gateway/db/firestore_utils.dart';
import 'package:sms_gateway/model/user_entity.dart';

class UserRepo with FirestoreUtils {
  final FirebaseUser firebaseUser;
  final DocumentReference root;

  UserRepo(this.firebaseUser) : root = FirestoreUtils.rootRef(firebaseUser) {
    assert(firebaseUser != null);
  }

  Future<UserEntity> save(UserEntity user) async {
    await root.setData(user.toJson());
    return user;
  }
}
