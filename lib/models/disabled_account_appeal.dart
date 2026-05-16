/// Request from a disabled user on the login screen (verified with password).
class DisabledAccountAppeal {
  final String id;
  final String userId;
  final String email;
  final String fullName;
  final String message;
  final int? createdAt;
  final bool resolved;

  const DisabledAccountAppeal({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.message,
    this.createdAt,
    this.resolved = false,
  });

  factory DisabledAccountAppeal.fromEntry(
    String id,
    Map<String, dynamic> data,
  ) {
    return DisabledAccountAppeal(
      id: id,
      userId: data['userId']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      fullName: data['fullName']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      createdAt: _parseMillis(data['createdAt']),
      resolved: _parseBool(data['resolved']),
    );
  }

  static int? _parseMillis(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'y' || s == 'yes';
  }
}
