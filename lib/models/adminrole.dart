/// Per-page access for staff admins. Super admins always have full access.
enum AdminFeedbackAccess {
  hidden,
  view,
  delete;

  static AdminFeedbackAccess fromDb(Object? raw) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    switch (s) {
      case 'view':
      case 'read':
        return AdminFeedbackAccess.view;
      case 'delete':
      case 'manage':
        return AdminFeedbackAccess.delete;
      default:
        return AdminFeedbackAccess.hidden;
    }
  }

  String toDb() {
    switch (this) {
      case AdminFeedbackAccess.hidden:
        return 'hidden';
      case AdminFeedbackAccess.view:
        return 'view';
      case AdminFeedbackAccess.delete:
        return 'delete';
    }
  }
}

enum AdminUserSupportAccess {
  hidden,
  view,
  manage;

  static AdminUserSupportAccess fromDb(Object? raw) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    switch (s) {
      case 'view':
        return AdminUserSupportAccess.view;
      case 'manage':
        return AdminUserSupportAccess.manage;
      default:
        return AdminUserSupportAccess.hidden;
    }
  }

  String toDb() {
    switch (this) {
      case AdminUserSupportAccess.hidden:
        return 'hidden';
      case AdminUserSupportAccess.view:
        return 'view';
      case AdminUserSupportAccess.manage:
        return 'manage';
    }
  }
}

/// Manage quiz questions: hidden, view list only, or add/edit/delete.
enum AdminQuizAccess {
  hidden,
  view,
  manage;

  static AdminQuizAccess fromDb(Object? raw) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    switch (s) {
      case 'view':
      case 'read':
        return AdminQuizAccess.view;
      case 'manage':
      case 'delete':
        return AdminQuizAccess.manage;
      default:
        return AdminQuizAccess.hidden;
    }
  }

  String toDb() {
    switch (this) {
      case AdminQuizAccess.hidden:
        return 'hidden';
      case AdminQuizAccess.view:
        return 'view';
      case AdminQuizAccess.manage:
        return 'manage';
    }
  }
}

enum AdminManageUsersAccess {
  hidden,
  view;

  static AdminManageUsersAccess fromDb(Object? raw) {
    final s = raw?.toString().trim().toLowerCase() ?? '';
    if (s == 'view') return AdminManageUsersAccess.view;
    return AdminManageUsersAccess.hidden;
  }

  String toDb() {
    switch (this) {
      case AdminManageUsersAccess.hidden:
        return 'hidden';
      case AdminManageUsersAccess.view:
        return 'view';
    }
  }
}

class AdminPermissions {
  final AdminFeedbackAccess feedback;
  final bool leaderboard;
  final AdminUserSupportAccess userSupport;
  final bool analytics;
  final AdminManageUsersAccess manageUsers;
  final AdminQuizAccess manageQuiz;

  const AdminPermissions({
    this.feedback = AdminFeedbackAccess.hidden,
    this.leaderboard = false,
    this.userSupport = AdminUserSupportAccess.hidden,
    this.analytics = false,
    this.manageUsers = AdminManageUsersAccess.hidden,
    this.manageQuiz = AdminQuizAccess.hidden,
  });

  static const AdminPermissions all = AdminPermissions(
    feedback: AdminFeedbackAccess.delete,
    leaderboard: true,
    userSupport: AdminUserSupportAccess.manage,
    analytics: true,
    manageUsers: AdminManageUsersAccess.view,
    manageQuiz: AdminQuizAccess.manage,
  );

  static const AdminPermissions none = AdminPermissions();

  /// Granted when a user is first made admin (super admin can tighten later).
  static const AdminPermissions defaultForNewAdmin = AdminPermissions(
    feedback: AdminFeedbackAccess.view,
    leaderboard: true,
    userSupport: AdminUserSupportAccess.view,
    analytics: true,
    manageUsers: AdminManageUsersAccess.view,
  );

  bool get canSeeFeedback => feedback != AdminFeedbackAccess.hidden;
  bool get canDeleteFeedback => feedback == AdminFeedbackAccess.delete;
  bool get canSeeUserSupport => userSupport != AdminUserSupportAccess.hidden;
  bool get canEnableFromUserSupport =>
      userSupport == AdminUserSupportAccess.manage;
  bool get canSeeManageUsers => manageUsers != AdminManageUsersAccess.hidden;
  bool get canSeeManageQuiz => manageQuiz != AdminQuizAccess.hidden;
  bool get canManageQuiz => manageQuiz == AdminQuizAccess.manage;

  bool get hasAnyAdminPageAccess =>
      canSeeFeedback ||
      leaderboard ||
      canSeeUserSupport ||
      analytics ||
      canSeeManageUsers ||
      canSeeManageQuiz;

  factory AdminPermissions.fromMap(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return AdminPermissions.none;
    return AdminPermissions(
      feedback: AdminFeedbackAccess.fromDb(data['feedback']),
      leaderboard: _parseBool(data['leaderboard']),
      userSupport: AdminUserSupportAccess.fromDb(data['userSupport']),
      analytics: _parseBool(data['analytics']),
      manageUsers: AdminManageUsersAccess.fromDb(data['manageUsers']),
      manageQuiz: AdminQuizAccess.fromDb(data['manageQuiz']),
    );
  }

  Map<String, dynamic> toMap() => {
    'feedback': feedback.toDb(),
    'leaderboard': leaderboard,
    'userSupport': userSupport.toDb(),
    'analytics': analytics,
    'manageUsers': manageUsers.toDb(),
    'manageQuiz': manageQuiz.toDb(),
  };

  AdminPermissions copyWith({
    AdminFeedbackAccess? feedback,
    bool? leaderboard,
    AdminUserSupportAccess? userSupport,
    bool? analytics,
    AdminManageUsersAccess? manageUsers,
    AdminQuizAccess? manageQuiz,
  }) {
    return AdminPermissions(
      feedback: feedback ?? this.feedback,
      leaderboard: leaderboard ?? this.leaderboard,
      userSupport: userSupport ?? this.userSupport,
      analytics: analytics ?? this.analytics,
      manageUsers: manageUsers ?? this.manageUsers,
      manageQuiz: manageQuiz ?? this.manageQuiz,
    );
  }

  static bool _parseBool(Object? raw) {
    if (raw == null) return false;
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    final s = raw.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'y' || s == 'yes';
  }
}
