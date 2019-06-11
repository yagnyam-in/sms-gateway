import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity {
  @JsonKey(nullable: false)
  final String uid;
  @JsonKey(nullable: true)
  final String fcmToken;

  UserEntity({
    @required this.uid,
    @required this.fcmToken,
  }) {
    assert(uid != null && uid.isNotEmpty);
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  static UserEntity fromJson(Map json) => _$UserEntityFromJson(json);

  UserEntity copy({
    String fcmToken,
  }) =>
      UserEntity(
        uid: uid,
        fcmToken: fcmToken ?? this.fcmToken,
      );
}
