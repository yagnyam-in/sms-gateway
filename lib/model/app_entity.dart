import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'app_entity.g.dart';

@JsonSerializable()
class AppEntity {
  static final RegExp ID_REGEX =
      RegExp(r"^[a-zA-Z0-9][a-zA-Z0-9-]{0,34}[a-zA-Z0-9]$");

  @JsonKey(nullable: false)
  final String uid;
  @JsonKey(nullable: false)
  final String id;
  @JsonKey(nullable: false)
  final String name;
  @JsonKey(nullable: false)
  final String description;
  @JsonKey(nullable: true)
  final String accessToken;
  @JsonKey(nullable: true)
  final int smsCount;

  AppEntity({
    @required this.uid,
    @required this.id,
    @required this.name,
    @required this.description,
    @required this.accessToken,
    int smsCount = 0,
  }) : smsCount = smsCount {
    assert(uid != null && uid.isNotEmpty);
    assert(ID_REGEX.hasMatch(id));
    assert(id != null);
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() => _$AppEntityToJson(this);

  static AppEntity fromJson(Map json) => _$AppEntityFromJson(json);

  AppEntity copy(
          {String id,
          String name,
          String description,
          String accessToken,
          int smsCount}) =>
      AppEntity(
          uid: uid,
          id: id ?? this.id,
          name: name ?? this.name,
          description: description ?? this.description,
          accessToken: accessToken ?? this.accessToken,
          smsCount: smsCount ?? this.smsCount);
}
