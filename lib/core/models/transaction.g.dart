// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String,
  senderId: json['sender_id'] as String,
  receiverId: json['receiver_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  senderName: json['senderName'] as String?,
  receiverName: json['receiverName'] as String?,
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'amount': instance.amount,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
      'senderName': instance.senderName,
      'receiverName': instance.receiverName,
    };
