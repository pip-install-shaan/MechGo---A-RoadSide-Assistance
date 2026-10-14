import 'package:equatable/equatable.dart';

enum MechChatStatus {
  initial,
  loading,
  loaded,
  sending,
  failure,
}

class MechChatState extends Equatable {
  final MechChatStatus status;
  final List<Map<String, dynamic>> messages;
  final String? errorMessage;

  const MechChatState({
    this.status = MechChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  MechChatState copyWith({
    MechChatStatus? status,
    List<Map<String, dynamic>>? messages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MechChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage:
          clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        messages,
        errorMessage,
      ];
}