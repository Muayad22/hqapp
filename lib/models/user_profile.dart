/// Staff tier stored in Realtime DB field `admin`: N, Y (admin), S (super admin).
enum AdminRole {
  none,
  admin,
  superAdmin;

  static AdminRole fromDb(Object? raw) {
    final s = (raw as String?)?.toUpperCase().trim() ?? 'N';
    if (s == 'S') return AdminRole.superAdmin;
    if (s == 'Y') return AdminRole.admin;
    return AdminRole.none;
  }

  String toDb() {
    switch (this) {
      case AdminRole.superAdmin:
        return 'S';
      case AdminRole.admin:
        return 'Y';
      case AdminRole.none:
        return 'N';
    }
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String contactNo;
  final String visitorType;
  final AdminRole adminRole;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.contactNo,
    this.visitorType = 'Local',
    this.adminRole = AdminRole.none,
  });

  /// True for normal admin or super admin (admin portal access).
  bool get hasStaffAccess =>
      adminRole == AdminRole.admin || adminRole == AdminRole.superAdmin;

  bool get isSuperAdmin => adminRole == AdminRole.superAdmin;

  /// Key for [AppLocalizations.t] describing this user's staff role.
  String get staffRoleL10nKey {
    switch (adminRole) {
      case AdminRole.none:
        return 'admin_role_user';
      case AdminRole.admin:
        return 'admin_role_admin';
      case AdminRole.superAdmin:
        return 'admin_role_super_admin';
    }
  }

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      contactNo: data['contactNo'] as String? ?? '',
      visitorType: data['visitorType'] as String? ?? 'Local',
      adminRole: AdminRole.fromDb(data['admin']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'contactNo': contactNo,
      'visitorType': visitorType,
      'admin': adminRole.toDb(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? contactNo,
    String? visitorType,
    AdminRole? adminRole,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      contactNo: contactNo ?? this.contactNo,
      visitorType: visitorType ?? this.visitorType,
      adminRole: adminRole ?? this.adminRole,
    );
  }

  static UserProfile guest() {
    return const UserProfile(
      id: 'guest',
      fullName: 'Guest Explorer',
      email: 'guest@heritage.quest',
      contactNo: '',
      visitorType: 'Local',
      adminRole: AdminRole.none,
    );
  }
}
