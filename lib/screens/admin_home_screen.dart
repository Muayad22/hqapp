import 'package:flutter/material.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/screens/admin_user_support_screen.dart';
import 'package:hqapp/screens/admin_feedback_screen.dart';
import 'package:hqapp/screens/admin_analytics_charts_screen.dart';
import 'package:hqapp/screens/leaderboard_screen.dart';
import 'package:hqapp/screens/login_screen.dart';
import 'package:hqapp/screens/edit_quiz.dart';
import 'package:hqapp/screens/manage_media_screen.dart';
import 'package:hqapp/screens/manage_users_screen.dart';
import 'package:hqapp/localization/app_localizations.dart';
import 'package:hqapp/services/session_service.dart';

class AdminHomeScreen extends StatefulWidget {
  final UserProfile user;

  const AdminHomeScreen({super.key, required this.user});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Future<void> _logout(BuildContext context) async {
    await SessionService.clearSession();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildLangChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B4423) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6B4423).withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B4423),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = widget.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('admin_title', params: {'app': l.t('app_title')})),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF6B4423),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangChip(
                  label: 'EN',
                  isSelected: AppLocalizations.currentLanguageCode == 'en',
                  onTap: () =>
                      setState(() => AppLocalizations.setLanguage('en')),
                ),
                const SizedBox(width: 4),
                _buildLangChip(
                  label: 'ع',
                  isSelected: AppLocalizations.currentLanguageCode == 'ar',
                  onTap: () =>
                      setState(() => AppLocalizations.setLanguage('ar')),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: Text(
                l.t('logout'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B4423).withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF6B4423).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative background pattern
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFB8860B).withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Icon container with gradient
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6B4423),
                                const Color(0xFF8B4513),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B4423).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.t(
                                  'admin_welcome',
                                  params: {'name': user.fullName},
                                ),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6B4423),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l.t('admin_subtitle'),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Builder(
                builder: (context) {
                  final perms = user.effectivePermissions;
                  final cards = <Widget>[];
                  if (user.isSuperAdmin || perms.canSeeManageUsers) {
                    cards.add(
                      _AdminCard(
                        icon: Icons.group,
                        title: l.t('admin_manage_users'),
                        subtitle: l.t('admin_manage_users_subtitle'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ManageUsersScreen(viewer: widget.user),
                          ),
                        ),
                      ),
                    );
                  }
                  if (perms.canSeeUserSupport) {
                    cards.add(
                      _AdminCard(
                        icon: Icons.support_agent,
                        title: l.t('admin_user_support_card_title'),
                        subtitle: l.t('admin_user_support_card_subtitle'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminUserSupportScreen(
                              viewer: widget.user,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (perms.analytics) {
                    cards.add(
                      _AdminCard(
                        icon: Icons.pie_chart,
                        title: l.t('admin_analytics_title'),
                        subtitle: l.t('admin_analytics_subtitle'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminAnalyticsChartsScreen(
                              viewer: widget.user,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (perms.canSeeFeedback) {
                    cards.add(
                      _AdminCard(
                        icon: Icons.feedback,
                        title: l.t('admin_check_feedback'),
                        subtitle: l.t('admin_check_feedback_subtitle'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminFeedbackScreen(
                              viewer: widget.user,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (perms.leaderboard) {
                    cards.add(
                      _AdminCard(
                        icon: Icons.emoji_events,
                        title: l.t('admin_check_leaderboard'),
                        subtitle: l.t('admin_check_leaderboard_subtitle'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        ),
                      ),
                    );
                  }
                  if (perms.canSeeManageQuiz) {
                    cards.add(
                      _AdminCard(
                        icon: Icons.quiz,
                        title: l.t('manage_quiz_card_title'),
                        subtitle: l.t('manage_quiz_card_subtitle'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditQuizScreen(viewer: widget.user),
                          ),
                        ),
                      ),
                    );
                  }
                  if (perms.canSeeManageMedia) {
                    cards.add(
                      _AdminCard(
                        icon: Icons.perm_media,
                        title: l.t('manage_media_card_title'),
                        subtitle: l.t('manage_media_card_subtitle'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ManageMediaScreen(viewer: widget.user),
                          ),
                        ),
                      ),
                    );
                  }
                  if (cards.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l.t('admin_no_pages_access'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }
                  return GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                    children: cards,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4423).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6B4423), size: 24),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        maxHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                              height: 1.25,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
