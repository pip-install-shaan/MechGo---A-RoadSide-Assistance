class CompletedPaymentRequest {
  final String requestId;
  final String mechanicId;
  final String mechanicName;
  final String mechanicPhone;
  final String mechanicProfilePic;
  final double amount;

  const CompletedPaymentRequest({
    required this.requestId,
    required this.mechanicId,
    required this.mechanicName,
    required this.mechanicPhone,
    required this.mechanicProfilePic,
    required this.amount,
  });
}