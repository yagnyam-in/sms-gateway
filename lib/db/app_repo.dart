import 'dart:async';
import 'dart:async' as prefix0;

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
    var document = await ref(appId).get();
    if (document.exists) {
      return AppEntity.fromJson(document.data);
    } else {
      return null;
    }
  }

  Future<bool> isAppIdTaken(String appId) async {
    var doc = await Firestore.instance.collection('apps').document(appId).get();
    return doc.exists;
  }

  Future<String> appIdOwnerId(String appId) async {
    var doc = await Firestore.instance.collection('apps').document(appId).get();
    if (!doc.exists) {
      return null;
    } else {
      return doc.data["userId"];
    }
  }


  Future<AppEntity> save(AppEntity app) async {
    String existingAppIdOwner = await appIdOwnerId(app.id);
    if (existingAppIdOwner == null) {
      await Firestore.instance.collection('apps').document(app.id).setData({
        'userId': app.userId,
      });
    } else if (existingAppIdOwner != app.userId) {
      throw "App id ${app.id} is already taken";
    }

    await ref(app.id).setData(app.toJson(), merge: true);
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
