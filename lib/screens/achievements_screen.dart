import 'package:flutter/material.dart';
import 'package:hqapp/models/user_profile.dart';
import 'package:hqapp/screens/login_screen.dart';
import 'package:hqapp/services/firestore_service.dart';

class AchievementsScreen extends StatefulWidget {
  final UserProfile user;

  const AchievementsScreen({super.key, required this.user});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Map<String, dynamic>> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (widget.user.id == 'guest') {
      setState(() {
        _achievements = _getDefaultAchievements(false, 0, false, false);
        _isLoading = false;
      });
      return;
    }

    final quizResults = await FirestoreService.getUserQuizResults(
      widget.user.id,
    );
    final quizCount = quizResults.length;
    final hasFullMark = quizResults.any((r) => r.score == r.totalQuestions);
    final hasFirstQuiz = quizCount > 0;
    final hasPerfectScore = quizResults.any(
      (r) => r.score == r.totalQuestions && r.totalQuestions >= 5,
    );

    final achievements = _getDefaultAchievements(
      hasFirstQuiz,
      quizCount,
      hasFullMark,
      hasPerfectScore,
    );

    // Update achievements and leaderboard
    await FirestoreService.updateUserAchievementsAndLeaderboard(
      userId: widget.user.id,
      userName: widget.user.fullName,
    );

    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getDefaultAchievements(
    bool hasFirstQuiz,
    int quizCount,
    bool hasFullMark,
    bool hasPerfectScore,
  ) {
    final consecutivePerfect = 0; // Would need to track this

    return [
      {
        'id': 1,
        'title': 'First Quiz',
        'description': 'Complete your first quiz',
        'icon': '🎯',
        'unlocked': hasFirstQuiz,
        'points': 50,
      },
      {
        'id': 2,
        'title': 'Perfect Score',
        'description': 'Get full marks in a quiz',
        'icon': '🏆',
        'unlocked': hasFullMark,
        'points': 100,
      },
      {
        'id': 3,
        'title': 'Quiz Master',
        'description': 'Complete 5 quizzes',
        'icon': '📚',
        'unlocked': quizCount >= 5,
        'points': 150,
      },
      {
        'id': 4,
        'title': 'History Expert',
        'description': 'Complete 10 quizzes',
        'icon': '🎓',
        'unlocked': quizCount >= 10,
        'points': 250,
      },
      {
        'id': 5,
        'title': 'Flawless Victory',
        'description': 'Get perfect score in 5-question quiz',
        'icon': '⭐',
        'unlocked': hasPerfectScore,
        'points': 200,
      },
      {
        'id': 6,
        'title': 'Dedicated Learner',
        'description': 'Complete 20 quizzes',
        'icon': '🌟',
        'unlocked': quizCount >= 20,
        'points': 300,
      },
      {
        'id': 7,
        'title': 'Speed Demon',
        'description': 'Complete 3 quizzes in one day',
        'icon': '⚡',
        'unlocked': false, // Would need to track daily quiz count
        'points': 175,
      },
      {
        'id': 8,
        'title': 'Heritage Scholar',
        'description': 'Complete 30 quizzes',
        'icon': '🎖️',
        'unlocked': quizCount >= 30,
        'points': 400,
      },
      {
        'id': 9,
        'title': 'Perfect Streak',
        'description': 'Get 3 perfect scores in a row',
        'icon': '🔥',
        'unlocked': consecutivePerfect >= 3,
        'points': 350,
      },
      {
        'id': 10,
        'title': 'Master Explorer',
        'description': 'Complete 50 quizzes',
        'icon': '👑',
        'unlocked': quizCount >= 50,
        'points': 500,
      },
      {
        'id': 11,
        'title': 'Quick Thinker',
        'description': 'Complete a quiz in under 2 minutes',
        'icon': '⏱️',
        'unlocked': false, // Would need to track quiz time
        'points': 125,
      },
      {
        'id': 12,
        'title': 'Consistent Performer',
        'description': 'Complete 7 quizzes in a week',
        'icon': '📅',
        'unlocked': false, // Would need to track weekly quiz count
        'points': 275,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.id == 'guest') {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Achievements',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: const Color(0xFF6B4423),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
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
                  'Login Required',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You need to login to access the achievement page.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.of(context, rootNavigator: true).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Achievements',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          backgroundColor: const Color(0xFF6B4423),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAchievements();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAchievements,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Your Achievements',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlock achievements to earn points and show off your heritage exploration skills!',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Unlocked',
                            _achievements.where((a) => a['unlocked']).isNotEmpty
                                ? _achievements
                                      .where((a) => a['unlocked'])
                                      .length
                                      .toString()
                                : 'Start playing!',
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Total Points',
                            _achievements
                                        .where((a) => a['unlocked'])
                                        .fold(
                                          0,
                                          (sum, a) =>
                                              sum + (a['points'] as int),
                                        ) >
                                    0
                                ? _achievements
                                      .where((a) => a['unlocked'])
                                      .fold(
                                        0,
                                        (sum, a) => sum + (a['points'] as int),
                                      )
                                      .toString()
                                : 'Earn points!',
                            Icons.stars,
                            Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Achievements Grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final achievement = _achievements[index];
                  return _buildAchievementCard(achievement);
                }, childCount: _achievements.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] as bool;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    achievement['icon'],
                    style: TextStyle(
                      fontSize: 26,
                      color: isUnlocked ? null : Colors.grey[400],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Title
              Flexible(
                child: Text(
                  achievement['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isUnlocked ? null : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),

              // Description
              Flexible(
                child: Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),

              // Points
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${achievement['points']} pts',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(height: 4),

              // Status
              if (isUnlocked)
                const Icon(Icons.check_circle, color: Colors.green, size: 18)
              else
                Icon(Icons.lock, color: Colors.grey[400], size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
