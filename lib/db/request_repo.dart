import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sms_gateway/db/firestore_utils.dart';
import 'package:sms_gateway/model/request_entity.dart';

class RequestRepo with FirestoreUtils {
  CollectionReference get _pendingRef => root.collection('pending-requests');

  CollectionReference get _completedRef =>
      root.collection('completed-requests');

  DocumentReference pendingRef(String requestId) {
    return _pendingRef.document(requestId);
  }

  DocumentReference completedRef(String requestId) {
    return _completedRef.document(requestId);
  }

  final FirebaseUser firebaseUser;
  final DocumentReference root;

  RequestRepo(this.firebaseUser) : root = FirestoreUtils.rootRef(firebaseUser) {
    assert(firebaseUser != null);
  }

  Stream<List<RequestEntity>> subscribeForPendingRequests() {
    return _pendingRef.snapshots().map(_querySnapshotToRequests);
  }

  Future<List<RequestEntity>> fetchPendingRequests() async {
    QuerySnapshot snapshot = await _pendingRef.getDocuments();
    return _querySnapshotToRequests(snapshot);
  }

  Future<void> markProcessed(RequestEntity request) async {
    await pendingRef(request.uid).delete();
    await completedRef(request.uid).setData(request.toJson());
  }

  List<RequestEntity> _querySnapshotToRequests(QuerySnapshot snapshot) {
    if (snapshot.documents != null) {
      return snapshot.documents
          .map((s) => RequestEntity.fromJson(s.data))
          .toList();
    } else {
      return [];
    }
  }
}
