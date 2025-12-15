import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:hqapp/models/feedback_entry.dart';
import 'package:hqapp/models/leaderboard_entry.dart';
import 'package:hqapp/models/notification_entry.dart';
import 'package:hqapp/models/quiz_result.dart';
import 'package:hqapp/models/user_profile.dart';

// Debug logging helper
void _debugLog(
  String location,
  String message,
  Map<String, dynamic> data,
  String hypothesisId,
) {
  if (kDebugMode) {
    try {
      final logEntry = {
        'id': 'log_${DateTime.now().millisecondsSinceEpoch}',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'location': location,
        'message': message,
        'data': data,
        'sessionId': 'debug-session',
        'runId': 'run1',
        'hypothesisId': hypothesisId,
      };
      final logPath = r'c:\FlutterApps\hq\.cursor\debug.log';
      final logFile = File(logPath);

      // Create directory if it doesn't exist
      final logDir = logFile.parent;
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      // Write log entry
      logFile.writeAsStringSync(
        '${jsonEncode(logEntry)}\n',
        mode: FileMode.append,
      );

      // Also print to console for immediate visibility
      print(
        '🔍 [DEBUG] $location: $message | Data: $data | Hypothesis: $hypothesisId',
      );
    } catch (e) {
      // Print error if logging fails
      print('❌ Debug log write failed: $e');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}

class FirestoreService {
  FirestoreService._();

  static DatabaseReference get _db {
    // Get database URL from Firebase options
    final app = Firebase.app();
    final databaseUrl = app.options.databaseURL;
    if (databaseUrl == null || databaseUrl.isEmpty) {
      throw Exception(
        'Database URL is not configured. Please check firebase_options.dart',
      );
    }
    return FirebaseDatabase.instanceFor(
      app: app,
      databaseURL: databaseUrl,
    ).ref();
  }

  static const _usersPath = 'users';
  static const _feedbackPath = 'feedback';
  static const _leaderboardPath = 'quizResults';
  static const _pointsLeaderboardPath = 'leaderboard';
  static const _notificationsPath = 'notifications';
  static const _otpPath = 'passwordResetOTPs';

  static String _hashPassword(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  static Future<UserProfile> registerUser({
    required String fullName,
    required String email,
    required String contactNo,
    required String password,
    String visitorType = 'Local',
    bool isAdmin = false,
  }) async {
    try {
      // Convert email to lowercase
      final normalizedEmail = email.toLowerCase().trim();

      // Check if email already exists
      final usersSnapshot = await _db
          .child(_usersPath)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (usersSnapshot.exists) {
        final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
        if (usersData != null) {
          for (var entry in usersData.entries) {
            final userData = entry.value as Map<dynamic, dynamic>;
            final existingEmail = (userData['email'] as String? ?? '')
                .toLowerCase();
            if (existingEmail == normalizedEmail) {
              throw const AuthException(
                'An account with this email already exists.',
              );
            }
          }
        }
      }

      // Create new user
      final newUserRef = _db.child(_usersPath).push();
      final userId = newUserRef.key!;

      final profile = UserProfile(
        id: userId,
        fullName: fullName,
        email: normalizedEmail,
        contactNo: contactNo,
        visitorType: visitorType,
        isAdmin: isAdmin,
      );

      await newUserRef
          .set({...profile.toMap(), 'passwordHash': _hashPassword(password)})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );
      return profile;
    } catch (e) {
      // Print error for debugging
      if (kDebugMode) {
        print('Register error: $e');
        print('Error type: ${e.runtimeType}');
      }

      if (e is AuthException) {
        rethrow;
      }

      // Handle FirebaseException (works on mobile platforms)
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            throw Exception(
              'Database permission error. Please contact support or check Firebase rules.',
            );
          case 'unavailable':
          case 'unreachable':
            throw Exception(
              'Cannot connect to database. Please check your internet connection and try again.',
            );
          case 'deadline-exceeded':
            throw Exception(
              'Connection timeout. Please check your internet connection and try again.',
            );
          default:
            throw Exception(
              'Failed to create account: ${e.message ?? e.code}. Please try again or contact support.',
            );
        }
      }

      // Handle all other errors (including web platform errors)
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('permission') ||
          errorMessage.contains('permission-denied')) {
        throw Exception(
          'Database permission error. Please contact support or check Firebase rules.',
        );
      } else if (errorMessage.contains('timeout') ||
          errorMessage.contains('deadline')) {
        throw Exception(
          'Connection timeout. Please check your internet connection and try again.',
        );
      } else if (errorMessage.contains('unavailable') ||
          errorMessage.contains('unreachable') ||
          errorMessage.contains('network')) {
        throw Exception(
          'Cannot connect to database. Please check your internet connection and try again.',
        );
      } else {
        throw Exception(
          'Failed to create account: ${e.toString()}. Please try again or contact support.',
        );
      }
    }
  }

  static Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      // Convert email to lowercase
      final normalizedEmail = email.toLowerCase().trim();

      final usersSnapshot = await _db
          .child(_usersPath)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (!usersSnapshot.exists) {
        throw const AuthException('The email is not registered.  ');
      }

      final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
      if (usersData == null || usersData.isEmpty) {
        throw const AuthException('The email is not registered.  ');
      }

      // Find user by email
      String? userId;
      Map<dynamic, dynamic>? userData;

      for (var entry in usersData.entries) {
        final data = entry.value as Map<dynamic, dynamic>;
        final existingEmail = (data['email'] as String? ?? '').toLowerCase();
        if (existingEmail == normalizedEmail) {
          userId = entry.key as String;
          userData = data;
          break;
        }
      }

      if (userId == null || userData == null) {
        throw const AuthException('The email is not registered.  ');
      }

      final storedHash = userData['passwordHash'] as String? ?? '';
      if (storedHash != _hashPassword(password)) {
        throw const AuthException('Invalid email or password.');
      }

      return UserProfile.fromMap(userId, Map<String, dynamic>.from(userData));
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }

      // Handle FirebaseException (works on mobile platforms)
      if (e is FirebaseException) {
        switch (e.code) {
          case 'permission-denied':
            throw Exception(
              'Database permission error. Please contact support or check Firebase rules.',
            );
          case 'unavailable':
          case 'unreachable':
            throw Exception(
              'Cannot connect to database. Please check your internet connection and try again.',
            );
          case 'deadline-exceeded':
            throw Exception(
              'Connection timeout. Please check your internet connection and try again.',
            );
          default:
            throw Exception(
              'Failed to login: ${e.message ?? e.code}. Please try again or contact support.',
            );
        }
      }

      // Handle all other errors (including web platform errors)
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('permission') ||
          errorMessage.contains('permission-denied')) {
        throw Exception(
          'Database permission error. Please contact support or check Firebase rules.',
        );
      } else if (errorMessage.contains('timeout') ||
          errorMessage.contains('deadline')) {
        throw Exception(
          'Connection timeout. Please check your internet connection and try again.',
        );
      } else if (errorMessage.contains('unavailable') ||
          errorMessage.contains('unreachable') ||
          errorMessage.contains('network')) {
        throw Exception(
          'Cannot connect to database. Please check your internet connection and try again.',
        );
      } else {
        throw Exception(
          'Failed to login: ${e.toString()}. Please try again or contact support.',
        );
      }
    }
  }

  static Stream<List<UserProfile>> usersStream() {
    return _db
        .child(_usersPath)
        .onValue
        .map((event) {
          if (!event.snapshot.exists) {
            return <UserProfile>[];
          }

          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) {
            return <UserProfile>[];
          }

          return data.entries.map((entry) {
            final userId = entry.key as String;
            final userData = entry.value as Map<dynamic, dynamic>;
            return UserProfile.fromMap(
              userId,
              Map<String, dynamic>.from(userData),
            );
          }).toList();
        })
        .handleError((error) {
          throw Exception('Failed to load users: ${error.toString()}');
        });
  }

  static Future<void> deleteUser(String userId) {
    return _db.child(_usersPath).child(userId).remove();
  }

  static Future<void> updateUser(UserProfile profile) {
    return _db.child(_usersPath).child(profile.id).update(profile.toMap());
  }

  static Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Get user data to verify old password
      final userSnapshot = await _db
          .child(_usersPath)
          .child(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (!userSnapshot.exists) {
        throw const AuthException('User not found.');
      }

      final userData = userSnapshot.value as Map<dynamic, dynamic>?;
      if (userData == null) {
        throw const AuthException('User not found.');
      }

      final storedHash = userData['passwordHash'] as String? ?? '';
      if (storedHash != _hashPassword(oldPassword)) {
        throw const AuthException('Current password is incorrect.');
      }

      // Update password
      await _db
          .child(_usersPath)
          .child(userId)
          .update({'passwordHash': _hashPassword(newPassword)})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      if (e is FirebaseException) {
        throw Exception(
          'Failed to change password: ${e.message ?? e.code}. Please try again.',
        );
      }
      rethrow;
    }
  }

  /// Get all users (for checking email existence)
  static Future<List<UserProfile>> getAllUsers() async {
    try {
      final usersSnapshot = await _db
          .child(_usersPath)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (!usersSnapshot.exists) {
        return [];
      }

      final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
      if (usersData == null) {
        return [];
      }

      final users = <UserProfile>[];
      for (var entry in usersData.entries) {
        final userId = entry.key as String;
        final userData = entry.value as Map<dynamic, dynamic>;
        try {
          users.add(
            UserProfile.fromMap(userId, Map<String, dynamic>.from(userData)),
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error parsing user $userId: $e');
          }
        }
      }
      return users;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all users: $e');
      }
      return [];
    }
  }

  static Future<String> verifyEmailForPasswordReset({
    required String email,
  }) async {
    try {
      // Convert email to lowercase
      final normalizedEmail = email.toLowerCase().trim();

      final usersSnapshot = await _db
          .child(_usersPath)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (!usersSnapshot.exists) {
        throw const AuthException('The email is not registered.  ');
      }

      final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
      if (usersData == null || usersData.isEmpty) {
        throw const AuthException('The email is not registered. ');
      }

      // Find user by email
      String? userId;

      for (var entry in usersData.entries) {
        final userData = entry.value as Map<dynamic, dynamic>;
        final existingEmail = (userData['email'] as String? ?? '')
            .toLowerCase();
        if (existingEmail == normalizedEmail) {
          userId = entry.key as String;
          break;
        }
      }

      if (userId == null) {
        throw const AuthException('The email is not registered.  ');
      }

      return userId;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      if (e is FirebaseException) {
        throw Exception(
          'Failed to verify email: ${e.message ?? e.code}. Please try again.',
        );
      }
      rethrow;
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Convert email to lowercase
      final normalizedEmail = email.toLowerCase().trim();

      final usersSnapshot = await _db
          .child(_usersPath)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (!usersSnapshot.exists) {
        throw const AuthException('The email is not registered.  ');
      }

      final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
      if (usersData == null || usersData.isEmpty) {
        throw const AuthException('The email is not registered. ');
      }

      // Find user by email
      String? userId;

      for (var entry in usersData.entries) {
        final userData = entry.value as Map<dynamic, dynamic>;
        final existingEmail = (userData['email'] as String? ?? '')
            .toLowerCase();
        if (existingEmail == normalizedEmail) {
          userId = entry.key as String;
          break;
        }
      }

      if (userId == null) {
        throw const AuthException('The email is not registered.  ');
      }

      // Update password
      await _db
          .child(_usersPath)
          .child(userId)
          .update({'passwordHash': _hashPassword(newPassword)})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      if (e is FirebaseException) {
        throw Exception(
          'Failed to reset password: ${e.message ?? e.code}. Please try again.',
        );
      }
      rethrow;
    }
  }

  static Future<void> submitFeedback({
    required UserProfile user,
    required String message,
  }) {
    final feedbackRef = _db.child(_feedbackPath).push();
    return feedbackRef.set({
      'userId': user.id,
      'userName': user.fullName,
      'message': message,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  static Stream<List<FeedbackEntry>> feedbackStream() {
    return _db
        .child(_feedbackPath)
        .orderByChild('createdAt')
        .onValue
        .map((event) {
          if (!event.snapshot.exists) {
            return <FeedbackEntry>[];
          }

          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) {
            return <FeedbackEntry>[];
          }

          final feedbackList = data.entries.map((entry) {
            final feedbackId = entry.key as String;
            final feedbackData = entry.value as Map<dynamic, dynamic>;
            return FeedbackEntry.fromMap(
              feedbackId,
              Map<String, dynamic>.from(feedbackData),
            );
          }).toList();

          // Sort by createdAt descending
          feedbackList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return feedbackList;
        })
        .handleError((error) {
          throw Exception('Failed to load feedback: ${error.toString()}');
        });
  }

  static Future<void> recordQuizResult({
    required UserProfile user,
    required int score,
    required int totalQuestions,
  }) async {
    if (user.id == 'guest') {
      return;
    }

    try {
      if (kDebugMode) {
        print(
          'Recording quiz result: User ${user.id}, Score: $score/$totalQuestions',
        );
      }

      final resultRef = _db.child(_leaderboardPath).push();
      await resultRef.set({
        'userId': user.id,
        'userName': user.fullName,
        'score': score,
        'totalQuestions': totalQuestions,
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('Successfully recorded quiz result');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error recording quiz result: $e');
      }
      rethrow;
    }
  }

  static Stream<List<QuizResult>> leaderboardStream() {
    return _db
        .child(_leaderboardPath)
        .orderByChild('score')
        .onValue
        .map((event) {
          if (!event.snapshot.exists) {
            return <QuizResult>[];
          }

          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) {
            return <QuizResult>[];
          }

          final results = data.entries.map((entry) {
            final resultId = entry.key as String;
            final resultData = entry.value as Map<dynamic, dynamic>;
            return QuizResult.fromMap(
              resultId,
              Map<String, dynamic>.from(resultData),
            );
          }).toList();

          // Sort by score descending, then by createdAt descending
          results.sort((a, b) {
            if (a.score != b.score) {
              return b.score.compareTo(a.score);
            }
            return b.createdAt.compareTo(a.createdAt);
          });
          return results;
        })
        .handleError((error) {
          throw Exception('Failed to load leaderboard: ${error.toString()}');
        });
  }

  static Future<List<QuizResult>> getUserQuizResults(String userId) async {
    try {
      // Get all quiz results first, then filter by userId
      // This is more reliable than using orderByChild/equalTo which might fail
      final snapshot = await _db.child(_leaderboardPath).get();

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) {
        return [];
      }

      final results = <QuizResult>[];
      for (var entry in data.entries) {
        final resultId = entry.key as String;
        final resultData = entry.value as Map<dynamic, dynamic>;
        // Filter by userId
        if (resultData['userId'] == userId) {
          try {
            results.add(
              QuizResult.fromMap(
                resultId,
                Map<String, dynamic>.from(resultData),
              ),
            );
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing quiz result $resultId: $e');
            }
          }
        }
      }

      if (kDebugMode) {
        print('Found ${results.length} quiz results for user $userId');
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user quiz results: $e');
      }
      return [];
    }
  }

  static Future<void> updateUserAdminStatus(String userId, bool isAdmin) async {
    await _db.child(_usersPath).child(userId).update({
      'admin': isAdmin ? 'Y' : 'N',
    });
  }

  static Future<void> updateUserPoints({
    required String userId,
    required String userName,
    required int totalPoints,
  }) async {
    await _db.child(_pointsLeaderboardPath).child(userId).set({
      'userName': userName,
      'totalPoints': totalPoints,
      'lastUpdated': DateTime.now().toIso8601String(),
    });
  }

  static Stream<List<LeaderboardEntry>> pointsLeaderboardStream() {
    return _db
        .child(_pointsLeaderboardPath)
        .onValue
        .map((event) {
          if (!event.snapshot.exists) {
            return <LeaderboardEntry>[];
          }

          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) {
            return <LeaderboardEntry>[];
          }

          final entries = data.entries.map((entry) {
            final userId = entry.key as String;
            final entryData = entry.value as Map<dynamic, dynamic>;
            return LeaderboardEntry.fromMap(
              userId,
              Map<String, dynamic>.from(entryData),
            );
          }).toList();

          // Sort by totalPoints descending, then by lastUpdated descending
          entries.sort((a, b) {
            if (a.totalPoints != b.totalPoints) {
              return b.totalPoints.compareTo(a.totalPoints);
            }
            return b.lastUpdated.compareTo(a.lastUpdated);
          });
          return entries;
        })
        .handleError((error) {
          if (kDebugMode) {
            print('Error loading leaderboard: $error');
          }
          return <LeaderboardEntry>[];
        });
  }

  static Future<int> getUserTotalPoints(String userId) async {
    try {
      final snapshot = await _db
          .child(_pointsLeaderboardPath)
          .child(userId)
          .get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return (data['totalPoints'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user points: $e');
      }
      return 0;
    }
  }

  /// Calculate achievements and update leaderboard points for a user
  static Future<void> updateUserAchievementsAndLeaderboard({
    required String userId,
    required String userName,
  }) async {
    try {
      final quizResults = await getUserQuizResults(userId);
      final quizCount = quizResults.length;
      final hasFullMark = quizResults.any((r) => r.score == r.totalQuestions);
      final hasPerfectScore = quizResults.any(
        (r) => r.score == r.totalQuestions && r.totalQuestions >= 5,
      );

      // Calculate achievement points
      int totalPoints = 0;

      // First Quiz - 50 points
      if (quizCount >= 1) totalPoints += 50;

      // Perfect Score - 100 points
      if (hasFullMark) totalPoints += 100;

      // Quiz Master (5 quizzes) - 150 points
      if (quizCount >= 5) totalPoints += 150;

      // History Expert (10 quizzes) - 250 points
      if (quizCount >= 10) totalPoints += 250;

      // Flawless Victory (perfect 5-question quiz) - 200 points
      if (hasPerfectScore) totalPoints += 200;

      // Dedicated Learner (20 quizzes) - 300 points
      if (quizCount >= 20) totalPoints += 300;

      // Heritage Scholar (30 quizzes) - 400 points
      if (quizCount >= 30) totalPoints += 400;

      // Master Explorer (50 quizzes) - 500 points
      if (quizCount >= 50) totalPoints += 500;

      if (kDebugMode) {
        print(
          'Calculated total points: $totalPoints for user $userId (quizCount: $quizCount)',
        );
      }

      // Update leaderboard with calculated points - use set to ensure it's saved
      await _db.child(_pointsLeaderboardPath).child(userId).set({
        'userId': userId,
        'userName': userName,
        'totalPoints': totalPoints,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        print('Successfully saved $totalPoints points for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating achievements and leaderboard: $e');
        print('Error details: ${e.toString()}');
      }
      rethrow; // Re-throw to see error in quiz screen
    }
  }

  /// Create a notification for a user
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'general',
  }) async {
    try {
      final notificationRef = _db.child(_notificationsPath).push();
      await notificationRef.set({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification: $e');
      }
    }
  }

  /// Get notifications stream for a user
  static Stream<List<NotificationEntry>> notificationsStream(String userId) {
    return _db
        .child(_notificationsPath)
        .onValue
        .map((event) {
          if (!event.snapshot.exists) {
            return <NotificationEntry>[];
          }

          final data = event.snapshot.value as Map<dynamic, dynamic>?;
          if (data == null) {
            return <NotificationEntry>[];
          }

          final notifications = <NotificationEntry>[];
          for (var entry in data.entries) {
            final notificationId = entry.key as String;
            final notificationData = entry.value as Map<dynamic, dynamic>;
            // Filter by userId
            if (notificationData['userId'] == userId) {
              notifications.add(
                NotificationEntry.fromMap(
                  notificationId,
                  Map<String, dynamic>.from(notificationData),
                ),
              );
            }
          }

          // Sort by createdAt descending (newest first)
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notifications;
        })
        .handleError((error) {
          if (kDebugMode) {
            print('Error loading notifications: $error');
          }
          return <NotificationEntry>[];
        });
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.child(_notificationsPath).child(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
    }
  }

  /// Mark all notifications as read for a user
  static Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _db.child(_notificationsPath).get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          final updates = <String, dynamic>{};
          for (var entry in data.entries) {
            final notificationData = entry.value as Map<dynamic, dynamic>;
            // Filter by userId
            if (notificationData['userId'] == userId) {
              updates['${_notificationsPath}/${entry.key}/isRead'] = true;
            }
          }
          if (updates.isNotEmpty) {
            await _db.update(updates);
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
    }
  }

  /// Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await _db.child(_notificationsPath).child(notificationId).remove();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
    }
  }

  /// Verify email exists and return userId
  static Future<String> verifyEmailExists(String email) async {
    final normalizedEmail = email.toLowerCase().trim();

    final usersSnapshot = await _db
        .child(_usersPath)
        .get()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
              'Connection timeout. Please check your internet connection and try again.',
            );
          },
        );

    if (!usersSnapshot.exists) {
      throw const AuthException('The email is not registered. ');
    }

    final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
    if (usersData == null || usersData.isEmpty) {
      throw const AuthException('The email is not registered.  ');
    }

    // Find user by email
    String? userId;
    for (var entry in usersData.entries) {
      final userData = entry.value as Map<dynamic, dynamic>;
      final existingEmail = (userData['email'] as String? ?? '')
          .trim()
          .toLowerCase();

      if (existingEmail == normalizedEmail) {
        userId = entry.key as String;
        break;
      }
    }

    if (userId == null) {
      throw const AuthException(' The email is not registered.  ');
    }

    return userId;
  }

  /// Store OTP in Firebase for password reset
  static Future<void> storeOTPForPasswordReset({
    required String email,
    required String userId,
    required String otp,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();

    // Store OTP with expiration (10 minutes)
    final otpData = {
      'email': normalizedEmail,
      'userId': userId,
      'otp': otp,
      'createdAt': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now()
          .add(const Duration(minutes: 10))
          .toIso8601String(),
      'used': false,
    };

    // Store OTP (use email as key for easy lookup, replace special chars)
    final otpKey = normalizedEmail.replaceAll('.', '_').replaceAll('@', '_');

    await _db
        .child(_otpPath)
        .child(otpKey)
        .set(otpData)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
              'Connection timeout. Please check your internet connection and try again. OTP: $otp',
            );
          },
        );

    // Verify OTP was stored successfully
    if (kDebugMode) {
      final verifySnapshot = await _db
          .child(_otpPath)
          .child(otpKey)
          .get()
          .timeout(const Duration(seconds: 5));

      if (!verifySnapshot.exists) {
        throw Exception(
          'OTP was generated but failed to store in database. Please try again.',
        );
      }
    }
  }

  /// Generate and store OTP for password reset
  static Future<String> generateOTPForPasswordReset({
    required String email,
  }) async {
    try {
      // Convert email to lowercase and trim whitespace
      final normalizedEmail = email.toLowerCase().trim();

      if (kDebugMode) {
        print('🔍 Looking for email: $normalizedEmail');
      }

      // #region agent log
      _debugLog(
        'firestore_service.dart:988',
        'Checking if email exists in database',
        {'email': normalizedEmail},
        'C',
      );
      // #endregion

      // Verify email exists first
      final usersSnapshot = await _db
          .child(_usersPath)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              // #region agent log
              _debugLog(
                'firestore_service.dart:995',
                'Database query timeout',
                {'email': normalizedEmail},
                'C',
              );
              // #endregion

              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      // #region agent log
      _debugLog('firestore_service.dart:1001', 'Database query completed', {
        'email': normalizedEmail,
        'snapshotExists': usersSnapshot.exists,
      }, 'C');
      // #endregion

      if (!usersSnapshot.exists) {
        // #region agent log
        _debugLog('firestore_service.dart:1005', 'No users found in database', {
          'email': normalizedEmail,
        }, 'C');
        // #endregion

        if (kDebugMode) {
          print('❌ No users found in database');
        }
        throw const AuthException('The email is not registered.  ');
      }

      final usersData = usersSnapshot.value as Map<dynamic, dynamic>?;
      if (usersData == null || usersData.isEmpty) {
        // #region agent log
        _debugLog(
          'firestore_service.dart:1013',
          'Users data is null or empty',
          {'email': normalizedEmail},
          'C',
        );
        // #endregion

        if (kDebugMode) {
          print('❌ Users data is null or empty');
        }
        throw const AuthException('The email is not registered.  ');
      }

      if (kDebugMode) {
        print('📊 Total users in database: ${usersData.length}');
      }

      // Find user by email - check both exact match and trimmed/lowercase match
      String? userId;
      List<String> foundEmails = [];

      for (var entry in usersData.entries) {
        final userData = entry.value as Map<dynamic, dynamic>;
        final existingEmail = (userData['email'] as String? ?? '').trim();
        final existingEmailLower = existingEmail.toLowerCase();

        if (kDebugMode && foundEmails.length < 5) {
          foundEmails.add(existingEmailLower);
        }

        // Match with normalized email (case-insensitive, trimmed)
        if (existingEmailLower == normalizedEmail) {
          userId = entry.key as String;
          if (kDebugMode) {
            print('✅ Found user: $userId with email: $existingEmail');
          }
          break;
        }
      }

      if (kDebugMode && userId == null) {
        print('❌ Email not found. Searched emails (first 5): $foundEmails');
        print('❌ Looking for: $normalizedEmail');
      }

      if (userId == null) {
        // #region agent log
        _debugLog('firestore_service.dart:1048', 'Email not found in users', {
          'email': normalizedEmail,
          'searchedEmails': foundEmails,
        }, 'C');
        // #endregion

        throw const AuthException('The email is not registered.  ');
      }

      // #region agent log
      _debugLog(
        'firestore_service.dart:1055',
        'User found, proceeding to generate OTP',
        {'email': normalizedEmail, 'userId': userId},
        'B',
      );
      // #endregion

      // Generate 6-digit OTP
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString();

      // #region agent log
      _debugLog('firestore_service.dart:1072', 'OTP generated', {
        'email': normalizedEmail,
        'userId': userId,
        'otp': otp,
      }, 'B');
      // #endregion

      // Store OTP with expiration (10 minutes)
      final otpData = {
        'email': normalizedEmail,
        'userId': userId,
        'otp': otp,
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now()
            .add(const Duration(minutes: 10))
            .toIso8601String(),
        'used': false,
      };

      // Store OTP (use email as key for easy lookup, replace special chars)
      final otpKey = normalizedEmail.replaceAll('.', '_').replaceAll('@', '_');

      // #region agent log
      _debugLog('firestore_service.dart:1095', 'Attempting database write', {
        'path': '$_otpPath/$otpKey',
        'otp': otp,
      }, 'D');
      // #endregion

      if (kDebugMode) {
        print('💾 Storing OTP in database...');
        print('📁 Path: $_otpPath/$otpKey');
        print('🔑 OTP: $otp');
      }

      try {
        await _db
            .child(_otpPath)
            .child(otpKey)
            .set(otpData)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                // #region agent log
                _debugLog(
                  'firestore_service.dart:1106',
                  'Database write timeout',
                  {'path': '$_otpPath/$otpKey'},
                  'D',
                );
                // #endregion

                if (kDebugMode) {
                  print('❌ Database write timeout');
                }
                throw Exception(
                  'Connection timeout. Please check your internet connection and try again. OTP: $otp',
                );
              },
            );

        // #region agent log
        _debugLog('firestore_service.dart:1110', 'Database write completed', {
          'path': '$_otpPath/$otpKey',
          'otp': otp,
        }, 'D');
        // #endregion

        // Verify OTP was stored successfully
        if (kDebugMode) {
          final verifySnapshot = await _db
              .child(_otpPath)
              .child(otpKey)
              .get()
              .timeout(const Duration(seconds: 5));

          if (verifySnapshot.exists) {
            print('✅ OTP successfully stored and verified in database');
            final storedData = verifySnapshot.value as Map<dynamic, dynamic>?;
            if (storedData != null && storedData['otp'] == otp) {
              print('✅ OTP matches stored value');
            } else {
              print('⚠️ Warning: OTP stored but value mismatch');
            }
          } else {
            print(
              '❌ ERROR: OTP write succeeded but verification failed - OTP not found in database',
            );
            throw Exception(
              'OTP was generated but failed to store in database. Please try again.',
            );
          }
        }

        return otp;
      } on FirebaseException catch (e) {
        if (kDebugMode) {
          print('❌ Firebase Database Error:');
          print('   Code: ${e.code}');
          print('   Message: ${e.message}');
        }

        // #region agent log
        _debugLog(
          'firestore_service.dart:1143',
          'FirebaseException during database write',
          {'code': e.code, 'message': e.message, 'otp': otp},
          'D',
        );
        // #endregion

        // Handle specific Firebase errors
        if (e.code == 'permission-denied') {
          throw Exception(
            'Database permission denied. Please check Firebase Database rules. OTP: $otp',
          );
        } else if (e.code == 'unavailable' || e.code == 'unreachable') {
          throw Exception(
            'Cannot connect to database. Please check your internet connection and try again. OTP: $otp',
          );
        } else {
          throw Exception(
            'Failed to store OTP in database: ${e.message ?? e.code}. OTP: $otp',
          );
        }
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      if (e is FirebaseException) {
        throw Exception(
          'Failed to generate OTP: ${e.message ?? e.code}. Please try again.',
        );
      }
      rethrow;
    }
  }

  /// Verify OTP for password reset
  static Future<String> verifyOTPForPasswordReset({
    required String email,
    required String otp,
  }) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      final otpKey = normalizedEmail.replaceAll('.', '_').replaceAll('@', '_');

      if (kDebugMode) {
        print('🔍 Verifying OTP for email: $normalizedEmail');
        print('🔍 OTP Key: $otpKey');
        print('🔍 OTP entered: $otp');
      }

      final otpSnapshot = await _db
          .child(_otpPath)
          .child(otpKey)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (!otpSnapshot.exists) {
        if (kDebugMode) {
          print('❌ OTP not found in database for key: $otpKey');
        }
        throw const AuthException(
          'Invalid or expired OTP. Please request a new one.',
        );
      }

      final otpData = otpSnapshot.value as Map<dynamic, dynamic>?;
      if (otpData == null) {
        if (kDebugMode) {
          print('❌ OTP data is null');
        }
        throw const AuthException(
          'Invalid or expired OTP. Please request a new one.',
        );
      }

      if (kDebugMode) {
        print('📧 OTP data found: ${otpData['otp']}');
        print('📧 OTP used: ${otpData['used']}');
        print('📧 OTP expires at: ${otpData['expiresAt']}');
      }

      // Check if OTP is already used
      if (otpData['used'] == true) {
        if (kDebugMode) {
          print('❌ OTP has already been used');
        }
        throw const AuthException(
          'This OTP has already been used. Please request a new one.',
        );
      }

      // Check if OTP matches (trim both for safety)
      final storedOtp = (otpData['otp'] as String?)?.trim();
      final enteredOtp = otp.trim();

      if (storedOtp == null || storedOtp.isEmpty) {
        if (kDebugMode) {
          print('❌ Stored OTP is null or empty');
        }
        throw const AuthException('Wrong OTP please try again');
      }

      if (storedOtp != enteredOtp) {
        if (kDebugMode) {
          print(
            '❌ OTP mismatch. Stored: "$storedOtp" (length: ${storedOtp.length}), Entered: "$enteredOtp" (length: ${enteredOtp.length})',
          );
        }
        throw const AuthException('Wrong OTP please try again');
      }

      if (kDebugMode) {
        print('✅ OTP matches: $storedOtp');
      }

      // Check if OTP is expired
      final expiresAt = DateTime.parse(otpData['expiresAt'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        if (kDebugMode) {
          print(
            '❌ OTP has expired. Expires at: $expiresAt, Now: ${DateTime.now()}',
          );
        }
        throw const AuthException('OTP has expired. Please request a new one.');
      }

      if (kDebugMode) {
        print('✅ OTP verified successfully');
      }

      // Mark OTP as used
      await _db.child(_otpPath).child(otpKey).update({'used': true});

      // Return userId for password reset
      final userId = otpData['userId'] as String;
      if (kDebugMode) {
        print('✅ OTP marked as used. UserId: $userId');
      }
      return userId;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      if (e is FirebaseException) {
        if (kDebugMode) {
          print(
            '❌ Firebase Exception during OTP verification: ${e.code} - ${e.message}',
          );
        }
        throw Exception(
          'Failed to verify OTP: ${e.message ?? e.code}. Please try again.',
        );
      }
      if (kDebugMode) {
        print('❌ Exception during OTP verification: $e');
      }
      rethrow;
    }
  }

  /// Reset password using verified OTP
  static Future<void> resetPasswordWithOTP({
    required String userId,
    required String newPassword,
    String? email,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 Resetting password for userId: $userId');
        if (email != null) {
          print('🔄 Email provided: $email');
        }
      }

      // Validate userId
      if (userId.isEmpty) {
        throw const AuthException(
          'Invalid user information. Please try the password reset process again.',
        );
      }

      // First, verify the user exists
      String actualUserId = userId;

      final userSnapshot = await _db
          .child(_usersPath)
          .child(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      // If user not found by userId, try to find by email as fallback
      if (!userSnapshot.exists) {
        if (kDebugMode) {
          print('⚠️ User not found with userId: $userId');
          if (email != null) {
            print('🔍 Attempting to find user by email: $email');
          }
        }

        // Try to find user by email if provided
        if (email != null && email.isNotEmpty) {
          try {
            actualUserId = await verifyEmailExists(email);
            if (kDebugMode) {
              print('✅ Found user by email. New userId: $actualUserId');
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Could not find user by email either: $e');
            }
            throw const AuthException(
              'User account not found. Please contact support.',
            );
          }
        } else {
          throw const AuthException(
            'User account not found. Please contact support.',
          );
        }
      }

      // Hash the new password
      final hashedPassword = _hashPassword(newPassword);

      if (kDebugMode) {
        print('🔐 Password hashed. Updating database...');
        print('🔐 User path: $_usersPath/$actualUserId');
      }

      // Update password using update() method (same as changePassword)
      await _db
          .child(_usersPath)
          .child(actualUserId)
          .update({'passwordHash': hashedPassword})
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection and try again.',
              );
            },
          );

      if (kDebugMode) {
        print('✅ Password updated in database for userId: $actualUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting password: $e');
        print('❌ Error type: ${e.runtimeType}');
      }
      if (e is AuthException) {
        rethrow;
      }
      if (e is FirebaseException) {
        throw Exception(
          'Failed to reset password: ${e.message ?? e.code}. Please try again.',
        );
      }
      rethrow;
    }
  }
}
