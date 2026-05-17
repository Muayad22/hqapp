class AiChatMessage {
  final String id;
  final String text;
  final DateTime date;
  final bool isSentByMe;

  const AiChatMessage({
    required this.id,
    required this.text,
    required this.date,
    required this.isSentByMe,
  });

  factory AiChatMessage.fromMap(String id, Map<String, dynamic> data) {
    return AiChatMessage(
      id: id,
      text: data['text'] as String? ?? '',
      date: data['date'] is DateTime
          ? data['date'] as DateTime
          : DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now(),
      isSentByMe: data['isSentByMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'date': date.toIso8601String(),
        'isSentByMe': isSentByMe,
      };
}
