// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestEntity _$RequestEntityFromJson(Map json) {
  return RequestEntity(
    uid: json['uid'] as String,
    appId: json['appId'] as String,
    phone: json['phone'] as String,
    message: json['message'] as String,
    creationTime: json['creationTime'] == null
        ? null
        : DateTime.parse(json['creationTime'] as String),
    success: json['success'] as bool,
  );
}

Map<String, dynamic> _$RequestEntityToJson(RequestEntity instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('uid', instance.uid);
  val['appId'] = instance.appId;
  val['phone'] = instance.phone;
  val['message'] = instance.message;
  writeNotNull('creationTime', instance.creationTime?.toIso8601String());
  writeNotNull('success', instance.success);
  return val;
}
