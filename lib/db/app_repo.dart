import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_gateway/db/firestore_utils.dart';
import 'package:sms_gateway/generic_helper.dart';
import 'package:sms_gateway/model/app_entity.dart';
import 'package:sms_gateway/model/app_state.dart';

class AppRepo with FirestoreUtils, GenericHelper {
  CollectionReference get _appsRef => root.collection('apps');

  DocumentReference ref(String appId) {
    return _appsRef.document(appId);
  }

  final AppState appState;
  final DocumentReference root;

  AppRepo(this.appState) : root = FirestoreUtils.rootRef(appState);

  Stream<List<AppEntity>> subscribeForApps() {
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

  Future<void> deleteAllApps() async {
    QuerySnapshot qs = await _appsRef.getDocuments();
    qs.documents.forEach((d) async {
      await delete(d.documentID);
    });
  }

  Future<void> delete(String appId) async {
    print("Removing /apps/$appId");
    await ignoreErrors(
        () => Firestore.instance.collection('apps').document(appId).delete());
    print("Removing /${ref(appId).path}");
    await ignoreErrors(() => ref(appId).delete());
  }
}
