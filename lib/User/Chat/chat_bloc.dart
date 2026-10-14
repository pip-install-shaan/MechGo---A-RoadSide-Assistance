import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_event.dart';
import 'chat_repo.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;

  StreamSubscription<List<Map<String, dynamic>>>?
      _messagesSubscription;

  ChatBloc({
    required ChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const ChatState()) {
    on<WatchChatMessages>(_onWatchChatMessages);

    on<SendChatMessage>(_onSendChatMessage);

    on<ChatMessagesUpdated>(_onChatMessagesUpdated);

    on<ChatMessagesFailed>(_onChatMessagesFailed);
  }

  Future<void> _onWatchChatMessages(
    WatchChatMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ChatStatus.loading,
        clearError: true,
      ),
    );

    await _messagesSubscription?.cancel();

    _messagesSubscription = _chatRepository
        .watchMessages(event.requestId)
        .listen(
      (messages) {
        add(
          ChatMessagesUpdated(
            messages: messages,
          ),
        );
      },
      onError: (error) {
        add(
          ChatMessagesFailed(
            message: error.toString(),
          ),
        );
      },
    );
  }

  void _onChatMessagesUpdated(
    ChatMessagesUpdated event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        status: ChatStatus.loaded,
        messages: event.messages,
        clearError: true,
      ),
    );
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<ChatState> emit,
  ) async {
    final cleanText = event.text.trim();

    if (cleanText.isEmpty) {
      return;
    }

    try {
      emit(
        state.copyWith(
          status: ChatStatus.sending,
          clearError: true,
        ),
      );

      await _chatRepository.sendMessage(
        requestId: event.requestId,
        text: cleanText,
      );

      emit(
        state.copyWith(
          status: ChatStatus.sent,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onChatMessagesFailed(
    ChatMessagesFailed event,
    Emitter<ChatState> emit,
  ) {
    emit(
      state.copyWith(
        status: ChatStatus.failure,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}