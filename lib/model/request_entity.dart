import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'request_entity.g.dart';

@JsonSerializable()
class RequestEntity {
  @JsonKey(nullable: true)
  final String uid;
  @JsonKey(nullable: false)
  final String appId;
  @JsonKey(nullable: false)
  final String phone;
  @JsonKey(nullable: false)
  final String message;
  @JsonKey(nullable: true)
  final bool success;

  RequestEntity({
    @required this.uid,
    @required this.appId,
    @required this.phone,
    @required this.message,
    this.success = true,
  }) {
    assert(uid != null);
    assert(appId != null);
    assert(phone != null);
    assert(message != null);
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Map<String, dynamic> toJson() => _$RequestEntityToJson(this);

  static RequestEntity fromJson(Map json) => _$RequestEntityFromJson(json);
}
