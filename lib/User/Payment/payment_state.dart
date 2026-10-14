import 'package:equatable/equatable.dart';

import 'payment_model.dart';

enum PaymentStateStatus {
  initial,
  loading,
  ready,
  processing,
  success,
  failure,
}

class PaymentState
    extends Equatable {
  final PaymentStateStatus status;
  final PaymentModel? payment;
  final PaymentMethod? selectedMethod;
  final String? checkoutUrl;
  final String? errorMessage;

  const PaymentState({
    this.status =
        PaymentStateStatus.initial,
    this.payment,
    this.selectedMethod,
    this.checkoutUrl,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentStateStatus? status,
    PaymentModel? payment,
    PaymentMethod? selectedMethod,
    String? checkoutUrl,
    String? errorMessage,
    bool clearError = false,
    bool clearCheckoutUrl = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      payment: payment ?? this.payment,
      selectedMethod:
          selectedMethod ?? this.selectedMethod,
      checkoutUrl: clearCheckoutUrl
          ? null
          : checkoutUrl ?? this.checkoutUrl,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        payment,
        selectedMethod,
        checkoutUrl,
        errorMessage,
      ];
}