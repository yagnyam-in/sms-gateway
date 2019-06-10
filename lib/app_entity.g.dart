// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppEntity _$AppEntityFromJson(Map json) {
  return AppEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      accessToken: json['accessToken'] as String);
}

Map<String, dynamic> _$AppEntityToJson(AppEntity instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['name'] = instance.name;
  val['description'] = instance.description;
  writeNotNull('accessToken', instance.accessToken);
  return val;
}
