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
      message: json['message'] as String);
}

Map<String, dynamic> _$RequestEntityToJson(RequestEntity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'appId': instance.appId,
      'phone': instance.phone,
      'message': instance.message
    };
