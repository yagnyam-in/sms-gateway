import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sms_gateway/db/firestore_utils.dart';
import 'package:sms_gateway/model/app_entity.dart';

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
    return _appsRef.snapshots().map(_querySnapshotToApps);
  }

  Future<AppEntity> fetchApp(String appId) async {
    var snapshot = await _appsRef.where("id", isEqualTo: appId).getDocuments();
    List<AppEntity> apps = _querySnapshotToApps(snapshot);
    if (apps.isEmpty) {
      return null;
    } else {
      return apps.first;
    }
  }

  Future<AppEntity> save(AppEntity app) async {
    await ref(app.uid).setData(app.toJson(), merge: true);
    return app;
  }

  List<AppEntity> _querySnapshotToApps(QuerySnapshot snapshot) {
    if (snapshot.documents != null) {
      return snapshot.documents.map((s) => AppEntity.fromJson(s.data)).toList();
    } else {
      return [];
    }
  }
}
