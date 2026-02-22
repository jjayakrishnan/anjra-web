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

  // Joined from profiles table
  final String? senderName;
  final String? receiverName;

  Transaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.amount,
    this.note,
    required this.createdAt,
    this.senderName,
    this.receiverName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: json['sender']?['full_name'] as String?,
      receiverName: json['receiver']?['full_name'] as String?,
    );
  }
}
