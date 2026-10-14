enum MechanicEarningsStatus {
  initial,
  loading,
  loaded,
  failure,
}

class MechanicEarningsState {
  final MechanicEarningsStatus status;
  final List<Map<String, dynamic>> earnings;
  final String? errorMessage;

  const MechanicEarningsState({
    this.status = MechanicEarningsStatus.initial,
    this.earnings = const [],
    this.errorMessage,
  });

  MechanicEarningsState copyWith({
    MechanicEarningsStatus? status,
    List<Map<String, dynamic>>? earnings,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MechanicEarningsState(
      status: status ?? this.status,
      earnings: earnings ?? this.earnings,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}