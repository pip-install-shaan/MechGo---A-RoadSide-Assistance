import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to Firebase messages
class WatchChatMessages extends ChatEvent {
  final String requestId;

  const WatchChatMessages({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}

/// Send a text message
class SendChatMessage extends ChatEvent {
  final String requestId;
  final String text;

  const SendChatMessage({
    required this.requestId,
    required this.text,
  });

  @override
  List<Object?> get props => [
        requestId,
        text,
      ];
}

/// Internal event used when Firebase sends new messages
class ChatMessagesUpdated extends ChatEvent {
  final List<Map<String, dynamic>> messages;

  const ChatMessagesUpdated({
    required this.messages,
  });

  @override
  List<Object?> get props => [messages];
}

/// Internal Firebase error
class ChatMessagesFailed extends ChatEvent {
  final String message;

  const ChatMessagesFailed({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}