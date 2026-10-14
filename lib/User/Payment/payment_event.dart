import 'package:equatable/equatable.dart';

import 'payment_model.dart';

abstract class PaymentEvent
    extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// LOAD PAYMENT
// ============================================================

class LoadPayment
    extends PaymentEvent {
  final String requestId;

  const LoadPayment({
    required this.requestId,
  });

  @override
  List<Object?> get props => [
        requestId,
      ];
}

// ============================================================
// SELECT PAYMENT METHOD
// ============================================================

class SelectPaymentMethod
    extends PaymentEvent {
  final PaymentMethod method;

  const SelectPaymentMethod({
    required this.method,
  });

  @override
  List<Object?> get props => [
        method,
      ];
}

// ============================================================
// CREATE PAYMENT
// ============================================================

class CreatePayment
    extends PaymentEvent {
  final String requestId;
  final String mechanicId;
  final String mechanicName;
  final double amount;
  final PaymentMethod method;

  const CreatePayment({
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.amount,
    required this.method,
  });

  @override
  List<Object?> get props => [
        requestId,
        mechanicId,
        mechanicName,
        amount,
        method,
      ];
}

// ============================================================
// CASH PAYMENT CONFIRMATION
// ============================================================

class ConfirmCashPayment
    extends PaymentEvent {
  final String requestId;
  final String mechanicId;
  final String mechanicName;
  final double amount;

  const ConfirmCashPayment({
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.amount,
  });

  @override
  List<Object?> get props => [
        requestId,
        mechanicId,
        mechanicName,
        amount,
      ];
}

// ============================================================
// INTERNAL PAYMENT UPDATED
// ============================================================

class PaymentUpdated
    extends PaymentEvent {
  final PaymentModel payment;

  const PaymentUpdated(
    this.payment,
  );

  @override
  List<Object?> get props => [
        payment,
      ];
}

// ============================================================
// INTERNAL PAYMENT FAILED
// ============================================================

class PaymentFailed
    extends PaymentEvent {
  final String message;

  const PaymentFailed(
    this.message,
  );

  @override
  List<Object?> get props => [
        message,
      ];
}

class PaymentNotFound
    extends PaymentEvent {
  const PaymentNotFound();
}