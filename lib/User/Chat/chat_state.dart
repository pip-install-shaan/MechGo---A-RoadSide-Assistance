import 'package:equatable/equatable.dart';

enum ChatStatus {
  initial,
  loading,
  loaded,
  sending,
  sent,
  failure,
}

class ChatState extends Equatable {
  final ChatStatus status;
  final List<Map<String, dynamic>> messages;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Map<String, dynamic>>? messages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
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