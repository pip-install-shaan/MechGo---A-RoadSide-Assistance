import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderRole;
  final String text;
  final DateTime? createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    this.createdAt,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    final timestamp = data['createdAt'];

    return ChatMessageModel(
      id: doc.id,
      senderId:
          data['senderId']?.toString() ?? '',
      senderRole:
          data['senderRole']?.toString() ?? '',
      text:
          data['text']?.toString() ?? '',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderRole': senderRole,
      'text': text,
      'createdAt': createdAt == null
          ? null
          : Timestamp.fromDate(createdAt!),
    };
  }
}