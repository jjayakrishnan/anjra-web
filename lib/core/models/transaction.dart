import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final String id;
  @JsonKey(name: 'sender_id')
  final String senderId;
  @JsonKey(name: 'receiver_id')
  final String receiverId;
  final double amount;
  final String? note;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  // Ideally, these would be expanded/joined, but for simple list, we might fetch basics or join manually
  // Or Supabase returns nested like `sender: profiles(...)`.
  // For now, simple model.

  Transaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
