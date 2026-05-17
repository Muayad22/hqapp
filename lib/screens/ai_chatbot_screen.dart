import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/ai_service.dart';
import 'package:hqapp/services/firestore_service.dart';
import '../localization/app_localizations.dart';

class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key, required this.user});

  final UserProfile user;

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  List<Message> messages = [];
  TextEditingController controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedMessages();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedMessages() async {
    final saved = await FirestoreService.loadAiChatMessages(widget.user.id);
    if (!mounted) return;
    setState(() {
      messages = saved
          .map(
            (m) => Message(
              text: m.text,
              date: m.date,
              isSentByMe: m.isSentByMe,
            ),
          )
          .toList();
      _loading = false;
    });
  }

  Future<void> _persistMessage(Message message) async {
    try {
      await FirestoreService.saveAiChatMessage(
        userId: widget.user.id,
        text: message.text,
        date: message.date,
        isSentByMe: message.isSentByMe,
      );
    } catch (_) {}
  }

  Future<void> _sendUserMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMessage = Message(
      text: trimmed,
      date: DateTime.now(),
      isSentByMe: true,
    );
    setState(() => messages.add(userMessage));
    controller.clear();
    await _persistMessage(userMessage);

    try {
      final reply = await getOpenRouterResponse(trimmed);
      if (!mounted) return;
      final aiMessage = Message(
        text: reply,
        date: DateTime.now(),
        isSentByMe: false,
      );
      setState(() => messages.add(aiMessage));
      await _persistMessage(aiMessage);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get response. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('ai_chatbot'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text(
                            l.t('start_conversation'),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 18,
                            ),
                          ),
                        )
                      : GroupedListView<Message, DateTime>(
                          padding: const EdgeInsets.all(8),
                          reverse: true,
                          order: GroupedListOrder.DESC,
                          elements: messages,
                          groupBy: (message) => DateTime(
                            message.date.year,
                            message.date.month,
                            message.date.day,
                          ),
                          groupHeaderBuilder: (Message message) => SizedBox(
                            height: 40,
                            child: Center(
                              child: Card(
                                color: const Color(0xFF8F5E3D),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    DateFormat.yMMMd().format(message.date),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          itemBuilder: (context, Message message) => Align(
                            alignment: message.isSentByMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: message.isSentByMe
                                ? Card(
                                    color: const Color(0xFFFFF0E3),
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        message.text,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  )
                                : Card(
                                    elevation: 5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        message.text,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [_sendMessage(), _sendButton()],
                ),
              ],
            ),
    );
  }

  Widget _sendMessage() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E3),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(5, 5),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: MediaQuery.of(context).size.height * 0.03,
      ),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_messageTextField()],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      child: TextField(
        cursorColor: Colors.black,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
          hintText: l.t('type_message'),
        ),
        onSubmitted: _sendUserMessage,
      ),
    );
  }

  Widget _sendButton() {
    return Material(
      elevation: 8,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: () => _sendUserMessage(controller.text),
        icon: const Icon(Icons.send, color: Colors.white),
        iconSize: 30,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFF8F5E3D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}

class Message {
  final String text;
  final DateTime date;
  final bool isSentByMe;

  const Message({
    required this.text,
    required this.date,
    required this.isSentByMe,
  });
}
