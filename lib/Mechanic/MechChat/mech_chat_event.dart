import 'package:equatable/equatable.dart';

abstract class MechChatEvent extends Equatable {
  const MechChatEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// WATCH CHAT
// ============================================================

class WatchMechanicChatMessages extends MechChatEvent {
  final String requestId;

  const WatchMechanicChatMessages({
    required this.requestId,
  });

  @override
  List<Object?> get props => [requestId];
}


// ============================================================
// SEND MESSAGE
// ============================================================

class SendMechanicChatMessage extends MechChatEvent {
  final String requestId;
  final String text;

  const SendMechanicChatMessage({
    required this.requestId,
    required this.text,
  });

  @override
  List<Object?> get props => [
        requestId,
        text,
      ];
}


// ============================================================
// INTERNAL STREAM UPDATE
// ============================================================

class MechanicChatMessagesUpdated extends MechChatEvent {
  final List<Map<String, dynamic>> messages;

  const MechanicChatMessagesUpdated({
    required this.messages,
  });

  @override
  List<Object?> get props => [messages];
}


// ============================================================
// INTERNAL STREAM ERROR
// ============================================================

class MechanicChatMessagesFailed extends MechChatEvent {
  final String errorMessage;

  const MechanicChatMessagesFailed({
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [errorMessage];
}