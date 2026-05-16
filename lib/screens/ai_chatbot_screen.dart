import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:hqapp/services/ai_service.dart';
import '../localization/app_localizations.dart';


class AiChatbot extends StatefulWidget {
  const AiChatbot({super.key});

  @override
  State<AiChatbot> createState() => _AiChatbotState();
}

class _AiChatbotState extends State<AiChatbot> {
  List<Message> messages = [];
  TextEditingController controller = TextEditingController();
  String answer = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  void  nothing(){}

  void _talkToAi() async {
    String theAnswer = await getOpenRouterResponse(controller.text);
    setState(() {
      answer = theAnswer;
      final aiMessage = Message(
        text: answer,
        date: DateTime.now(),
        isSentByMe: false,
      );
      messages.add(aiMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(l.t('ai_chatbot'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: GroupedListView<Message,DateTime>(
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
                    color: Color(0xFF8F5E3D),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Text(
                        DateFormat.yMMMd().format(message.date),
                        style: const TextStyle(color: Colors.white,fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, Message message) => Align(
                alignment: message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                child:
                message.isSentByMe ?
                Card(
                  color: Color(0xFFFFF0E3),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(message.text,style: TextStyle(fontSize: 16),),
                  ),
                )
                :
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(message.text,style: TextStyle(fontSize: 16),),
                  ),
                ),
              ),
            )
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _sendMessage(),
              _sendButton()
            ]
          )
        ],
      ),

    );
  }

  // Widgets building

  Widget _sendMessage (){
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
          color: Color(0xFFFFF0E3),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Spread radius
            blurRadius: 10, // Blur radius
            offset: Offset(5, 5), // Changes position of shadow (x, y)
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
          children: [
            _messageTextField(),
          ],
        ),
      ),
    );
  }

  //Text Field
  Widget _messageTextField(){
    final l = AppLocalizations.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.70,
      child: TextField(
        cursorColor: Colors.black,
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
          hintText: l.t('Type in your message...'),
        ),
        onSubmitted: (text) {
          final message = Message(
            text: text,
            date: DateTime.now(),
            isSentByMe: true,
          );
          setState(() {
            messages.add(message);
            _talkToAi();
          });
          controller.clear();
        },
      ),
    );
  }

  //Send Button
  Widget _sendButton(){
    return Material(
      elevation: 8,
      shape: CircleBorder(),
      child: IconButton(
        onPressed: (){
          final message = Message(
            text: controller.text,
            date: DateTime.now(),
            isSentByMe: true,
          );
          setState(() {
            messages.add(message);
            _talkToAi();
          });
          controller.clear();
        },
        icon: Icon(Icons.send,color: Colors.white,),
        iconSize: 30,
        style: IconButton.styleFrom(
          backgroundColor: Color(0xFF8F5E3D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }
}

class Message{
  final String text;
  final DateTime date;
  final bool isSentByMe;

  const Message({
    required this.text,
    required this.date,
    required this.isSentByMe,
});
}
