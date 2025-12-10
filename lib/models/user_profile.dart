class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String contactNo;
  final String visitorType;
  final bool isAdmin;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contactNo,
    this.visitorType = 'Local',
    required this.isAdmin,
  });

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      contactNo: data['contactNo'] as String? ?? '',
      visitorType: data['visitorType'] as String? ?? 'Local',
      isAdmin: (data['admin'] as String? ?? 'N').toUpperCase() == 'Y',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'contactNo': contactNo,
      'visitorType': visitorType,
      'admin': isAdmin ? 'Y' : 'N',
    };
  }

  UserProfile copyWith({String? fullName, String? contactNo, String? visitorType}) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      contactNo: contactNo ?? this.contactNo,
      visitorType: visitorType ?? this.visitorType,
      isAdmin: isAdmin,
    );
  }

  static UserProfile guest() {
    return const UserProfile(
      id: 'guest',
      fullName: 'Guest Explorer',
      email: 'guest@heritage.quest',
      contactNo: '',
      visitorType: 'Local',
      isAdmin: false,
    );
  }
}
