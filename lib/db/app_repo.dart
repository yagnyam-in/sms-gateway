import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/db/firestore_utils.dart';

class AppRepo with FirestoreUtils {
  CollectionReference get _appsRef => root.collection('apps');

  DocumentReference ref(String appId) {
    return _appsRef.document(appId);
  }

  final FirebaseUser firebaseUser;
  final DocumentReference root;

  AppRepo(this.firebaseUser) : root = FirestoreUtils.rootRef(firebaseUser) {
    assert(firebaseUser != null);
  }

  Stream<List<AppEntity>> fetchApps() {
    return _appsRef.snapshots().map((qs) {
      if (qs.documents != null) {
        return qs.documents.map((s) => AppEntity.fromJson(s.data)).toList();
      } else {
        return [];
      }
    });
  }

  Future<AppEntity> save(AppEntity app) async {
    await ref(app.uid).setData(app.toJson());
    return app;
  }
}
