import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final String id;
  @JsonKey(name: 'full_name')
  final String? fullName;
  final String? email;
  @JsonKey(name: 'is_parent')
  final bool isParent;
  final double balance;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final String? pin; // Added PIN for kid transactions

  bool get isKid => !isParent;

  UserProfile({
    required this.id,
    this.fullName,
    this.email,
    this.isParent = false,
    this.balance = 0.0,
    this.createdAt,
    this.updatedAt,
    this.pin, // Optional
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
