class LeaderboardEntry {
  final String userId;
  final String userName;
  final int totalPoints;
  final DateTime lastUpdated;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.totalPoints,
    required this.lastUpdated,
  });

  factory LeaderboardEntry.fromMap(String id, Map<String, dynamic> data) {
    return LeaderboardEntry(
      userId: id,
      userName: data['userName'] as String? ?? '',
      totalPoints: (data['totalPoints'] as num?)?.toInt() ?? 0,
      lastUpdated: data['lastUpdated'] is DateTime
          ? data['lastUpdated'] as DateTime
          : DateTime.tryParse(data['lastUpdated']?.toString() ?? '') ??
                DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userName': userName,
      'totalPoints': totalPoints,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

