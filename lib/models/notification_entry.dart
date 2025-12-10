class NotificationEntry {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // 'achievement', 'quiz', 'general'
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationEntry.fromMap(String id, Map<String, dynamic> data) {
    return NotificationEntry(
      id: id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      type: data['type'] as String? ?? 'general',
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt'] as DateTime
          : DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      isRead: (data['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  NotificationEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

