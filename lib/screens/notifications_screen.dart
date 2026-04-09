import 'package:flutter/material.dart';
import 'package:hqapp/models/notification_entry.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/localization/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  final UserProfile user;

  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  ({String title, String message}) _localizedNotificationText(
    NotificationEntry notification,
  ) {
    final l = AppLocalizations.of(context);

    // Known achievement notifications (old saved titles)
    final titleMap = <String, String>{
      '🎯 Achievement Unlocked: First Quiz!': l.t(
        'achievement_unlocked_first_quiz_title',
      ),
      '🏆 Achievement Unlocked: Perfect Score!': l.t(
        'achievement_unlocked_perfect_score_title',
      ),
      '📚 Achievement Unlocked: Quiz Master!': l.t(
        'achievement_unlocked_quiz_master_title',
      ),
      '⭐ Achievement Unlocked: Flawless Victory!': l.t(
        'achievement_unlocked_flawless_victory_title',
      ),
      // Arabic variants (in case old notifications were created in Arabic)
      '🎯 تم فتح إنجاز: أول اختبار!': l.t('achievement_unlocked_first_quiz_title'),
      '🏆 تم فتح إنجاز: نتيجة كاملة!': l.t('achievement_unlocked_perfect_score_title'),
      '📚 تم فتح إنجاز: خبير الاختبارات!': l.t('achievement_unlocked_quiz_master_title'),
      '⭐ تم فتح إنجاز: انتصار مثالي!': l.t('achievement_unlocked_flawless_victory_title'),
    };

    final messageMap = <String, String>{
      'You completed your first quiz! Keep exploring to unlock more achievements.':
          l.t('achievement_unlocked_first_quiz_message'),
      'Amazing! You got full marks in the quiz!':
          l.t('achievement_unlocked_perfect_score_message'),
      "Congratulations! You've completed 5 quizzes. You're becoming a quiz master!":
          l.t('achievement_unlocked_quiz_master_message'),
      'Incredible! You got a perfect score on a 5-question quiz!':
          l.t('achievement_unlocked_flawless_victory_message'),
      // Arabic variants
      'لقد أكملت أول اختبار لك! استمر في الاستكشاف لفتح المزيد من الإنجازات.':
          l.t('achievement_unlocked_first_quiz_message'),
      'مذهل! لقد حصلت على العلامة الكاملة في الاختبار!':
          l.t('achievement_unlocked_perfect_score_message'),
      'تهانينا! لقد أكملت 5 اختبارات. أنت تصبح خبيراً في الاختبارات!':
          l.t('achievement_unlocked_quiz_master_message'),
      'رائع! لقد حققت نتيجة كاملة في اختبار من 5 أسئلة!':
          l.t('achievement_unlocked_flawless_victory_message'),
    };

    String title = notification.title;
    String message = notification.message;

    // Localize known achievement notifications
    if (notification.type == 'achievement') {
      title = titleMap[notification.title] ?? notification.title;
      message = messageMap[notification.message] ?? notification.message;
      return (title: title, message: message);
    }

    // Localize quiz completion notifications (parse score/total from old messages)
    if (notification.type == 'quiz') {
      final rawTitle = notification.title.trim();
      if (rawTitle == 'Quiz Completed!' || rawTitle == 'تم إنهاء الاختبار!') {
        title = l.t('quiz_completed_notification_title');
      }

      final enMatch = RegExp(r'You scored (\d+) out of (\d+)\.\s*(.*)$')
          .firstMatch(notification.message.trim());
      final arMatch = RegExp(r'لقد حصلت على (\d+) من (\d+)\.\s*(.*)$')
          .firstMatch(notification.message.trim());

      final match = enMatch ?? arMatch;
      if (match != null) {
        final score = match.group(1) ?? '';
        final total = match.group(2) ?? '';
        final tail = (match.group(3) ?? '').trim();

        final isPerfect = tail.toLowerCase().contains('perfect') ||
            tail.contains('نتيجة كاملة');
        final suffix = isPerfect
            ? l.t('quiz_completed_suffix_perfect')
            : l.t('quiz_completed_suffix_great');

        message = l.t(
          'quiz_completed_notification_message',
          params: {'score': score, 'total': total, 'suffix': suffix},
        );
      }

      return (title: title, message: message);
    }

    return (title: title, message: message);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (widget.user.id == 'guest') {
      return Scaffold(
        appBar: AppBar(
          title: Text(l.t('notifications_title')),
          backgroundColor: const Color(0xFF6B4423),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  l.t('notifications_login_required'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l.t('notifications_login_message'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('notifications_title')),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<List<NotificationEntry>>(
            stream: FirestoreService.notificationsStream(widget.user.id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final unreadCount = snapshot.data!
                    .where((n) => !n.isRead)
                    .length;
                if (unreadCount > 0) {
                  return TextButton(
                    onPressed: () async {
                      await FirestoreService.markAllNotificationsAsRead(
                        widget.user.id,
                      );
                    },
                    child: Text(
                      l.t('notifications_mark_all_read'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationEntry>>(
        stream: FirestoreService.notificationsStream(widget.user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l.t('notifications_empty_title'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.t('notifications_empty_message'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              // Force refresh by rebuilding
              setState(() {});
            },
            child: ListView.builder(
              itemCount: notifications.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(notification);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationTile(NotificationEntry notification) {
    IconData icon;
    Color iconColor;

    switch (notification.type) {
      case 'achievement':
        icon = Icons.workspace_premium;
        iconColor = const Color(0xFF2E7D32);
        break;
      case 'quiz':
        icon = Icons.quiz;
        iconColor = const Color(0xFF6B4423);
        break;
      default:
        icon = Icons.notifications;
        iconColor = const Color(0xFFB8860B);
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final l = AppLocalizations.of(context);
        FirestoreService.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('notifications_deleted')),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead
            ? Colors.white
            : const Color(0xFF6B4423).withOpacity(0.05),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            _localizedNotificationText(notification).title,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(_localizedNotificationText(notification).message),
              const SizedBox(height: 4),
              Text(
                _formatDate(notification.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: notification.isRead
              ? null
              : Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4423),
                    shape: BoxShape.circle,
                  ),
                ),
          onTap: () async {
            if (!notification.isRead) {
              await FirestoreService.markNotificationAsRead(notification.id);
            }
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return l.t('time_just_now');
        }
        return l.t(
          'time_minutes_ago',
          params: {'value': difference.inMinutes.toString()},
        );
      }
      return l.t(
        'time_hours_ago',
        params: {'value': difference.inHours.toString()},
      );
    } else if (difference.inDays == 1) {
      return l.t('time_yesterday');
    } else if (difference.inDays < 7) {
      return l.t(
        'time_days_ago',
        params: {'value': difference.inDays.toString()},
      );
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
