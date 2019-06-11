// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppEntity _$AppEntityFromJson(Map json) {
  return AppEntity(
      userId: json['userId'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      accessToken: json['accessToken'] as String,
      smsCount: json['smsCount'] as int);
}

Map<String, dynamic> _$AppEntityToJson(AppEntity instance) {
  final val = <String, dynamic>{
    'userId': instance.userId,
    'id': instance.id,
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('description', instance.description);
  writeNotNull('accessToken', instance.accessToken);
  writeNotNull('smsCount', instance.smsCount);
  return val;
}
