import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat_event.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat_repo.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat_state.dart';


class MechChatBloc
    extends Bloc<MechChatEvent, MechChatState> {
  final MechanicChatRepository _chatRepository;

  StreamSubscription<List<Map<String, dynamic>>>?
      _messagesSubscription;

  MechChatBloc({
    required MechanicChatRepository chatRepository,
  })  : _chatRepository = chatRepository,
        super(const MechChatState()) {
    on<WatchMechanicChatMessages>(
      _onWatchMessages,
    );

    on<SendMechanicChatMessage>(
      _onSendMessage,
    );

    on<MechanicChatMessagesUpdated>(
      _onMessagesUpdated,
    );

    on<MechanicChatMessagesFailed>(
      _onMessagesFailed,
    );
  }



  // ============================================================
  // WATCH MESSAGES
  // ============================================================

  Future<void> _onWatchMessages(
    WatchMechanicChatMessages event,
    Emitter<MechChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();

    final requestId = event.requestId.trim();

    if (requestId.isEmpty) {
      emit(
        state.copyWith(
          status: MechChatStatus.failure,
          errorMessage: 'Request ID is missing.',
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status: MechChatStatus.loading,
        clearError: true,
      ),
    );

    _messagesSubscription =
        _chatRepository
            .watchMessages(
              requestId: requestId,
            )
            .listen(
      (messages) {
        add(
          MechanicChatMessagesUpdated(
            messages: messages,
          ),
        );
      },
      onError: (error) {
        add(
          MechanicChatMessagesFailed(
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }


  // ============================================================
  // MESSAGE STREAM UPDATED
  // ============================================================

  void _onMessagesUpdated(
    MechanicChatMessagesUpdated event,
    Emitter<MechChatState> emit,
  ) {
    emit(
      state.copyWith(
        status: MechChatStatus.loaded,
        messages: event.messages,
        clearError: true,
      ),
    );
  }


  // ============================================================
  // MESSAGE STREAM FAILED
  // ============================================================

  void _onMessagesFailed(
    MechanicChatMessagesFailed event,
    Emitter<MechChatState> emit,
  ) {
    emit(
      state.copyWith(
        status: MechChatStatus.failure,
        errorMessage: event.errorMessage,
      ),
    );
  }


  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _onSendMessage(
    SendMechanicChatMessage event,
    Emitter<MechChatState> emit,
  ) async {
    final text = event.text.trim();

    if (text.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        status: MechChatStatus.sending,
        clearError: true,
      ),
    );

    try {
      await _chatRepository.sendMessage(
        requestId: event.requestId,
        text: text,
      );

      emit(
        state.copyWith(
          status: MechChatStatus.loaded,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MechChatStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }


  // ============================================================
  // CLOSE
  // ============================================================

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();

    return super.close();
  }
}