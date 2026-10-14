import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentMethod {
  jazzCash,
  easyPaisa,
  card,
  cash,
}

enum PaymentStatus {
  pending,
  processing,
  paid,
  failed,
  cancelled,
}

class PaymentModel {
  final String paymentId;
  final String requestId;
  final String userId;
  final String mechanicId;
  final String mechanicName;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String transactionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentModel({
    required this.paymentId,
    required this.requestId,
    required this.userId,
    required this.mechanicId,
    required this.mechanicName,
    required this.amount,
    required this.method,
    required this.status,
    required this.transactionId,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return PaymentModel(
      paymentId:
          data['paymentId']?.toString() ?? doc.id,

      requestId:
          data['requestId']?.toString() ?? '',

      userId:
          data['userId']?.toString() ?? '',

      mechanicId:
          data['mechanicId']?.toString() ?? '',

      mechanicName:
          data['mechanicName']?.toString() ?? '',

      amount:
          (data['amount'] as num?)?.toDouble() ?? 0,

      method:
          _methodFromString(
        data['method']?.toString(),
      ),

      status:
          _statusFromString(
        data['status']?.toString(),
      ),

      transactionId:
          data['transactionId']?.toString() ?? '',

      createdAt:
          data['createdAt'] is Timestamp
              ? (data['createdAt'] as Timestamp)
                  .toDate()
              : null,

      updatedAt:
          data['updatedAt'] is Timestamp
              ? (data['updatedAt'] as Timestamp)
                  .toDate()
              : null,
    );
  }

  static PaymentMethod _methodFromString(
    String? value,
  ) {
    switch (value) {
      case 'jazzCash':
        return PaymentMethod.jazzCash;

      case 'easyPaisa':
        return PaymentMethod.easyPaisa;

      case 'card':
        return PaymentMethod.card;

      case 'cash':
        return PaymentMethod.cash;

      default:
        return PaymentMethod.cash;
    }
  }

  static PaymentStatus _statusFromString(
    String? value,
  ) {
    switch (value) {
      case 'processing':
        return PaymentStatus.processing;

      case 'paid':
        return PaymentStatus.paid;

      case 'failed':
        return PaymentStatus.failed;

      case 'cancelled':
        return PaymentStatus.cancelled;

      default:
        return PaymentStatus.pending;
    }
  }

  String get methodName {
    switch (method) {
      case PaymentMethod.jazzCash:
        return 'JazzCash';

      case PaymentMethod.easyPaisa:
        return 'Easypaisa';

      case PaymentMethod.card:
        return 'Card';

      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  String get statusName {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';

      case PaymentStatus.processing:
        return 'Processing';

      case PaymentStatus.paid:
        return 'Paid';

      case PaymentStatus.failed:
        return 'Failed';

      case PaymentStatus.cancelled:
        return 'Cancelled';
    }
  }
}