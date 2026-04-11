import 'package:flutter/material.dart';
import 'package:hqapp/models/leaderboard_entry.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/models/notification_entry.dart';
import 'package:hqapp/screens/achievements_screen.dart';
import 'package:hqapp/screens/feedback_form_screen.dart';
import 'package:hqapp/screens/leaderboard_screen.dart';
import 'package:hqapp/screens/login_screen.dart';
import 'package:hqapp/screens/notifications_screen.dart';
import 'package:hqapp/screens/quiz_screen.dart';
import 'package:hqapp/screens/map_tracking_screen.dart';
import 'package:hqapp/screens/tutorial_screen.dart';
import 'package:hqapp/services/firestore_service.dart';
import 'package:hqapp/localization/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final UserProfile user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late UserProfile _user;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool screenOpen = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    screenOpen = false;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapTrackingScreen()),
    );
  }

  void _goToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
    );
  }

  void _goToAchievements() {
    // Navigate directly - Achievements screen will show lock screen for guests
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AchievementsScreen(user: _user)),
    );
  }

  void _goToQuiz() {
    // Navigate directly - Quiz screen will show lock screen for guests
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen(user: _user)),
    );
  }

  Future<void> _editAccount() async {
    final l = AppLocalizations.of(context);
    final nameController = TextEditingController(text: _user.fullName);
    final contactController = TextEditingController(text: _user.contactNo);

    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.t('edit_account'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l.t('full_name')),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: l.t('mobile_number')),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) {
                      Navigator.pop(context);
                      return;
                    }
                    Navigator.pop(context, 'save');
                  },
                  child: Text(l.t('save')),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, 'changePassword'),
                  icon: const Icon(Icons.lock, color: const Color(0xFF6B4423)),
                  label: Text(
                    l.t('change_password'),
                    style: const TextStyle(color: Color(0xFF6B4423)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6B4423)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (action == 'save') {
      final updated = _user.copyWith(
        fullName: nameController.text.trim(),
        contactNo: contactController.text.trim(),
      );
      await FirestoreService.updateUser(updated);
      setState(() => _user = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.t('profile_updated_success')),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (action == 'changePassword') {
      await _changePassword();
    }
  }

  Future<void> _changePassword() async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureOldPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;
    bool isLoading = false;
    String? currentPasswordError;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l = AppLocalizations.of(context);
          return AlertDialog(
            title: Text(l.t('change_password')),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: oldPasswordController,
                          obscureText: obscureOldPassword,
                          decoration: InputDecoration(
                            labelText: l.t('current_password'),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureOldPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setDialogState(
                                  () =>
                                      obscureOldPassword = !obscureOldPassword,
                                );
                              },
                            ),
                            errorText: currentPasswordError,
                            errorStyle: const TextStyle(fontSize: 12),
                            border: const OutlineInputBorder(),
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: currentPasswordError != null
                                ? const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                      width: 2,
                                    ),
                                  )
                                : null,
                          ),
                          validator: (value) {
                            if (currentPasswordError != null) {
                              return currentPasswordError;
                            }
                            if (value == null || value.isEmpty) {
                              return l.t('enter_current_password');
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (currentPasswordError != null) {
                              setDialogState(() {
                                currentPasswordError = null;
                              });
                              formKey.currentState?.validate();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: obscureNewPassword,
                      decoration: InputDecoration(
                        labelText: l.t('new_password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(
                              () => obscureNewPassword = !obscureNewPassword,
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l.t('enter_new_password');
                        }
                        if (value.length < 8) {
                          return l.t('password_requirements_min8');
                        }
                        // Check if password contains at least one letter
                        final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(value);
                        // Check if password contains at least one number
                        final hasNumber = RegExp(r'[0-9]').hasMatch(value);

                        if (!hasLetter) {
                          return l.t('password_requirements_letter');
                        }
                        if (!hasNumber) {
                          return l.t('password_requirements_number');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: l.t('confirm_new_password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setDialogState(
                              () => obscureConfirmPassword =
                                  !obscureConfirmPassword,
                            );
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l.t('confirm_new_password_prompt');
                        }
                        if (value != newPasswordController.text) {
                          return l.t('passwords_do_not_match');
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: Text(l.t('cancel')),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        final newPassword = newPasswordController.text;

                        // Additional validation for password requirements
                        if (newPassword.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('password_requirements_min6')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final hasLetter = RegExp(
                          r'[a-zA-Z]',
                        ).hasMatch(newPassword);
                        final hasNumber = RegExp(
                          r'[0-9]',
                        ).hasMatch(newPassword);

                        if (!hasLetter) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('password_requirements_letter')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (!hasNumber) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('password_requirements_number')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (newPassword != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('passwords_do_not_match')),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setDialogState(() => isLoading = true);

                        try {
                          await FirestoreService.changePassword(
                            userId: _user.id,
                            oldPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                          );

                          if (!mounted) return;

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l.t('password_changed_success')),
                              backgroundColor: const Color(0xFF2E7D32),
                              duration: const Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } on AuthException catch (error) {
                          if (!mounted) return;
                          setDialogState(() {
                            isLoading = false;
                            // Check if error is about current password
                            if (error.message.toLowerCase().contains(
                                  'current password',
                                ) ||
                                error.message.toLowerCase().contains(
                                  'incorrect',
                                )) {
                              currentPasswordError = AppLocalizations.localizeError(
                                context,
                                error.message,
                              );
                            }
                          });
                          // Trigger validation to show error below field
                          formKey.currentState?.validate();
                        } catch (e) {
                          if (!mounted) return;
                          setDialogState(() => isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context).t(
                                  'change_password_error',
                                  params: {'error': e.toString()},
                                ),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.t('change_password')),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    final l = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
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
                          Icons.explore,
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
                              _user.id == 'guest'
                                  ? l.t('welcome_guest')
                                  : l.t(
                                      'welcome_user',
                                      params: {'name': _user.fullName},
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
                              l.t('scan_explore_earn'),
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
          const SizedBox(height: 20),
          // Leaderboard Section - Only show for logged in users
          if (_user.id != 'guest')
            StreamBuilder<List<LeaderboardEntry>>(
              stream: FirestoreService.pointsLeaderboardStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final entries = snapshot.data!;
                  final userEntry = entries.firstWhere(
                    (e) => e.userId == _user.id,
                    orElse: () => LeaderboardEntry(
                      userId: _user.id,
                      userName: _user.fullName,
                      totalPoints: 0,
                      lastUpdated: DateTime.now(),
                    ),
                  );

                  int userRank = 0;
                  int totalPoints = userEntry.totalPoints;

                  if (totalPoints > 0) {
                    // Find rank based on position in sorted leaderboard
                    userRank =
                        entries.indexWhere((e) => e.userId == _user.id) + 1;
                    if (userRank == 0) {
                      // If not found, calculate rank based on points
                      final betterEntries = entries
                          .where(
                            (e) =>
                                e.totalPoints > totalPoints ||
                                (e.totalPoints == totalPoints &&
                                    e.lastUpdated.isAfter(
                                      userEntry.lastUpdated,
                                    )),
                          )
                          .length;
                      userRank = betterEntries + 1;
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events,
                              color: const Color(0xFFB8860B),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.t('home_leaderboard_stats'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                l.t('home_points'),
                                totalPoints > 0
                                    ? totalPoints.toString()
                                    : l.t('home_earn_points'),
                                Icons.stars,
                                const Color(0xFFB8860B),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                l.t('home_rank'),
                                userRank > 0
                                    ? '#$userRank'
                                    : l.t('home_start_playing'),
                                Icons.leaderboard,
                                const Color(0xFF6B4423),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB8860B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                color: const Color(0xFFB8860B),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l.t('home_stats_hint'),
                                  style: const TextStyle(
                                    color: Color(0xFF6B4423),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          if (_user.id != 'guest') const SizedBox(height: 20),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildDashboardCard(
                icon: Icons.quiz,
                title: l.t('home_quiz_title'),
                subtitle: l.t('home_quiz_subtitle'),
                color: const Color(0xFF6B4423),
                onTap: _goToQuiz,
              ),
              _buildDashboardCard(
                icon: Icons.map,
                title: l.t('home_map_title'),
                subtitle: l.t('home_map_subtitle'),
                color: const Color(0xFF8B4513),
                onTap: _openMap,
              ),
              _buildDashboardCard(
                icon: Icons.emoji_events,
                title: l.t('home_leaderboard_title'),
                subtitle: l.t('home_leaderboard_subtitle'),
                color: const Color(0xFFB8860B),
                onTap: _goToLeaderboard,
              ),
              _buildDashboardCard(
                icon: Icons.workspace_premium,
                title: l.t('home_achievements_title'),
                subtitle: l.t('home_achievements_subtitle'),
                color: const Color(0xFF2E7D32),
                onTap: _goToAchievements,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 9),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    final l = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
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
                            isSelected:
                                AppLocalizations.currentLanguageCode == 'en',
                            onTap: () {
                              setState(() {
                                AppLocalizations.setLanguage('en');
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          _buildLangChip(
                            label: 'ع',
                            isSelected:
                                AppLocalizations.currentLanguageCode == 'ar',
                            onTap: () {
                              setState(() {
                                AppLocalizations.setLanguage('ar');
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _user.fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _user.email,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    l.t('mobile'),
                    _user.contactNo.isEmpty ? '-' : _user.contactNo,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _user.id == 'guest' ? null : _editAccount,
                          child: Text(l.t('edit_account')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FeedbackFormScreen(user: _user),
                              ),
                            );
                          },
                          child: Text(l.t('feedback')),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Tutorialpage(user: _user),
                              ),
                                  (route) => false,
                            );
                          },
                          child: Text(l.t('tutorial')),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        l.t('logout'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildScanContent() {
    final l = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: _buildGradientButton(
                onPressed: () {
                  setState(() {
                    screenOpen = false;
                  });
                  controller?.resumeCamera();
                },
                text: l.t('qr_scan_again'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = [
      _buildHomeContent(),
      _buildScanContent(),
      _buildProfileContent(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('app_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        actions: _user.id != 'guest'
            ? [
                StreamBuilder<List<NotificationEntry>>(
                  stream: FirestoreService.notificationsStream(_user.id),
                  builder: (context, snapshot) {
                    int unreadCount = 0;
                    if (snapshot.hasData) {
                      unreadCount = snapshot.data!
                          .where((n) => !n.isRead)
                          .length;
                    }
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.notifications),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NotificationsScreen(user: _user),
                              ),
                            );
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ]
            : null,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6B4423),
          unselectedItemColor: Colors.grey[400],
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l.t('home_tab_home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              activeIcon: const Icon(Icons.qr_code_scanner),
              label: l.t('home_tab_scan'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: l.t('home_tab_profile'),
            ),
          ],
        ),
      ),
    );
  }

  //Function for the scan page
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (!screenOpen && result?.code != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoundCodeScreen(value: result),
            ),
          );
          controller.pauseCamera();
          screenOpen = true;
        }
      });
    });
  }

  //building gradiant button for the scan page
  Widget _buildGradientButton({required String text, VoidCallback? onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6B4423), const Color(0xFF8B4513)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4423).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }



}
