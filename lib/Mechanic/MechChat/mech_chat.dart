import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat_bloc.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat_event.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat_repo.dart';
import 'package:mech_go/Mechanic/MechChat/mech_chat_state.dart';
import 'package:url_launcher/url_launcher.dart';


class MechanicChatScreen extends StatelessWidget {
  final String requestId;
  final String userId;
  final String userName;
  final String userPhone;
  final String userProfilePic;

  const MechanicChatScreen({
    super.key,
    required this.requestId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    this.userProfilePic = '',
  });

  bool get hasUser {
    return requestId.trim().isNotEmpty &&
        userId.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (!hasUser) {
      return const _NoUserConnectedScreen();
    }

    return BlocProvider(
      create: (_) => MechChatBloc(
        chatRepository: MechanicChatRepository(),
      )..add(
          WatchMechanicChatMessages(
            requestId: requestId,
          ),
        ),
      child: _MechanicChatView(
        requestId: requestId,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        userProfilePic: userProfilePic,
      ),
    );
  }
}


// ============================================================
// NO USER CONNECTED
// ============================================================

class _NoUserConnectedScreen extends StatelessWidget {
  const _NoUserConnectedScreen();

  @override
  Widget build(BuildContext context) {
    const primaryRed =
        Color.fromARGB(255, 198, 24, 11);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 45,
                  color: primaryRed,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'No User Connected',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'There is no active user connection for this request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Accept a service request to communicate with the user.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ============================================================
// CHAT VIEW
// ============================================================

class _MechanicChatView extends StatefulWidget {
  final String requestId;
  final String userId;
  final String userName;
  final String userPhone;
  final String userProfilePic;

  const _MechanicChatView({
    required this.requestId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userProfilePic,
  });

  @override
  State<_MechanicChatView> createState() =>
      _MechanicChatViewState();
}


class _MechanicChatViewState
    extends State<_MechanicChatView> {

  final Color primaryRed =
      const Color.fromARGB(255, 198, 24, 11);

  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();


  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }


  // ============================================================
  // CALL USER
  // ============================================================

  Future<void> _callUser() async {
    final phone = widget.userPhone.trim();

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User phone number is not available.',
          ),
        ),
      );

      return;
    }

    final Uri uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open phone dialer.',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to make phone call.',
          ),
        ),
      );
    }
  }


  // ============================================================
  // SEND MESSAGE
  // ============================================================

  void _sendMessage() {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      return;
    }

    context.read<MechChatBloc>().add(
          SendMechanicChatMessage(
            requestId: widget.requestId,
            text: text,
          ),
        );

    messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 100),
      _scrollToBottom,
    );
  }


  // ============================================================
  // SCROLL
  // ============================================================

  void _scrollToBottom() {
    if (!scrollController.hasClients) {
      return;
    }

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(
        milliseconds: 250,
      ),
      curve: Curves.easeOut,
    );
  }


  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        backgroundColor: primaryRed,

        title: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: Colors.white,

              backgroundImage:
                  widget.userProfilePic
                          .trim()
                          .isNotEmpty
                      ? NetworkImage(
                          widget.userProfilePic,
                        )
                      : null,

              child:
                  widget.userProfilePic
                          .trim()
                          .isEmpty
                      ? const Icon(
                          Icons.person,
                          color: Colors.black,
                        )
                      : null,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                widget.userName.isNotEmpty
                    ? widget.userName
                    : 'User',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: _callUser,
            icon: const Icon(
              Icons.call,
              color: Colors.white,
              size: 25,
            ),
          ),
        ],
      ),

      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          color: Color.fromARGB(
            255,
            234,
            209,
            209,
          ),
        ),

        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<
                  MechChatBloc,
                  MechChatState>(
                listener: (context, state) {
                  if (state.status ==
                      MechChatStatus.failure) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          state.errorMessage ??
                              'Unable to send message.',
                        ),
                      ),
                    );
                  }
                },

                builder: (context, state) {
                  if (state.status ==
                          MechChatStatus.loading &&
                      state.messages.isEmpty) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'Start a conversation with the user.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  WidgetsBinding.instance
                      .addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(
                      top: 15,
                      bottom: 10,
                    ),
                    itemCount:
                        state.messages.length,

                    itemBuilder:
                        (context, index) {
                      final message =
                          state.messages[index];

                      return _MessageBubble(
                        message: message,
                      );
                    },
                  );
                },
              ),
            ),

            // ==================================================
            // MESSAGE INPUT
            // ==================================================

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  top: 5,
                ),

                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,

                  children: [
                    Expanded(
                      child: TextFormField(
                        controller:
                            messageController,

                        keyboardType:
                            TextInputType.multiline,

                        minLines: 1,
                        maxLines: 4,

                        textCapitalization:
                            TextCapitalization
                                .sentences,

                        onFieldSubmitted: (_) {
                          _sendMessage();
                        },

                        decoration:
                            InputDecoration(
                          filled: true,
                          fillColor: Colors.white,

                          hintText: 'Message',

                          hintStyle:
                              const TextStyle(
                            color: Colors.black,
                          ),

                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(15),
                            borderSide:
                                BorderSide.none,
                          ),

                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(15),
                            borderSide:
                                const BorderSide(
                              color: Colors.black,
                            ),
                          ),

                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 10,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    CircleAvatar(
                      radius: 25,
                      backgroundColor:
                          Colors.white,

                      child: IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(
                          Icons.send,
                          size: 27,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// MESSAGE BUBBLE
// ============================================================

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser =
        MechanicChatRepository().currentUser;

    final String senderId =
        message['senderId']?.toString() ?? '';

    final bool isMine =
        currentUser?.uid == senderId;

    final String text =
        message['text']?.toString() ?? '';

    return Align(
      alignment: isMine
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
                  0.75,
        ),

        margin: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 5,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: isMine
              ? Colors.black
              : Colors.white,

          borderRadius:
              BorderRadius.only(
            topRight:
                const Radius.circular(12),
            topLeft:
                const Radius.circular(12),

            bottomLeft: isMine
                ? const Radius.circular(12)
                : Radius.zero,

            bottomRight: isMine
                ? Radius.zero
                : const Radius.circular(12),
          ),
        ),

        child: Text(
          text,
          style: TextStyle(
            color: isMine
                ? Colors.white
                : Colors.black,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}