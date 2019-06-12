import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sms_gateway/db/firestore_utils.dart';
import 'package:sms_gateway/model/app_state.dart';
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

  final AppState appState;
  final DocumentReference root;

  RequestRepo(this.appState)
      : root = FirestoreUtils.rootRef(appState);

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
      return snapshot.documents.map(_documentSnapshotToRequest).toList();
    } else {
      return [];
    }
  }

  RequestEntity _documentSnapshotToRequest(DocumentSnapshot snapshot) {
    if (!snapshot.exists) {
      return null;
    } else {
      Map map = {
        ...snapshot.data,
        'uid': snapshot.documentID,
      };
      return RequestEntity.fromJson(map);
    }
  }
}
