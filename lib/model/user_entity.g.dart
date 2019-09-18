// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map json) {
  return UserEntity(
    uid: json['uid'] as String,
    fcmToken: json['fcmToken'] as String,
  );
}

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) {
  final val = <String, dynamic>{
    'uid': instance.uid,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('fcmToken', instance.fcmToken);
  return val;
}
